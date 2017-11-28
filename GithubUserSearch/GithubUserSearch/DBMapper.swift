//
//  DBMapper.swift
//  GithubUserSearch
//
//  Created by Vikas Dadheech on 27/11/17.
//  Copyright © 2017 startrek. All rights reserved.
//

import UIKit
import CoreData

class DBMapper {
	static let sharedInstance = DBMapper()
	
	private init() {
		
	}
	
	static func getInstance() -> DBMapper
	{
		return sharedInstance
	}
	
	lazy var applicationDocumentsDirectory: NSURL = {
		let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return urls[urls.count-1] as NSURL
	}()
	
	lazy var managedObjectModel: NSManagedObjectModel = {
		let modelURL = Bundle.main.url(forResource: "GithubUserSearchModel", withExtension: "momd")!
		return NSManagedObjectModel(contentsOf: modelURL)!
	}()
	
	lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
		let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
		let url = self.applicationDocumentsDirectory.appendingPathComponent("GithubUserSearch")!.appendingPathExtension("sqlite")
		var failureReason = "There was an error creating or loading the application's saved data."
		var options: [NSObject : AnyObject] = [NSMigratePersistentStoresAutomaticallyOption as NSObject: true as AnyObject, NSInferMappingModelAutomaticallyOption as NSObject: true as AnyObject]
		do {
			try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
		} catch {
			// Report any error we got.
			var dict = [String: AnyObject]()
			dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
			dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
			
			dict[NSUnderlyingErrorKey] = error as NSError
			let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
		
			NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
		}
		return coordinator
	}()
	
	lazy var managedObjectContext: NSManagedObjectContext = {
		let coordinator = self.persistentStoreCoordinator
		var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
		managedObjectContext.persistentStoreCoordinator = coordinator
		managedObjectContext.mergePolicy = NSOverwriteMergePolicy
		return managedObjectContext
	}()
	
	func saveContext () {
		
		if managedObjectContext.hasChanges {
			do {
				try managedObjectContext.save()
			} catch {
				// Replace this implementation with code to handle the error appropriately.
				// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				let nserror = error as NSError
				NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
			}
		}
	}
	
}

