//
//  DataHelper.swift
//  MapViewTest
//
//  Created by Richard E. Brown on 5/6/16.
//  Copyright © 2016 Zipcar. All rights reserved.
//

import Foundation
import UIKit
import MagicalRecord

protocol DataHelperProtocol
{
    associatedtype T

    static func preload (items: [T]) throws -> Int64
    static func insert (item: T) throws -> Int64
    static func delete (item: T) throws -> Void
    static func findAll () throws -> [T]?
}

//class LocationHelper: DataHelperProtocol
//{
//
//}