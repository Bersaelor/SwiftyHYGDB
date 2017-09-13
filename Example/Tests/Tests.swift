import UIKit
import XCTest
import SwiftyHYGDB

class Tests: XCTestCase {
    let allStarFileName = "allStars.csv"
    let starsCountInCSV = 119614

    override func setUp() {
        super.setUp()

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func no_test_01_SaveStars() {
        let filePath = Bundle.main.path(forResource: "hygdata_v3", ofType:  "csv")
        XCTAssertNotNil(filePath, "Excpected hygdata_v3 to be bundled")
        
        let startLoading = Date()
        let stars = SwiftyHYGDB.loadCSVData(from: filePath!)
        print("Time to load \(stars?.count ?? 0) stars: \(Date().timeIntervalSince(startLoading))s from \(filePath!)")
        XCTAssertNotNil(stars, "Excpected hygdata_v3 to not be empty")
        XCTAssertEqual(stars?.count, starsCountInCSV, "Excpected hygdata_v3 to have \(starsCountInCSV) stars")
        
        self.saveStars(stars: stars, fileName: allStarFileName)
    }
    
    func test_02_ReloadStars() {
        let reloadedStars = self.loadStars(fileName: allStarFileName)
        XCTAssertEqual(reloadedStars?.count, starsCountInCSV, "Expected \(allStarFileName) to have \(starsCountInCSV) stars too")
    }
    
    private func saveStars(stars: [Star]?, fileName: String, predicate: ((Star) -> Bool)? = nil ) {
        guard let stars = stars,
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first,
            let filePath = NSURL(fileURLWithPath: path).appendingPathComponent(fileName) else { return }
        
        print("Writing \(stars.count) stars to file \( filePath )")
        do {
            let startLoading = Date()
            let visibleStars = predicate.flatMap({ stars.filter($0) }) ?? stars
            try SwiftyHYGDB.save(stars: visibleStars, to: filePath)
            print("Writing  took \( Date().timeIntervalSince(startLoading) )")
        } catch {
            print("Error trying to saving stars: \( error )")
        }
    }
    
    private func loadStars(fileName: String) -> [Star]? {
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first,
            let filePath = NSURL(fileURLWithPath: path).appendingPathComponent(fileName) else { return nil }

        let startLoading = Date()
        let stars = SwiftyHYGDB.loadCSVData(from: filePath.absoluteString)
        print("Time to load \(stars?.count ?? 0) stars: \(Date().timeIntervalSince(startLoading))s from \(filePath)")
        XCTAssertNotNil(stars, "Expected \(fileName) to not be empty")
        return stars
    }
    
}
