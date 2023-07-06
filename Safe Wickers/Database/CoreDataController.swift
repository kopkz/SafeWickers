//
//  CoreDataController.swift
//  Safe Wickers
//
//  Created by 匡正 on 25/4/20.
//  Copyright © 2020 匡正. All rights reserved.
//

import UIKit
import CoreData

class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate{
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistantContainer: NSPersistentContainer
    
    // results
    var lovedBeachsFetchedResultsController : NSFetchedResultsController<LovedBeach>?
    
    //init
    override init() {
        persistantContainer = NSPersistentContainer(name: "LovedBeachModel")
        persistantContainer.loadPersistentStores() {(description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        super.init()
    }
    
    func saveContext(){
        if persistantContainer.viewContext.hasChanges{
            do{
                try persistantContainer.viewContext.save()
            } catch{
                fatalError("Failed to save Core Data stack: \(error)")
            }
        }
    }
    
    func addLovedBeach(beachName: String, lat: Double, long: Double, imageName: String, ifGuard: Bool, ifPort: Bool) -> LovedBeach {
        let lovedBeach = NSEntityDescription.insertNewObject(forEntityName: "LovedBeach", into: persistantContainer.viewContext) as! LovedBeach
        lovedBeach.beachName = beachName
        lovedBeach.lat = lat
        lovedBeach.long = long
        lovedBeach.ifPort = ifPort
        lovedBeach.ifGuard = ifGuard
        lovedBeach.imageNmae = imageName
        
        // This less efficient than batching changes and saving once at end.
        saveContext()
        return lovedBeach
    }
    
    func deleteLovedBeach(lovedBeach: LovedBeach) {
        persistantContainer.viewContext.delete(lovedBeach)
        // This less efficient than batching changes and saving once at end.
        saveContext()
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == ListenerType.lovedBeach {
            listener.onLovedBeachChange(change: .update, lovedBeachs: fetchLovedBeachs())
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func fetchLovedBeachs() -> [LovedBeach]{
        if lovedBeachsFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<LovedBeach> = LovedBeach.fetchRequest()
            let nameSortDeacriptor = NSSortDescriptor(key: "beachName", ascending: true)
            fetchRequest.sortDescriptors = [nameSortDeacriptor]
            lovedBeachsFetchedResultsController = NSFetchedResultsController<LovedBeach>(fetchRequest: fetchRequest, managedObjectContext: persistantContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            lovedBeachsFetchedResultsController?.delegate = self
            
            do{
                try lovedBeachsFetchedResultsController?.performFetch()
            }catch{
                print("Fetch Request failed: \(error)")
            }
        }
        var lovedBeachs = [LovedBeach]()
        if lovedBeachsFetchedResultsController?.fetchedObjects != nil {
            lovedBeachs = (lovedBeachsFetchedResultsController?.fetchedObjects)!
        }
        return lovedBeachs
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == lovedBeachsFetchedResultsController {
            listeners.invoke{ (listener) in
                if listener.listenerType == ListenerType.lovedBeach{
                    listener.onLovedBeachChange(change: .update, lovedBeachs: fetchLovedBeachs())
                }
                
            }
        }
    }

}
