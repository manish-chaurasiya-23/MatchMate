//
//  Persistence.swift
//  MatchMate
//
//  Created by Manish Kumar on 23/12/24.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "MatchMate")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func deleteAllPersons() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Person.fetchRequest()
        let context = PersistenceController.shared.container.viewContext
        
        do {
            let results = try context.fetch(fetchRequest)
            
            for object in results {
                if let personToDelete = object as? NSManagedObject {
                    context.delete(personToDelete)
                }
            }
            
            try context.save()
        } catch {
            print("Failed to delete all persons: \(error.localizedDescription)")
        }
    }
}
