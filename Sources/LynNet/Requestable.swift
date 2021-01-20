//
//  Requestable.swift
//  LynNet
//
//  Created by infiq on 2020/10/29.
//

import Foundation

public protocol Requestable: PluginParameters {
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

public protocol PluginParameters {
    /// extension info for plugins.
    /// For example, you can set cache enable flag to open/close cache in ResponsePlugin.
    var ext: [String: Any]? { get }
    
}

public protocol Terminatable {
    
    /// 终止请求 (是否终止、结果--如果有则执行回调,nil则不执行回调)
    func terminate() -> (Bool, LynNetResult?)
}

public extension Terminatable {
    func terminate() -> (Bool, LynNetResult?) { (false, nil) }
}

public protocol RequestPlugin: Terminatable {
    func beforeRequest(_ request: Requestable) -> Requestable
}


public protocol ResponsePlugin: Terminatable {
    func afterResponse(_ request: Requestable, _ result: LynNetResult) -> LynNetResult
}


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
    var ext: [String: Any]? { nil }
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
            let paramString = (noQuery ? "?" : "&") + (parameters?.toQuery ?? "")
            let urlString = "\(baseUrl)\(path)\(paramString)"
            if let url = URL(string: urlString) {
                request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeout)
            }
        }else {
            request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeout)
            if let query = parameters?.toQuery, let data = query.data(using: .utf8) {//, let data = json2Data(param)
                
//                if self.isStream {
//                    request?.httpBodyStream = InputStream(data: data)
//                }else {
                
                request?.httpBody = data
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
    
    var ext: [String : Any]?
    
}

extension InternalRequest {
    private func json2Data(_ json: Dictionary<String,Any>) -> Data? {
        guard JSONSerialization.isValidJSONObject(json) else { return nil }
        let data = try? JSONSerialization.data(withJSONObject: json, options: [])
        return data
    }
}


extension String {
    func urlEncode() -> Self {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
}

extension Dictionary where Key == String {
    var toQuery: String {
        var andSymbol = ""
        return self.reduce("", { (result, arg1) -> String in
            defer {
                andSymbol = "&"
            }
            let (key, value) = arg1
            let item = "\(key)=" + "\(value)".urlEncode()
            return "\(result)\(andSymbol)\(item)"
        })
    }
}
