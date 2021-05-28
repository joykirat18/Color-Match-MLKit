//
//  Settings.swift
//  Color Match
//
//  Created by Joykirat on 28/05/21.
//  Copyright © 2021 Google Inc. All rights reserved.
//

import SpriteKit


enum PhysicsCategories {
    static let none: UInt32 = 0
    static let ballCategory: UInt32 = 0x1         //01
    static let switchCategory: UInt32 = 0x1 << 1  //10
}
