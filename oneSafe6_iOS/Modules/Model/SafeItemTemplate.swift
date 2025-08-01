//
//  SafeItemTemplate.swift
//  Model
//
//  Created by Lunabee Studio (François Combe) on 16/09/2022 - 11:21.
//  Copyright © 2022 Lunabee Studio. All rights reserved.
//
import Foundation

public enum SafeItemTemplate: Hashable {
    case website
    case creditCard
    case application
    case folder
    case custom
    case note
    case mediaFromLibrary
    case mediaFromCamera
    case mediaFromFiles
    case files

    case fromPasteboard(url: String)

    public static var defaultTemplates: [SafeItemTemplate] = [
        .website,
        .creditCard,
        .application,
        .folder,
        .custom,
        .note,
        .mediaFromLibrary,
        .mediaFromCamera,
        .mediaFromFiles,
        .files
    ]
}
