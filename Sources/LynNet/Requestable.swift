//
//  Requestable.swift
//  LynNet
//
//  Created by infiq on 2020/10/29.
//

import Foundation

public protocol Requestable {
    var baseUrl: String { get }
    var path: String { get }
    var method: HttpMethod { get }
    var parameters: Dictionary<String, Any>? { get }
    var headers: Dictionary<String, String>? { get }
    var requestPlugins: [RequestPlugin] { get }
    var responsePlugins: [ResponsePlugin] { get }
    var timeout: TimeInterval { get }
    var isStream: Bool { get }
}

public protocol RequestPlugin {
    func beforeRequest(_ request: Requestable) -> Requestable
    
}

public protocol ResponsePlugin {
     func afterResponse(_ result: Result<Data?, NetError>) -> Result<Data?, NetError>
}

//protocol DataDecoder {
//    func decode<T>(_ data: Data?) throws -> Result<T?, NetError>
//}

public enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case update = "UPDATE"
    case delete = "DELETE"
}



public extension Requestable {
    var timeout: TimeInterval { 10 * 1000 }
    var isStream: Bool { false }
}

protocol InternalRequestable: Requestable {
    var urlRequest: URLRequest? { get }
    
}

struct InternalRequest: InternalRequestable {
    
    var urlRequest: URLRequest? {
        guard let url = URL(string: "\(baseUrl)\(path)") else {
            return nil
        }
        var request: URLRequest?
        if method == .get {
            let noQuery = url.query == nil
            let paramString = parameters?.reduce( noQuery ? "?" : "", { (result, arg1) -> String in
                let (key, value) = arg1
                let item = "\(key)=" + "\(value)"
                return "\(result)\(item)&"
            }) ?? ""
            let urlString = "\(baseUrl)\(path)\(paramString)"
            if let url = URL(string: urlString) {
                request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeout)
            }
        }else {
            request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeout)
            if let param = parameters, let data = json2Data(param) {
//                if self.isStream {
                    request?.httpBodyStream = InputStream(data: data)
//                }else {
//                request?.httpBody = data
//                }
            }
        }
        if let httpHeaderFields = headers {
            for (key, val) in httpHeaderFields {
                request?.addValue(val, forHTTPHeaderField: key)
            }
        }
        request?.httpMethod = method.rawValue
        return request
    }
    
    let baseUrl: String
    
    let path: String
    
    let method: HttpMethod
    
    let parameters: Dictionary<String, Any>?
    
    let headers: Dictionary<String, String>?
    
    var requestPlugins: [RequestPlugin] { [] }
    
    var responsePlugins: [ResponsePlugin] { [] }
    
    let isStream: Bool
    
}

extension InternalRequest {
    private func json2Data(_ json: Dictionary<String,Any>) -> Data? {
        guard JSONSerialization.isValidJSONObject(json) else { return nil }
        let data = try? JSONSerialization.data(withJSONObject: json, options: [])
        return data
    }
}


