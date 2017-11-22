//
//  AppDelegate.swift
//  GithubUserSearch
//
//  Created by Vikas Dadheech on 21/11/17.
//  Copyright © 2017 startrek. All rights reserved.
//


import UIKit


class UserDetailViewController: UIViewController {
	
    @IBOutlet weak var imageViewUserPic: UIImageView?
    @IBOutlet weak var labelUserName: UILabel?
	
    @IBOutlet weak var labelUserPublicRepoCount: UILabel?
    @IBOutlet weak var labelUserPublicGistCount: UILabel?
    @IBOutlet weak var labelUserFollowersCount: UILabel?
	
	
	
    
    var userInformation : User?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupNavigationElements()
		if let username = userInformation?.login {
			fetchDataFromUrl(urlString: GenericFunctions.userDetailFetchUrl + username)
		}
		else {
			setupViewWithValues()
		}
		imageViewUserPic?.image = UIImage.init(imageLiteralResourceName: "Octocat.png")
		imageViewUserPic?.layer.cornerRadius = 5.0
		imageViewUserPic?.layer.borderColor = UIColor.black.cgColor
		imageViewUserPic?.layer.borderWidth = 2.0
		imageViewUserPic?.clipsToBounds = true
	}
	
	func fetchDataFromUrl(urlString : String?) {
		
		if let urlString = urlString, urlString.isEmpty == false {
			
			if let Url = URL(string:urlString) {
				
				GenericFunctions.getDataFromUrl(url: Url) { data, response, error in
					guard let data = data, error == nil else {
						GenericFunctions.showAlert(title: "Error", message: error?.localizedDescription)
						return
					}
						let jsonData = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
						if let records = jsonData, records.isEmpty == true {
							GenericFunctions.showAlert(title: "Error", message: "No records")
						}
						else {
							self.userInformation = User.init(dicitonary: jsonData!)
							DispatchQueue.main.async {
								self.setupViewWithValues()
							}
						}
					
				}
			}
		}
		else {
			
		}
	}
	
	func setupNavigationElements() {
		
		navigationController?.navigationBar.isTranslucent = false
		navigationItem.title = userInformation?.name
		
	}
    
    func setupViewWithValues() {
		
		if let publicRepoCount = userInformation?.repoCount {
			labelUserPublicRepoCount?.text = String(describing: publicRepoCount)
		}
		
		if let followersCount = userInformation?.followersCount {
			labelUserFollowersCount?.text = String(describing: followersCount)
		}
		
		if let avatarUrl = userInformation?.avatarUrl, let profilePicURL = URL(string: avatarUrl) {
			imageViewUserPic?.contentMode = .scaleAspectFill
			loadImageFromURL(url: profilePicURL)
		}
        
		if let name = userInformation?.name {
            labelUserName?.text = name
        }

        if let publicGistsCount = userInformation?.gistCount {
            labelUserPublicGistCount?.text = String(describing: publicGistsCount)
        }
        
		
    }
	
    func loadImageFromURL(url: URL) {

        if let image = imageViewUserPic {
            
            GenericFunctions.getDataFromUrl(url: url) { data, response, error in
                defer {
                    DispatchQueue.main.async() {
                    }
                }
                guard let data = data, error == nil else {
                    return
                }

                DispatchQueue.main.async() {
                    self.imageViewUserPic?.image = UIImage(data: data)
                }
            }
        }
    }

}
