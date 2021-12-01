//
//  PersistenceController.swift
//  S.C.R.E.E.N
//
//  Created by Bogdan on 11/19/21.
//

import CoreData

struct PersitenceController {
    
    static let shared = PersitenceController()
    let container: NSPersistentContainer
    let context: NSManagedObjectContext
    
    init() {
        
        container = NSPersistentContainer(name: "SessionModel")
        container.loadPersistentStores { (description, error) in
            
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
        
        context = container.viewContext
    }
    
    func save(completion: @escaping (Error?) -> () = {_ in}) {
        
        if context.hasChanges {
            do {
                
                try context.save()
                print("saved")
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    func delete(_ object: NSManagedObject, completion: @escaping (Error?) -> () = {_ in}) {
        
        context.delete(object)
        save(completion: completion)
    }
}

