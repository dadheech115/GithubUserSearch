//
//  DBManager.swift
//  GithubUserSearch
//
//  Created by Vikas Dadheech on 27/11/17.
//  Copyright © 2017 startrek. All rights reserved.
//

import UIKit
import CoreData

class DBManager: NSObject {
	
	
	class func addUser(user : User?) {
		let managedContext = DBMapper.getInstance().managedObjectContext
		if DBManager().checkIfUserDetailPresent(user : user) == false {
			if let entity =  NSEntityDescription.entity(forEntityName: "UserInfo",in:managedContext) {
				let msgupdate = NSManagedObject(entity: entity,insertInto: managedContext)
				do {
					msgupdate.setValue(user?.login ,forKey: "login")
					msgupdate.setValue(user?.name ,forKey: "name")
					msgupdate.setValue(user?.userId,forKey: "userId")
					msgupdate.setValue(user?.avatarUrl, forKey: "avatarUrl")
					
					try managedContext.save()
				}
				catch let error as NSError {
					print("Could not fetch \(error), \(error.userInfo)")
				}
			}
		}else{
			updateUser(user: user)
		}
	}
	
	class func updateUser(user : User?) {
		
		let managedContext = DBMapper.getInstance().managedObjectContext
				let msgupdate = getUserDetail(searchKey: (user?.login)!)
				do {
					msgupdate?.setValue(user?.login ,forKey: "login")
					msgupdate?.setValue(user?.name ,forKey: "name")
					msgupdate?.setValue(user?.avatarUrl, forKey: "avatarUrl")
					msgupdate?.setValue(user?.userId,forKey: "userId")
					msgupdate?.setValue(user?.followersCount,forKey: "followersCount")
					msgupdate?.setValue(user?.repoCount,forKey: "repoCount")
					msgupdate?.setValue(user?.gistCount,forKey: "gistCount")
					msgupdate?.setValue(user?.htmlUrl,forKey: "htmlUrl")
					msgupdate?.setValue(user?.company,forKey: "company")
					msgupdate?.setValue(user?.location,forKey: "location")
					msgupdate?.setValue(user?.creationDate,forKey: "creationDate")
					msgupdate?.setValue(user?.updatedDate,forKey: "updatedDate")
					msgupdate?.setValue(user?.followersUrl,forKey: "followersUrl")
					msgupdate?.setValue(user?.gistsUrl,forKey: "gistsUrl")
					msgupdate?.setValue(user?.reposUrl,forKey: "reposUrl")
					
					
					try managedContext.save()
				}
				catch let error as NSError {
					print("Could not fetch \(error), \(error.userInfo)")
				}
		
	}
	
	class func getUserDetail(searchKey : String) -> UserInfo? {
		
		let managedContext = DBMapper.getInstance().managedObjectContext
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserInfo")
		let p1 = NSPredicate(format:"login = %@", searchKey)
		let p2 = NSPredicate(format:"name = %@", searchKey)
		
		fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [p1,p2])
		
		do {
			let results = try managedContext.fetch(fetchRequest) as? [NSManagedObject]
			if results?.isEmpty == false {
				return (results?[0] as? UserInfo)
			}
		}
		catch let error as NSError {
			print("Could not fetch \(error), \(error.userInfo)")
		}
		return nil
	}
	
	class func getUsers(searchKey : String) -> [NSManagedObject] {
		
		let managedContext = DBMapper.getInstance().managedObjectContext
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserInfo")
		
		//[NSPredicate predicateWithFormat:@"%K like %@",
		//attributeName, attributeValue]
		//firstName BEGINSWITH[cd]
		let p1 = NSPredicate(format:"login CONTAINS[cd] %@", searchKey)
		let p2 = NSPredicate(format:"name CONTAINS[cd] %@", searchKey)
		
		fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [p1,p2])
		
		do {
			let results = try managedContext.fetch(fetchRequest) as? [NSManagedObject]
			if results?.isEmpty == false {
				return (results as! [NSManagedObject])
			}
		}
		catch let error as NSError {
			print("Could not fetch \(error), \(error.userInfo)")
		}
		return []
	}

	private func checkIfUserDetailPresent(user : User?) -> Bool {
		
		if let id = user?.userId  {
			
			let managedContext = DBMapper.getInstance().managedObjectContext
			let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserInfo")
			
			fetchRequest.predicate = NSPredicate(format:"userId = %d", id)
			
			do {
				let results = try managedContext.fetch(fetchRequest)
				if results.isEmpty == false {
					return true
				}
			}
			catch let error as NSError {
				print("Could not fetch \(error), \(error.userInfo)")
			}
		}
		return false
	}
}
