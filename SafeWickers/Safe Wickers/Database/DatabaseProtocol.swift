//
//  DatabaseProtocol.swift
//  Safe Wickers
//
//  Created by 匡正 on 25/4/20.
//  Copyright © 2020 匡正. All rights reserved.
//

import Foundation

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case lovedBeach
}

protocol DatabaseListener:AnyObject {
    var listenerType: ListenerType{get set}
    func onLovedBeachChange(change: DatabaseChange, lovedBeachs:[LovedBeach])
}

protocol DatabaseProtocol:AnyObject {
    func addLovedBeach(beachName: String, lat: Double, long: Double, imageName: String, ifGuard: Bool, ifPort: Bool) -> LovedBeach
    func deleteLovedBeach(lovedBeach: LovedBeach)
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
}
