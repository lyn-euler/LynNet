//
//  ViewController.swift
//  LynNet
//
//  Created by lyn-euler on 10/30/2020.
//  Copyright (c) 2020 lyn-euler. All rights reserved.
//

import UIKit
import LynNet

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        LynNet.request(GetRequest()) { result in
//            
//        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

struct GetRequest: Requestable {
    var baseUrl: String = "https://localhost:3000"
    
    var path: String = "/get"
    
    var method: HttpMethod = .get
    
    var parameters: Dictionary<String, Any>?
    
    var headers: Dictionary<String, String>?
    
    var requestPlugins: [RequestPlugin] = []
    
    var responsePlugins: [ResponsePlugin] = []
    
    var timeout: TimeInterval = 10
    
    var isStream: Bool = false
    
    
}
