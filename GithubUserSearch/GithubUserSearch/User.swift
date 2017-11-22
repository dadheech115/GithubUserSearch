//
//  User.swift
//  GithubUserSearch
//
//  Created by Vikas Dadheech on 22/11/17.
//  Copyright © 2017 startrek. All rights reserved.
//

import UIKit

class User: NSObject {
	
	var avatarUrl : String?
	var login: String?
	var name : String?
	var followersCount : NSInteger?
	var repoCount : NSInteger?
	var gistCount : NSInteger?

   init(dicitonary: [String : Any]){
	
		super.init()
		avatarUrl = dicitonary["avatar_url"] as? String
		name = dicitonary["name"] as? String
		followersCount = (dicitonary["followers"] as? NSInteger)
		repoCount = (dicitonary["public_repos"] as? NSInteger)
		gistCount = (dicitonary["public_repos"] as? NSInteger)
		login = dicitonary["login"] as? String
	}

}
