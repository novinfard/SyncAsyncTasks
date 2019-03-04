//
//  ViewController.swift
//  SyncAsyncTasks
//
//  Created by Soheil Novinfard on 04/03/2019.
//  Copyright © 2019 Soheil Novinfard. All rights reserved.
//

import UIKit
import Promises

class ViewController: UIViewController {
    
    let baseUrl = "https://jsonplaceholder.typicode.com/"
    let endpoints = ["posts", "comments", "albums", "photos", "todos", "users"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.promiseSolution()
    }
    
    // MARK: - Dispatch Group
    
    func dispatchGroupSolution() {
        let group = DispatchGroup()
        endpoints.forEach { endpoint in
            group.enter()
            performNetworkRequest(url: baseUrl + endpoint) { data, error in
                print("Task \(endpoint) is done")
                group.leave()
            }
        }
        
        // notify the main thread when all task are completed
        group.notify(queue: .main) {
            print("All Tasks are done")
        }
    }
    
    // MARK: - Google Promises
    
    func performNetworkPromise(url: String) -> Promise<Data>{
        let promise =  Promise<Data>.pending()
        
        performNetworkRequest(url: url) { (data, error) in
            guard let data = data else { return }
            promise.fulfill(data)
        }
        
        return promise
    }
    
    func promiseSolution() {
        let networkPromises = endpoints.map {
            performNetworkPromise(url: baseUrl + $0)
        }
        
        all(networkPromises).then { dataArray in
            print("All Tasks are done")
        }
    }
    
    // MARK: - General

    func performNetworkRequest(url: String,
                               completion: @escaping (Data?, Error?) -> Void) {
        // create a url
        let requestUrl = URL(string: url)
        
        // create a data task
        let task = URLSession.shared.dataTask(with: requestUrl!) { (data, response, error) in
            completion(data, error)
        }
        task.resume()
    }

}

