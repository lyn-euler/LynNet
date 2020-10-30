//
//  TestRequest.swift
//  LynNet_Tests
//
//  Created by infiq on 2020/10/30.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

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
