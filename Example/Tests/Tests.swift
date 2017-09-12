import UIKit
import XCTest
import SwiftyHYGDB

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLoadingAndSavingEquals() {
        let filePath = Bundle.main.path(forResource: "hygdata_v3", ofType:  "csv")
        XCTAssertNotNil(filePath, "Excpected hygdata_v3 to be bundled")
        
        let startLoading = Date()
        SwiftyHYGDB.loadCSVData(from: filePath!) { (stars) in
            print("Time to load \(stars?.count ?? 0) stars: \(Date().timeIntervalSince(startLoading))s from \(filePath!)")
            XCTAssertNotNil(stars, "Excpected hygdata_v3 to not be empty")
            let starsCountInCSV = 119614
            XCTAssertEqual(stars?.count, starsCountInCSV, "Excpected hygdata_v3 to have \(starsCountInCSV) stars")
            
            let allStarFileName = "allStars.csv"
            self.saveStars(stars: stars, fileName: allStarFileName)
            self.loadStars(fileName: allStarFileName, completion: { (star) in
                XCTAssertEqual(stars?.count, starsCountInCSV, "Excpected \(allStarFileName) to have \(starsCountInCSV) stars too")
            })
        }
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
            print("Error trying to saving visible stars: \( error )")
        }
    }
    
    private func loadStars(fileName: String, completion: ([Star]?) -> Void) {
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first,
            let filePath = NSURL(fileURLWithPath: path).appendingPathComponent(fileName) else { return }

        let startLoading = Date()
        SwiftyHYGDB.loadCSVData(from: filePath.absoluteString) { (stars) in
            print("Time to load \(stars?.count ?? 0) stars: \(Date().timeIntervalSince(startLoading))s from \(filePath)")
            XCTAssertNotNil(stars, "Excpected \(fileName) to not be empty")
            completion(stars)
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
