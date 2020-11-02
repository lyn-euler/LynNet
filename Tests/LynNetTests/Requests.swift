//
//  GetRequest.swift
//  LynNet_Tests
//
//  Created by infiq on 2020/10/30.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import LynNet


struct GetTestRequest: TestRequest {
    
    let path: String = "get"
    
    let method: HttpMethod = .get
    
    var parameters: Dictionary<String, Any>? = ["test": "this is a get request!", "aa": 111]
    
}


struct PostTestRequest: TestRequest {
    
    let path: String = "post"
    
    let method: HttpMethod = .post
    
    var parameters: Dictionary<String, Any>? = ["message": "this is a post request!"]

}
