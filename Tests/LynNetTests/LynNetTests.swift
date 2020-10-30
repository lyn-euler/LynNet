import XCTest
@testable import LynNet


/// ⚠️NOTE: you must run a node server before testing
/// ```shell
/// # file path at 'Tests/server'
/// node server.js
///```
final class LynNetTests: XCTestCase {
    func testGet() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
//        XCTAssertEqual(LynNet().text, "Hello, World!")
        let exp = self.expectation(description: "test get")
        LynNet.request(GetTestRequest()) { (result) in
            if case .success(_) = result {
                exp.fulfill()
            }else if case let .failure(error) = result {
                print(error.msg)
            }else {
                XCTAssert(false, "error!")
            }
        }
        
        self.waitForExpectations(timeout: 10) { (error) in
            guard let _ = error else {
                return
            }
            print("timeout error!!!")
        }
    }
    
    func testPost() {
        let exp = self.expectation(description: "test post")
        LynNet.request(PostTestRequest()) { (result) in
            if case .success(_) = result {
                exp.fulfill()
            }else if case let .failure(error) = result {
                print(error.msg)
            }else {
                XCTAssert(false, "error!")
            }
        }
        
        self.waitForExpectations(timeout: 10) { (error) in
            guard let _ = error else {
                return
            }
            print("timeout error!!!")
        }
    }

    static var allTests = [
        ("testGet", testGet),
        ("testPost", testPost),
    ]
}

