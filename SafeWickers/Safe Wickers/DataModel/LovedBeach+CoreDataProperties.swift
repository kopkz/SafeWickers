//
//  LovedBeach+CoreDataProperties.swift
//  Safe Wickers
//
//  Created by 匡正 on 25/4/20.
//  Copyright © 2020 匡正. All rights reserved.
//
//

import Foundation
import CoreData


extension LovedBeach {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LovedBeach> {
        return NSFetchRequest<LovedBeach>(entityName: "LovedBeach")
    }

    @NSManaged public var beachName: String?
    @NSManaged public var lat: Double
    @NSManaged public var long: Double
    @NSManaged public var imageNmae: String?
    @NSManaged public var ifGuard: Bool
    @NSManaged public var ifPort: Bool

}
