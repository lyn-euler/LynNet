//
//  GetRequest.swift
//  LynNet_Tests
//
//  Created by infiq on 2020/10/30.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import LynNet

protocol TestRequest: Requestable {
    
}

extension TestRequest {
    var baseUrl: String {
        "http://localhost:3000/"
    }
    var method: HttpMethod {
        .get
    }
    
    var requestPlugins: [RequestPlugin] {
        []
    }
    
    var headers: Dictionary<String, String>? {
        ["content-type": "application/json"]
    }
    
    var responsePlugins: [ResponsePlugin] {
        [LogPlugin()]
    }
}


struct GetTestRequest: TestRequest {
    
    let path: String = "get"
    
    let method: HttpMethod = .get
    
    var parameters: Dictionary<String, Any>? = ["test": "this is a get request!"]
    
//    var headers: Dictionary<String, String>?

    
}


struct PostTestRequest: TestRequest {
    
    let path: String = "post"
    
    let method: HttpMethod = .post
    
    var parameters: Dictionary<String, Any>? = ["message": "this is a post request!"]
    
//    var headers: Dictionary<String, String>?

    
}
