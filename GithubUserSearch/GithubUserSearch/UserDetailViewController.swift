//
//  AppDelegate.swift
//  GithubUserSearch
//
//  Created by Vikas Dadheech on 21/11/17.
//  Copyright © 2017 startrek. All rights reserved.
//


import UIKit
import CoreData
import SafariServices


class UserDetailViewController: UIViewController {
	
    @IBOutlet weak var imageViewUserPic: UIImageView?
    @IBOutlet weak var labelUserName: UILabel?
	
    @IBOutlet weak var labelUserPublicRepoCount: UILabel?
    @IBOutlet weak var labelUserPublicGistCount: UILabel?
    @IBOutlet weak var labelUserFollowersCount: UILabel?
	
	@IBOutlet weak var labelCompany: UILabel!
	
	@IBOutlet weak var labelLocation: UILabel!
	@IBOutlet weak var labelCreatedDate: UILabel!
	@IBOutlet weak var labelUpdatedDate: UILabel!
	
    
    var userInformation : NSManagedObject?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupNavigationElements()
		if let username = userInformation?.value(forKeyPath: "login") as? String {
			if Reachability.isConnectedToNetwork() == true{
			fetchDataFromUrl(urlString: GenericFunctions.userDetailFetchUrl + username)
			}else{
				userInformation = DBManager.getUserDetail(searchKey: username)
				setupViewWithValues()
			}
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
							let user = User.init(dicitonary: jsonData!)
							DBManager.updateUser(user: user)
							self.userInformation = DBManager.getUserDetail(searchKey: user.login!)
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
		navigationItem.title = userInformation?.value(forKeyPath: "login") as? String
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(shareTapped))
		
	}
    
    func setupViewWithValues() {
		
		if let publicRepoCount = userInformation?.value(forKeyPath: "repoCount") {
			labelUserPublicRepoCount?.text = String(describing: publicRepoCount)
		}
		
		if let followersCount = userInformation?.value(forKeyPath: "followersCount") {
			labelUserFollowersCount?.text = String(describing: followersCount)
		}
		
		if let avatarUrl = userInformation?.value(forKeyPath: "avatarUrl"), let profilePicURL = URL(string: avatarUrl as! String) {
			imageViewUserPic?.contentMode = .scaleAspectFill
			loadImageFromURL(url: profilePicURL)
		}
        
		if let name = userInformation?.value(forKeyPath: "name") {
			labelUserName?.text = name as? String
        }

        if let publicGistsCount = userInformation?.value(forKeyPath: "gistCount") {
            labelUserPublicGistCount?.text = String(describing: publicGistsCount)
        }
		
		if let company = userInformation?.value(forKeyPath: "company") as? String {
			labelCompany?.text =  "Company  \n" + company
		}else{
			labelCompany?.text =  "Company  --"
		}
		
		if let location = userInformation?.value(forKeyPath: "location") as? String{
			labelLocation?.text = "Location  \n" + location
		}else{
			labelLocation?.text = "Location  --"
		}
		
		if let creationDate = userInformation?.value(forKeyPath: "creationDate") as? String {
			labelCreatedDate?.text = "Creation  \n" + (getFormatedDate(dateString: creationDate) ?? "--")
		}else{
			labelCreatedDate?.text = "Creation  --"
		}
		
		if let updatedDate = userInformation?.value(forKeyPath: "updatedDate") as? String {
			labelUpdatedDate?.text = "Last update  \n" + (getFormatedDate(dateString: updatedDate)  ?? "--")
		}else{
			labelUpdatedDate?.text = "Last update --"
		}
        
		
    }
	
	func getFormatedDate(dateString: String?)-> String? {
		
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
		if let dateString = dateString, let date  = formatter.date(from: dateString)  {
			formatter.dateFormat = "dd MMM, yy"
			return formatter.string(from: date)
		}
		return nil
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

	@objc func shareTapped(sender : UIButton) {
		if let htmlUrl = userInformation?.value(forKeyPath: "htmlUrl") as? String  {
			
			let activityVC = UIActivityViewController(activityItems: [htmlUrl], applicationActivities: nil)
			
			activityVC.popoverPresentationController?.sourceView = sender
			self.present(activityVC, animated: true, completion: nil)
		}
	}

}

extension UserDetailViewController :SFSafariViewControllerDelegate{
}
