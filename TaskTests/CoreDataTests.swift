//
//  CoreDataTests.swift
//  TaskTests
//
//  Created by Łukasz Sypniewski on 21/02/2018.
//  Copyright © 2018 Łukasz Sypniewski. All rights reserved.
//

import XCTest
import Foundation
@testable import Task

class CoreDataTests: XCTestCase {
    var articles = [ArticleClass]()
    let numberOfArticlesToAdd = 5
    
    override func setUp() {
        super.setUp()
        articles = [ArticleClass]()
        DataPersistence.persistDeleteData(&articles)
        let entitiesCount = DataPersistence.getEntitiesCount()
        XCTAssert(entitiesCount == 0, "Was: \(entitiesCount), expected: \(0)")
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        DataPersistence.persistDeleteData(&articles)
    }
    
    func testSavingData() {
        for _ in 0..<numberOfArticlesToAdd { DataPersistence.persistSaveArticle(ArticleClass(), imageData: nil)}
        let entitiesCount = DataPersistence.getEntitiesCount()
        XCTAssert(entitiesCount == numberOfArticlesToAdd, "Was: \(entitiesCount), expected: \(numberOfArticlesToAdd)")
    }
    
    func testLoadingData() {
        testSavingData()
        DataPersistence.persistLoadAtricle(&articles)
        XCTAssert(articles.count == numberOfArticlesToAdd, "Was: \(articles.count), expected: \(numberOfArticlesToAdd)")
    }
    
    func testDeletingData() {
        testLoadingData()
        DataPersistence.persistDeleteData(&articles)
        let entitiesCount = DataPersistence.getEntitiesCount()
        XCTAssert(entitiesCount == 0, "Was: \(entitiesCount), expected: \(0)")
    }
}
