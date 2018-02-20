//
//  TaskTests.swift
//  TaskTests
//
//  Created by Łukasz Sypniewski on 14/02/2018.
//  Copyright © 2018 Łukasz Sypniewski. All rights reserved.
//

import XCTest
import Foundation
@testable import Task

class TaskTests: XCTestCase {
    
    let apiKey = "2beb5953fd92424983abae1dc1c7d58c"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInternetConnection() {
        if !RestCall.connectedToNetwork() { 
            XCTFail("There's no internet connection")
            continueAfterFailure = false
        }
    }
    
    func testServiceConnection() {
        let expectation = self.expectation(description: "Server's HTTP response equals 200")
        RestCall.makeGetCall(endpoint: RestCall.Endpoints.topHeadlines, itemsCount: 0, additionalQueries: [URLQueryItem(name: "country", value: "us")],
                             apiKey: apiKey) { data, response in
                                XCTAssert((response as! HTTPURLResponse).statusCode == 200)
                                expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("Async test failed errored: \(error)")
            }
        }
    }
    
}
