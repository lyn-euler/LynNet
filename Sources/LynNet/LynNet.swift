
import Foundation

public typealias LynNetResult = ResultModel<[String: Any]>
public typealias NetworkCompletion = (LynNetResult) -> Void

public struct ResultModel<T> {
    public let reserve: T?
    public let result: Result<Data?, NetError>
    public init(_ result: Result<Data?, NetError>, reserve: Any? = nil) {
        self.result = result
        self.reserve = reserve as? T
    }
}



public protocol Cancelable {
    func cancel()
}

private class NetTask: Cancelable {
    func cancel() {
        guard let t = task else { return  }
        t.cancel()
    }
    
    var task: URLSessionTask?
}

open class LynNet {
    
    /// 请求网络数据
    /// - Parameters:
    ///   - srcRequest: 请求模型
    ///   - completion: 回调
    /// - Returns: NetTask
    @discardableResult
    public static func asyncRequest(_ srcRequest: Requestable,
                                    _ completion: @escaping NetworkCompletion) -> Cancelable {
        let task = NetTask()
        DispatchQueue.global(qos: .default).async {
            if let netTask = request(srcRequest, completion) as? NetTask {
                task.task = netTask.task
            }
        }
        return task
    }
    
    /// ### 请求网络数据
    /// - Parameters:
    ///   - request: 请求模型
    ///   - completion: 回调
    /// - Returns: NetTask
    @discardableResult
    public static func request(_ srcRequest: Requestable,
                               _ completion: @escaping  NetworkCompletion) -> Cancelable {
        let cancelable = NetTask()
        var request = srcRequest
        for plugin in request.requestPlugins {
            request = plugin.beforeRequest(srcRequest)
            let r = plugin.terminate()
            if r.0 {
                if let result = r.1 {
                    completion(result)
                }
                return cancelable
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
            let e = NetError(msg: "[LynNet]::InternalRequest convert error!", code: .protocol)
            completion(LynNetResult(.failure(e)))
            return cancelable
        }

        URLSession.shared.configuration.httpAdditionalHeaders = request.headers
        let task: URLSessionTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            var result: LynNetResult
            if let err = error {
                let e = NetError(msg: err.localizedDescription, code: .protocol)
                result = LynNetResult(.failure(e))
            }else {
                let r: Result<Data?, NetError> = .success(data)
                result = LynNetResult(r)
            }
            
            for plugin in request.responsePlugins {
                result = plugin.afterResponse(internalRequest, result)
                let r = plugin.terminate()
                if r.0 {
                    if let result = r.1 {
                        completion(result)
                    }
                    return
                }
            }
            completion(result)
        }
        cancelable.task = task
        task.resume()
        return cancelable
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
