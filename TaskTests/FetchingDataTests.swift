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
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInternetConnection() {
        if !Utils.connectedToNetwork() {
            XCTFail("There's no internet connection")
            continueAfterFailure = false
        }
    }
    
    func testServiceConnection() {
        let expectation = self.expectation(description: "Server's HTTP response equals 200")
        let settings = Settings(apiKey: apiKey, endpoint: ArticleController.Endpoints.topHeadlines, itemsCount: 0, queries: [URLQueryItem(name: "country", value: "us")])
        ArticleController.downloadData(withSettings: settings) { data, response, error in
                                let statusCode = (response as! HTTPURLResponse).statusCode
                                XCTAssert(statusCode == 200, "Was: \(statusCode), expected: \(200)")
                                expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("Async test failed errored: \(error)")
            }
        }
    }
    
    func testFetchingData() {
        let headline = ArticleController.Endpoints.topHeadlines
        let everything = ArticleController.Endpoints.everything
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
    
    func fetchingData(_ endpoint: ArticleController.Endpoints, _ queries: [URLQueryItem], expectedPass: Bool, expectedHTTPCode: Int) {
        let expectation = self.expectation(description: "Number of downloaded data equals to 'itemsCount' parameter.")
        let testEndpoint = endpoint
        let itemsCount = 3
        let testqueries = queries
        let settings = Settings(apiKey: apiKey, endpoint: endpoint, itemsCount: itemsCount, queries: testqueries)
        continueAfterFailure = false
        
        ArticleController.downloadData(withSettings: settings) { data, response, error in
            guard let response = response else {
                XCTFail("Couldn't connect to the server. Check internet connection.")
                return
            }
            let statusCode = (response as! HTTPURLResponse).statusCode
            XCTAssert(statusCode == expectedHTTPCode, "Was: \(statusCode), expected: \(expectedHTTPCode)")
            guard let data = data else {
                if expectedPass {
                    XCTFail("Function has downloaded no data. Test data: \(testEndpoint), \(testqueries), \(expectedPass)")
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
