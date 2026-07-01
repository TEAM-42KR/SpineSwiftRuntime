//
//  SpineMetalPipeLineStorage.swift
//  spine-ios
//
//  Created by 박병관 on 7/5/25.
//
#if canImport(Metal)
    internal import SpineSwiftRuntimeShaderContainer
    public import Metal
    public import SpineC

    public class SpineMetalPipeLineStorage: NSObject {

        @inline(__always)
        @usableFromInline
        internal static var caseIterableBlendModes: ContiguousArray<spine_blend_mode> {
            [
                SPINE_BLEND_MODE_NORMAL,
                SPINE_BLEND_MODE_ADDITIVE,
                SPINE_BLEND_MODE_MULTIPLY,
                SPINE_BLEND_MODE_SCREEN,
            ]
        }

        @inline(__always)
        @usableFromInline
        internal let storage: ContiguousArray<MTLRenderPipelineState?>


        @nonobjc
        internal init(storage: ContiguousArray<MTLRenderPipelineState?>) {
            self.storage = storage
        }

        @objc public convenience init(library: any MTLLibrary, pixelFormat: MTLPixelFormat) throws {
            let blendModes = Self.caseIterableBlendModes
            let descriptor = MTLRenderPipelineDescriptor()
            // The vertex-color premultiply and the texture premultiply are two
            // independent decisions, so specialize each stage with its own
            // function constant. Vertex colors always arrive straight from the C
            // runtime, so they must be premultiplied whenever the page is pma;
            // the texture must only be premultiplied when it is straight and
            // composited into a premultiplied blend.
            func makeVertex(premultiplyColor: Bool) throws -> any MTLFunction {
                let constants = MTLFunctionConstantValues()
                var value = premultiplyColor
                constants.setConstantValue(&value, type: .bool, withName: "kPremultiplyVertexColor")
                return try library.makeFunction(name: "spine_vertexShader", constantValues: constants)
            }
            func makeFragment(premultiplyTexture: Bool) throws -> any MTLFunction {
                let constants = MTLFunctionConstantValues()
                var value = premultiplyTexture
                constants.setConstantValue(&value, type: .bool, withName: "kPremultiplyTexture")
                return try library.makeFunction(name: "spine_fragmentShader", constantValues: constants)
            }

            let vertexPremultiplied = try makeVertex(premultiplyColor: true)
            let vertexStraight = try makeVertex(premultiplyColor: false)
            let fragmentPremultipliesTexture = try makeFragment(premultiplyTexture: true)
            let fragmentUsesTextureAsIs = try makeFragment(premultiplyTexture: false)

            descriptor.colorAttachments[0].pixelFormat = pixelFormat
            descriptor.vertexBuffers[0].mutability = .immutable
            descriptor.vertexBuffers[1].mutability = .immutable
            descriptor.vertexBuffers[2].mutability = .immutable
            descriptor.fragmentBuffers[0].mutability = .immutable
            var pipeLinecache = [Int: MTLRenderPipelineState]()
            var buffer = ContiguousArray<MTLRenderPipelineState?>()
            for blendMode in blendModes {
                var label = ""
                switch blendMode {
                case SPINE_BLEND_MODE_NORMAL:
                    label = "SPINE_NORMAL"
                case SPINE_BLEND_MODE_SCREEN:
                    label = "SPINE_SCREEN"
                case SPINE_BLEND_MODE_MULTIPLY:
                    label = "SPINE_MULTIPLY"
                case SPINE_BLEND_MODE_ADDITIVE:
                    label = "SPINE_ADDITIVE"
                default:
                    continue
                }
                for pma in [false, true] {
                    // Vertex color: premultiply when the page is premultiplied.
                    descriptor.vertexFunction = pma ? vertexPremultiplied : vertexStraight

                    // Texture: premultiply the texel in-shader only for a straight
                    // (non-pma) texture fed into a blend that expects a
                    // premultiplied source RGB (multiply/screen). Normal/additive
                    // let the .sourceAlpha factor do the weighting, and any pma
                    // page is already premultiplied — so both leave it as-is.
                    let premultiplyTextureInShader =
                        (blendMode == SPINE_BLEND_MODE_MULTIPLY || blendMode == SPINE_BLEND_MODE_SCREEN) && !pma
                    descriptor.fragmentFunction =
                        premultiplyTextureInShader ? fragmentPremultipliesTexture : fragmentUsesTextureAsIs
                    descriptor.label = premultiplyTextureInShader ? label + "_PMTEX" : label

                    descriptor.colorAttachments[0].apply(
                        blendMode: blendMode,
                        with: pma
                    )
                    let hashCode = descriptor.colorAttachments[0].computeLocalHashCode(pma: pma)
                    if let existing = pipeLinecache[hashCode] {
                        buffer.append(existing)
                    } else {
                        let newPipeLine = try library.device.makeRenderPipelineState(descriptor: descriptor)
                        pipeLinecache[hashCode] = newPipeLine
                        buffer.append(newPipeLine)
                    }
                }

            }
            self.init(storage: buffer)
        }


        @objc public convenience init(device: any MTLDevice, pixelFormat: MTLPixelFormat) throws {
            let defaultLibrary = try device.makeDefaultLibrary(bundle: SpineSwiftRuntimeShaderContainer.exposedBundle())
            try self.init(library: defaultLibrary, pixelFormat: pixelFormat)
        }

        @nonobjc
        public convenience init<E: Error>(
            device: MTLDevice,
            block: (MTLDevice, ColorBlendPipeLineKey) throws(E) -> MTLRenderPipelineState?
        ) throws(E) {
            let blendModes = Self.caseIterableBlendModes
            var buffer = ContiguousArray<MTLRenderPipelineState?>()
            for blendMode in blendModes {
                for pma in [false, true] {
                    let state = try (block(device, .init(pma: pma, blendMode: blendMode)))
                    buffer.append(state)

                }

            }
            self.init(storage: buffer)
        }

        @available(swift, obsoleted: 1.0)
        @objc
        public convenience init(
            device: any MTLDevice,
            block: (MTLDevice, SpineColorBlendBridgedKey, UnsafeMutablePointer<NSError?>) -> MTLRenderPipelineState?
        ) throws {
            let blendModes = Self.caseIterableBlendModes
            var buffer = ContiguousArray<MTLRenderPipelineState?>()
            var error: NSError? = nil
            for blendMode in blendModes {
                for pma in [false, true] {
                    let state = (block(device, .init(pma: pma, blendMode: blendMode), &error))
                    if let _error = error {
                        throw _error
                    }
                    buffer.append(state)
                }

            }
            self.init(storage: buffer)
        }

        @usableFromInline
        @inline(__always)
        internal func renderPipelineState(
            for blendMode: spine_blend_mode,
            premultiplyAlpha: Bool = true
        ) -> MTLRenderPipelineState? {
            let base = Int(blendMode.rawValue) << 1
            let index = base | (premultiplyAlpha ? 1 : 0)
            guard index < storage.count else {
                return nil
            }
            return storage[index]
        }

        @nonobjc
        public func renderPipelineState(_ key: ColorBlendPipeLineKey) -> MTLRenderPipelineState? {
            return renderPipelineState(for: key.blendMode, premultiplyAlpha: key.pma)
        }

        @objc(renderPipelineStatefromKey:)
        public func __renderPipelineState(_ key: SpineColorBlendBridgedKey) -> MTLRenderPipelineState? {
            return renderPipelineState(key.imp)
        }


    }


    extension MTLRenderPipelineColorAttachmentDescriptor {

        fileprivate func computeLocalHashCode(pma: Bool) -> Int {
            var hasher = Hasher()
            hasher.combine(self.sourceRGBBlendFactor)
            hasher.combine(self.sourceAlphaBlendFactor)
            hasher.combine(self.destinationRGBBlendFactor)
            hasher.combine(self.destinationAlphaBlendFactor)
            hasher.combine(pma)
            return hasher.finalize()
        }

    }

    extension MTLRenderPipelineColorAttachmentDescriptor {

        fileprivate func apply(blendMode: spine_blend_mode, with premultipliedAlpha: Bool) {
            isBlendingEnabled = true
            sourceRGBBlendFactor = blendMode.sourceRGBBlendFactor(premultipliedAlpha: premultipliedAlpha)
            sourceAlphaBlendFactor = blendMode == SPINE_BLEND_MODE_SCREEN ? .oneMinusDestinationAlpha : .one
            switch blendMode {
            case SPINE_BLEND_MODE_NORMAL, SPINE_BLEND_MODE_MULTIPLY:
                destinationAlphaBlendFactor = .oneMinusSourceAlpha
                destinationRGBBlendFactor = .oneMinusSourceAlpha
            case SPINE_BLEND_MODE_ADDITIVE, SPINE_BLEND_MODE_SCREEN:
                destinationAlphaBlendFactor = .one
                destinationRGBBlendFactor = .one
            default:
                destinationRGBBlendFactor = .one
                destinationAlphaBlendFactor = .one
            }
        }

    }

    extension spine_blend_mode {

        fileprivate func sourceRGBBlendFactor(premultipliedAlpha: Bool) -> MTLBlendFactor {
            switch self {
            case SPINE_BLEND_MODE_NORMAL:
                return premultipliedAlpha ? .one : .sourceAlpha
            case SPINE_BLEND_MODE_ADDITIVE:
                return premultipliedAlpha ? .one : .sourceAlpha
            case SPINE_BLEND_MODE_MULTIPLY:
                // requires src rgb chnnel to be multiplied by 1 alpha src before blending in non pma
                return .destinationColor
            case SPINE_BLEND_MODE_SCREEN:
                // requires src rgb chnnel to be multiplied by 1 alpha src before blending in non pma
                return .oneMinusDestinationColor
            default:
                return .one  // Should never be called
            }
        }

    }

#endif  // canImport(Metal)
