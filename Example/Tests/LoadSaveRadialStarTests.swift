import UIKit
import XCTest
import SwiftyHYGDB

extension StarData {
    func isIdentical(starData: StarData) -> Bool {
        return abs(starData.right_ascension - self.right_ascension) < Float.ulpOfOne
            && abs(starData.declination - self.declination) < Float.ulpOfOne
            && starData.hip_id == self.hip_id
            && starData.hd_id == self.hd_id
            && starData.hr_id == self.hr_id
            && starData.gl_id == self.gl_id
            && starData.bayer_flamstedt == self.bayer_flamstedt
            && starData.properName == self.properName
            && abs(starData.distance - self.distance) < Double.ulpOfOne
            && abs((starData.rv ?? 0) - (self.rv ?? 0)) < Double.ulpOfOne
            && abs(starData.mag - self.mag) < Double.ulpOfOne
            && abs(starData.absmag - self.absmag) < Double.ulpOfOne
            && starData.spectralType == self.spectralType
            && abs((starData.colorIndex ?? 0) - (self.colorIndex ?? 0)) < Float.ulpOfOne
    }
}

extension RadialStar {
    func isIdentical(star: RadialStar) -> Bool {
        if dbID != star.dbID { return false }
        if abs(normalizedAscension - star.normalizedAscension) > 10 * Float.ulpOfOne { return false }
        if abs(normalizedDeclination - star.normalizedDeclination) > 10 * Float.ulpOfOne { return false }
        
        guard let starData = self.starData?.value, let otherStarData = star.starData?.value else {
            return self.starData?.value == nil && star.starData?.value == nil
        }
        
        return starData.isIdentical(starData: otherStarData)
    }
}

class LoadSaveRadialStarTests: XCTestCase {
    static let allStarFileName = "allStars.csv"
    let starsCountInCSV = 119614
    var originalStars: [RadialStar]?
    
    override class func setUp() {
        super.setUp()
        
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first,
            let filePath = NSURL(fileURLWithPath: path).appendingPathComponent(allStarFileName) else { return }
        try? FileManager().removeItem(at: filePath)
    }

    override func setUp() {
        super.setUp()

        let originalDBPath = Bundle.main.path(forResource: "hygdata_v3", ofType:  "csv")!
        originalStars = SwiftyHYGDB.loadCSVData(from: originalDBPath)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_01_SaveStars() {
        guard let stars = originalStars else { return }
        XCTAssertEqual(stars.count, starsCountInCSV, "Excpected hygdata_v3 to have \(starsCountInCSV) stars")
        self.saveStars(stars: stars, fileName: LoadSaveRadialStarTests.allStarFileName)
        
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first,
            let filePath = NSURL(fileURLWithPath: path).appendingPathComponent(LoadSaveRadialStarTests.allStarFileName) else { return }
        XCTAssertTrue(FileManager().fileExists(atPath: filePath.path), "File should exist at \(filePath)")
    }
    
    func test_02_ReloadStars() {
        let reloadedStars = self.loadStars(fileName: LoadSaveRadialStarTests.allStarFileName)
        XCTAssertEqual(reloadedStars?.count, starsCountInCSV,
                       "Expected \(LoadSaveRadialStarTests.allStarFileName) to have \(starsCountInCSV) stars too")
        guard let originalStars = originalStars else {
            XCTFail("Failed Test, originalStars should have been loaded by this time")
            return
        }
        for (offset, star) in (reloadedStars ?? []).enumerated() {
            let originalStar = originalStars[offset]
            if !star.isIdentical(star: originalStar) {
                XCTFail("Reloaded Star:\n \(star)\n should have been equal:\n \(originalStars[offset])")
                break
            }
        }
    }
    
    private func saveStars(stars: [RadialStar]?, fileName: String, predicate: ((RadialStar) -> Bool)? = nil ) {
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
    
    private func loadStars(fileName: String) -> [RadialStar]? {
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first,
            let filePath = NSURL(fileURLWithPath: path).appendingPathComponent(fileName) else { return nil }

        let startLoading = Date()
        let stars = SwiftyHYGDB.loadCSVData(from: filePath.path)
        print("Time to load \(stars?.count ?? 0) stars: \(Date().timeIntervalSince(startLoading))s from \(filePath)")
        XCTAssertNotNil(stars, "Expected \(fileName) to not be empty")
        return stars
    }
    
}
