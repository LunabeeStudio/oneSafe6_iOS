//
//  RealmStorable.swift
//  oneSafe
//
//  Created by Lunabee Studio (Francois Beta) on 04/08/2022 - 10:43.
//  Copyright © 2022 Lunabee Studio. All rights reserved.
//

import Model
import RealmSwift

public protocol RealmStorable {
    associatedtype RModel: Object, CodableForAppModel where RModel.AppModel == Self
}
