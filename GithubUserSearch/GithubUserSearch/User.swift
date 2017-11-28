//
//  User.swift
//  GithubUserSearch
//
//  Created by Vikas Dadheech on 22/11/17.
//  Copyright © 2017 startrek. All rights reserved.
//

import UIKit

class User: NSObject {
	var userId : NSInteger?
	var avatarUrl : String?
	var login: String?
	var name : String?
	var followersCount : NSInteger?
	var repoCount : NSInteger?
	var gistCount : NSInteger?
	var htmlUrl : String?
	var company : String?
	var location : String?
	var creationDate : String?
	var updatedDate : String?
	var followersUrl : String?
	var gistsUrl : String?
	var reposUrl : String?

   init(dicitonary: [String : Any]){
	
		super.init()
		userId = (dicitonary["id"] as? NSInteger)
		avatarUrl = dicitonary["avatar_url"] as? String
		name = dicitonary["name"] as? String
		followersCount = (dicitonary["followers"] as? NSInteger)
		repoCount = (dicitonary["public_repos"] as? NSInteger)
		gistCount = (dicitonary["public_repos"] as? NSInteger)
		login = dicitonary["login"] as? String
		htmlUrl = dicitonary["html_url"] as? String
		company = dicitonary["company"] as? String
		location = dicitonary["location"] as? String
		creationDate = dicitonary["created_at"] as? String
		updatedDate = dicitonary["updated_at"] as? String
	followersUrl = dicitonary["followers_url"] as? String
	gistsUrl = dicitonary["gists_url"] as? String
	reposUrl = dicitonary["repos_url"] as? String
	
	}

}
