//
//  Star3DIndexTests.swift
//  SwiftyHYGDB_Tests
//
//  Created by Konrad Feiler on 08.02.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
@testable import SwiftyHYGDB

class Star3DIndexTests: XCTestCase {
    
    var originalDBPath: String {
        if let originalDBPath = Bundle.main.path(forResource: "hygdata_v3", ofType:  "csv") { return originalDBPath }
        return String.getOriginalRepositoryPath()! + "/Example/SwiftyHYGDB/hygdata_v3.csv"
    }
    lazy var originalStar3Ds: [Star3D]? = {
        return SwiftyHYGDB.loadCSVData(from: originalDBPath, precess: true)
    }()
    
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testVega() {
        guard let vega = originalStar3Ds?.first(where: { $0.dbID == 90979 }) else {
            XCTFail("Database should have an entry for vega, id 90979")
            return
        }
        guard let starData = vega.starData?.value else { XCTFail("Failed to get stardata"); return }
        
        XCTAssertEqual(starData.getProperName(), "Vega")
        XCTAssertEqual(starData.getBayerFlamstedt(), "3Alp Lyr")
        XCTAssertEqual(starData.getGlId(), "Gl 721")
        XCTAssertEqual(starData.getSpectralType(), "A0Vvar")
    }

    func testAltair() {
        guard let vega = originalStar3Ds?.first(where: { $0.dbID == 97338 }) else {
            XCTFail("Database should have an entry for vega, id 90979")
            return
        }
        guard let starData = vega.starData?.value else { XCTFail("Failed to get stardata"); return }
        
        XCTAssertEqual(starData.getProperName(), "Altair")
        XCTAssertEqual(starData.getBayerFlamstedt(), "53Alp Aql")
        XCTAssertEqual(starData.getGlId(), "Gl 768")
        XCTAssertEqual(starData.getSpectralType(), "A7IV-V")
    }

    func testUnnamedStar() {
        guard let vega = originalStar3Ds?.first(where: { $0.dbID == 35244 }) else {
            XCTFail("Database should have an entry for vega, id 35244")
            return
        }
        guard let starData = vega.starData?.value else { XCTFail("Failed to get stardata"); return }
        
        XCTAssertEqual(starData.getProperName(), nil)
        XCTAssertEqual(starData.getBayerFlamstedt(), "64    Aur")
        XCTAssertEqual(starData.getGlId(), nil)
        XCTAssertEqual(starData.getSpectralType(), "A5Vn")
    }
    
}
