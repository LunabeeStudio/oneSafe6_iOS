//
//  CodableForAppModel.swift
//  Model
//
//  Created by Lunabee Studio (Nicolas) on 28/05/2021 - 10:34.
//  Copyright © 2021 Lunabee Studio. All rights reserved.
//

public protocol EncodableToAppModel: Identifiable {
    associatedtype AppModel
    func toAppModel() throws -> AppModel
}

public protocol DecodableFromAppModel: Identifiable {
    associatedtype AppModel
    static func from(appModel: AppModel) throws -> Self
}

public typealias CodableForAppModel = EncodableToAppModel & DecodableFromAppModel
