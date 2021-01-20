//
//  Error.swift
//  LynNet
//
//  Created by infiq on 2020/10/29.
//

public struct NetError: Error {
    public let msg: String
    public let code: ErrorCode
    
    /// 扩展字段, 额外信息
    public let ext: Any?
    
    public init(msg: String, code: ErrorCode = .default, ext: Any? = nil) {
        self.msg = msg
        self.code = code
        self.ext = ext
    }
}

public enum ErrorCode {
    case `default`
    case `protocol`
    case decode
    case `nil`
}
