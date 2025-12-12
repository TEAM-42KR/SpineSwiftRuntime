//
//  SpineRendererDelegate.swift
//  spine-ios
//
//  Created by 박병관 on 3/17/25.
//

public import Foundation
public import spine_apple_extension

#if canImport(Metal)
    public import Metal
    @objc
    public protocol SpineRendererDelegate: AnyObject {

        func spineRenderer(_ renderer: SpineRenderer, willUpdateAtTime time: CFAbsoluteTime)

        func spineRenderer(_ renderer: SpineRenderer, didUpdateAtTime time: CFAbsoluteTime)

        func spineRenderer(_ renderer: SpineRenderer, textureForPage page: spine_atlas_page) -> (any MTLTexture)?

        func spineRenderer(_ renderer: SpineRenderer, vertexBufferForMinimumSize minimumSize: Int) -> (any SpineVertexBuffer)?

        func spineRenderer(_ renderer: SpineRenderer, samplerForPage page: spine_atlas_page) -> (any MTLSamplerState)

    }

    extension SpineRendererDelegate {

        public func spineRenderer(_ renderer: SpineRenderer, willUpdateAtTime time: CFAbsoluteTime) {}

        public func spineRenderer(_ renderer: SpineRenderer, didUpdateAtTime time: CFAbsoluteTime) {}

    }

    @objc
    public protocol SpineVertexBuffer {

        /// buffer must be cpu accessible
        var buffer: any MTLBuffer { get }

        var offsetInBytes: Int { get }
    }

    extension SpineVertexBuffer {

        var offsetInBytes: Int { 0 }

    }

#endif  // canImport(Metal)
