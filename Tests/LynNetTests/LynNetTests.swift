import XCTest
@testable import LynNet

final class LynNetTests: XCTestCase {
    func testGet() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
//        XCTAssertEqual(LynNet().text, "Hello, World!")
        let exp = self.expectation(description: "test get")
        LynNet.request(TestGetRequest()) { (result) in
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
    ]
}

struct TestGetRequest: Requestable {
    
    let baseUrl: String = "http://rap2api.taobao.org"
    
    let path: String = "/app/mock/269543/test/get"
    
    let method: HttpMethod = .get
    
    var parameters: Dictionary<String, Any>? = ["test": "testtttt"]
    
    var headers: Dictionary<String, String>?
    
    var requestPlugins: [RequestPlugin] = []
    
    var responsePlugins: [ResponsePlugin] = [ToStringPlugin()]
    
    
}


struct ToStringPlugin: ResponsePlugin {
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
