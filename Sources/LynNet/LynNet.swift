
import Foundation

public typealias NetworkCompletion<T> = (Result<T?, NetError>) -> Void



open class LynNet {
    
    /// ### 请求网络数据
    /// - Parameters:
    ///   - request: 请求模型
    ///   - completion: 回调
    /// - Returns: task
    @discardableResult
    public static func request(_ srcRequest: Requestable,
                               _ completion: @escaping  NetworkCompletion<Data>) -> URLSessionTask? {
        
        var request = srcRequest
        for plugin in request.requestPlugins {
            request = plugin.beforeRequest(srcRequest)
            if let result = plugin.terminate() {
                completion(result)
                return nil
            }
        }
        let internalRequest: InternalRequest = InternalRequest(baseUrl: request.baseUrl,
                                                               path: request.path,
                                                               method: request.method,
                                                               parameters: request.parameters,
                                                               headers: request.headers,
                                                               isStream: request.isStream,
                                                               ext: request.ext)
        guard let urlRequest = internalRequest.urlRequest else {
            let e = NetError(msg: "InternalRequest convert error!", code: .protocol)
            completion(.failure(e))
            return nil
        }
        
        URLSession.shared.configuration.httpAdditionalHeaders = request.headers
        let task: URLSessionTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let err = error {
                let e = NetError(msg: err.localizedDescription, code: .protocol)
                completion(.failure(e))
                return
            }
            var result: Result<Data?, NetError> = .success(data)
            for plugin in request.responsePlugins {
                result = plugin.afterResponse(internalRequest, result)
                if let r = plugin.terminate() {
                    completion(r)
                    return
                }
            }
            completion(result)
        }
        task.resume()
        return task
    }
    
}


extension Requestable {
    fileprivate var urlRequest: URLRequest? {
        get {
            guard let url = _url() else {
                return nil
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            if let httpHeaders = headers {
                for (key, val) in httpHeaders {
                    request.setValue(val, forHTTPHeaderField: key)
                }
            }
            if method == .get {
                // todo:
            }else if let param = parameters, let data = json2Data(param) {
                request.httpBody = data
            }
            return request
        }
    }
    
    private func json2Data(_ json: Dictionary<String,Any>) -> Data? {
        guard JSONSerialization.isValidJSONObject(json) else { return nil }
        let data = try? JSONSerialization.data(withJSONObject: json, options: [])
        return data
    }
    
    private func _url() -> URL? {
        let urlString = "\(baseUrl)\(path)"
        if method == .get {
            var components = URLComponents(string: urlString)
            components?.queryItems = parameters?.map({ (key, value) -> URLQueryItem in
                URLQueryItem(name: key, value: "\(value)")
            })
            return components?.url
        }
        return URL(string: urlString)
    }
    
}
