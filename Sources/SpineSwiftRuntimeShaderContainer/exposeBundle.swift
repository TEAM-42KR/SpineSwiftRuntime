//
//  exposeBundle.swift
//  SpineSwiftRuntime
//
//  Created by 박병관 on 12/11/25.
//

public import Foundation

@usableFromInline
package enum SpineSwiftRuntimeShaderContainer {

    @usableFromInline
    package static func exposedBundle() -> Bundle {
        .module
    }

}
