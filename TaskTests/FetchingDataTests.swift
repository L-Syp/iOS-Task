//
//  FetchingDataTests.swift
//  TaskTests
//
//  Created by Łukasz Sypniewski on 14/02/2018.
//  Copyright © 2018 Łukasz Sypniewski. All rights reserved.
//

import XCTest
import Foundation
@testable import Task

class TaskFetchingTests: XCTestCase {
    
    let apiKey = "2beb5953fd92424983abae1dc1c7d58c"
    var mockIsOnline = false
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInternetConnection() {
        if !RestCall.connectedToNetwork(&mockIsOnline) {
            XCTFail("There's no internet connection")
            continueAfterFailure = false
        }
    }
    
    func testServiceConnection() {
        let expectation = self.expectation(description: "Server's HTTP response equals 200")
        RestCall.makeGetCall(endpoint: RestCall.Endpoints.topHeadlines, itemsCount: 0, additionalQueries: [URLQueryItem(name: "country", value: "us")],
                             apiKey: apiKey) { data, response, error in
                                XCTAssert((response as! HTTPURLResponse).statusCode == 200)
                                expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("Async test failed errored: \(error)")
            }
        }
    }
    
    func testFetchingData() {
        let headline = RestCall.Endpoints.topHeadlines
        let everything = RestCall.Endpoints.everything
        let testData = [
           (headline, [URLQueryItem(name: "country", value: "us")], true, 200),
           (everything, [URLQueryItem(name: "q", value: "business")], true, 200),
           (headline, [URLQueryItem(name: "q", value: "business")], true, 200),
           (everything, [URLQueryItem(name: "country", value: "us")], false, 400),
           (headline, [URLQueryItem(name: "invalidValue", value: "us")], false, 400),
           (everything, [URLQueryItem(name: "invalidValue", value: "us")], false, 400)
        ]
        testData.forEach( {
            fetchingData($0, $1, expectedPass: $2, expectedHTTPCode: $3)
        })
    }
    
    func fetchingData(_ endpoint: RestCall.Endpoints, _ additionalQueries: [URLQueryItem], expectedPass: Bool, expectedHTTPCode: Int) {
        let expectation = self.expectation(description: "Number of downloaded data equals to 'itemsCount' parameter.")
        let testEndpoint = endpoint
        let itemsCount = 3
        let testAdditionalQueries = additionalQueries
        continueAfterFailure = false
        
        RestCall.makeGetCall(endpoint: testEndpoint, itemsCount: itemsCount, additionalQueries: testAdditionalQueries, apiKey: apiKey) { data, response, error in
            guard let response = response else {
                XCTFail("Couldn't connect to the server. Check internet connection.")
                return
            }
            let statusCode = (response as! HTTPURLResponse).statusCode
            XCTAssert(statusCode == expectedHTTPCode, "Was: \(statusCode), expected: \(expectedHTTPCode)")
            guard let data = data else {
                if expectedPass {
                    XCTFail("Function has downloaded no data. Test data: \(endpoint), \(additionalQueries), \(expectedPass)")
                } else {
                    expectation.fulfill()
                }
                return
            }
            
            
            if expectedPass {
                let dataCount = data.articles.count
                XCTAssert(dataCount == itemsCount, "Was: \(dataCount), expected: \(itemsCount)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("Async test failed errored: \(error)")
            }
        }
    }
}
