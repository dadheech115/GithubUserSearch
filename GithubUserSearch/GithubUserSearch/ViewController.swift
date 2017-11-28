//
//  AppDelegate.swift
//  GithubUserSearch
//
//  Created by Vikas Dadheech on 21/11/17.
//  Copyright © 2017 startrek. All rights reserved.
//


import UIKit
import CoreData

class ViewController: UIViewController {
	
	@IBOutlet weak var tableViewResults: UITableView?
	@IBOutlet weak var searchBar: UISearchBar?
	
	
	var searchKeyword : String?
	var arrayResults : Array<NSManagedObject>?
	var totalResult  : Int?
	var currentPageIndex : Int = 0
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		arrayResults = Array.init()
		tableViewResults?.delegate = self
		tableViewResults?.dataSource = self
		tableViewResults?.tableFooterView = UIView()
		
		searchBar?.delegate = self
		searchBar?.showsCancelButton = false
		searchBar?.placeholder = "Enter username to search"
		
		navigationController?.navigationBar.isTranslucent = false
		navigationItem.title = "Search"
	}
	
	@objc func dismissKeyboard()
	{
		self.view.endEditing(true)
	}
	
	
	func searchUsersFor(searchedString: String?, pageCount : String?) {
		
		if Reachability.isConnectedToNetwork() == true{
		
		if let searchedString = searchedString, searchedString.isEmpty == false {
			
			var urlString = GenericFunctions.searchUrl
			let queryItems = [URLQueryItem(name: "q", value: searchedString), URLQueryItem(name: "page", value: pageCount)]
			var searchUrl = URLComponents(string: GenericFunctions.searchUrl)
			searchUrl?.queryItems = queryItems
			
			if let Url = searchUrl?.url {
				let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
				indicator.center = view.center
				view.addSubview(indicator)
				indicator.startAnimating()
				
				GenericFunctions.getDataFromUrl(url: Url) { data, response, error in
					defer {
						DispatchQueue.main.async {
							indicator.stopAnimating()
						}
					}
					guard let data = data, error == nil else {
						GenericFunctions.showAlert(title: "Error", message: error?.localizedDescription)
						return
					}
					let jsonData = try! JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable : Any]
					if let json = jsonData, let records = json["items"] as? [[String : Any]], records.isEmpty == true {
						self.currentPageIndex = 1
						GenericFunctions.showAlert(title: "Error", message: "No users")
					}
					else {
						if let json = jsonData, let users = json["items"] as? [[String : Any]]  {
							if self.currentPageIndex==1{
								self.arrayResults?.removeAll()
								self.tableViewResults?.reloadData()
							}
							
							for userInformation in users {
								let user = User.init(dicitonary: userInformation )
								DBManager.addUser(user: user)
								self.arrayResults?.append(DBManager.getUserDetail(searchKey: user.login!)!)
							}
							
							if let totalCount = json["total_count"] as? Int {
								self.totalResult = totalCount
							}
							
							if searchedString == self.searchKeyword && self.totalResult == json["total_count"] as? Int {
								self.currentPageIndex = self.currentPageIndex + 1
							}
							
							DispatchQueue.main.async {
								self.tableViewResults?.reloadData()
							}
						}
						else {
							if let json = jsonData, let message = json["message"] as? String, message.isEmpty == false {
								GenericFunctions.showAlert(title: "Error", message: message)
							}
						}
					}
				}
			}
		}
		else {
			
			self.tableViewResults?.reloadData()
		}
		}else{
			let userInformationFromDb = DBManager.getUsers(searchKey: searchedString!)
			self.arrayResults = userInformationFromDb
			self.tableViewResults?.reloadData()
			print("from DB")
		}
	}
}

extension ViewController : UISearchBarDelegate {
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		arrayResults?.removeAll()
		tableViewResults?.reloadData()
		searchKeyword = searchBar.text
		currentPageIndex = 1
		searchUsersFor(searchedString: searchKeyword, pageCount: String(currentPageIndex))
	}
}


extension ViewController : UITableViewDelegate,UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (arrayResults?.count)!
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "profileInfo")
		
		if let cell = cell {
			var user:NSManagedObject = arrayResults![indexPath.row]
			cell.textLabel?.text = user.value(forKeyPath: "login") as? String
			cell.imageView?.image = UIImage.init(imageLiteralResourceName:"Octocat.png")
			if let image = cell.imageView {
				if let avatarUrl = user.value(forKeyPath: "avatarUrl"), let profilePicURL = URL(string: avatarUrl as! String) {
					GenericFunctions.getDataFromUrl(url: URL(string: (user.value(forKeyPath: "avatarUrl") as? String)!)!) { data, response, error in
						defer {
							DispatchQueue.main.async() {
							}
						}
						guard let data = data, error == nil else {
							return
						}
						
						DispatchQueue.main.async() {
							cell.imageView?.image = UIImage(data: data)
							//						cell.layoutSubviews()
							//						self.tableViewResults?.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
						}
					}
			}
				

			}
			return cell
		}
		else {
			return UITableViewCell()
		}
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		
		if let totalRecords = totalResult, indexPath.row == tableView.numberOfRows(inSection: 0) - 1 && (arrayResults?.count)! < totalRecords
		{
			searchUsersFor(searchedString: searchKeyword, pageCount: String(currentPageIndex))
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 50
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		if let userDetailViewController = storyboard?.instantiateViewController(withIdentifier: "UserDetailViewController") as? UserDetailViewController {
			userDetailViewController.userInformation = arrayResults?[indexPath.row]
			self.navigationController?.pushViewController(userDetailViewController, animated:true)
		}
	}
}
