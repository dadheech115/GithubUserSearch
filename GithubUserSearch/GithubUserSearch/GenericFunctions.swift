//
//  AppDelegate.swift
//  GithubUserSearch
//
//  Created by Vikas Dadheech on 21/11/17.
//  Copyright © 2017 startrek. All rights reserved.
//


import UIKit
import Foundation

class GenericFunctions : NSObject {
	
    static let searchUrl = "https://api.github.com/search/users?q="
    static let userDetailFetchUrl = "https://api.github.com/users/"
	

    class func showAlert(title : String?, message : String?) {
        DispatchQueue.main.async(execute: {
            // update the view
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert);
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        })
    }
    
    class func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    class func getLocalFormatdate(dateString: String?)-> String? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        if let dateString = dateString, let date  = formatter.date(from: dateString)  {
            formatter.dateFormat = "d MMM''yy 'at' HH:mm"
            return formatter.string(from: date)
        }
        return nil
    }
}
