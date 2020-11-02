//
//  Error.swift
//  LynNet
//
//  Created by infiq on 2020/10/29.
//

public struct NetError: Error {
    public let msg: String
    public let code: ErrorCode
    public init(msg: String, code: ErrorCode = .default) {
        self.msg = msg
        self.code = code
    }
}

public enum ErrorCode {
    case `default`
    case `protocol`
    case decode
    case `nil`
}
