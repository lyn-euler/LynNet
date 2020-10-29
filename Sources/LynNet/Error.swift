//
//  Error.swift
//  LynNet
//
//  Created by infiq on 2020/10/29.
//

public struct NetError: Error {
    let msg: String
    let code: ErrorCode
}

public enum ErrorCode {
    case `default`
    case `protocol`
    case decode
    case `nil`
}
