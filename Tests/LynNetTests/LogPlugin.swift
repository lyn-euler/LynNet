//
//  LogPlugin.swift
//  LynNet_Tests
//
//  Created by infiq on 2020/10/30.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import LynNet

struct LogPlugin: ResponsePlugin {
    func afterResponse(_ result: Result<Data?, NetError>) -> Result<Data?, NetError> {
        if case let .success(data) = result {
            guard let d = data else {
                return result
            }
            let string = String(data: d, encoding: .utf8)
            print("======start=========")
            print(string ?? "")
            print("======end=========")
        }
        return result
    }
    
    
}
