import UIKit
import XCTest
@testable import SwiftyHYGDB

class LoadSaveRadialStarTests: XCTestCase {
    static let allStarFileName = "allStars.csv"
    static let allStar3DFileName = "allStars3D.csv"
    let starsCountInCSV = 119614
    lazy var originalStars: [RadialStar]? = {
        let originalDBPath = Bundle.main.path(forResource: "hygdata_v3", ofType:  "csv")!
        return SwiftyHYGDB.loadCSVData(from: originalDBPath, precess: true)
    }()
    lazy var originalStar3Ds: [Star3D]? = {
        let originalDBPath = Bundle.main.path(forResource: "hygdata_v3", ofType:  "csv")!
        return SwiftyHYGDB.loadCSVData(from: originalDBPath, precess: true)
    }()
    
    func test_01_SaveRadialStars() {
        guard let stars = originalStars else { return }
        XCTAssertEqual(stars.count, starsCountInCSV, "Excpected hygdata_v3 to have \(starsCountInCSV) stars")
        self.saveStars(stars: stars, fileName: LoadSaveRadialStarTests.allStarFileName)
        
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first,
            let filePath = NSURL(fileURLWithPath: path).appendingPathComponent(LoadSaveRadialStarTests.allStarFileName) else { return }
        XCTAssertTrue(FileManager().fileExists(atPath: filePath.path), "File should exist at \(filePath)")
    }
    
    func test_02_ReloadRadialStars() {
        let reloadedStars: [RadialStar]? = self.loadStars(fileName: LoadSaveRadialStarTests.allStarFileName)
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
    
    func test_04_Save3DStars() {
        guard let stars = originalStar3Ds else { return }
        XCTAssertEqual(stars.count, starsCountInCSV, "Expected hygdata_v3 to have \(starsCountInCSV) stars")
        self.saveStars(stars: stars, fileName: LoadSaveRadialStarTests.allStar3DFileName)
        
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first,
            let filePath = NSURL(fileURLWithPath: path).appendingPathComponent(LoadSaveRadialStarTests.allStarFileName) else { return }
        XCTAssertTrue(FileManager().fileExists(atPath: filePath.path), "File should exist at \(filePath)")
    }
    
    func test_05_Reload3DStars() {
        let reloadedStars: [Star3D]? = self.loadStars(fileName: LoadSaveRadialStarTests.allStar3DFileName)
        XCTAssertEqual(reloadedStars?.count, starsCountInCSV,
                       "Expected \(LoadSaveRadialStarTests.allStar3DFileName) to have \(starsCountInCSV) stars too")
        guard let originalStars = originalStar3Ds else {
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
    
    func test_06_advanceByYears() {
        guard let originalDBPath = Bundle.main.path(forResource: "hygdata_v3", ofType:  "csv"),
            let fileHandle = fopen(originalDBPath, "r") else {
            XCTFail("Failed to get file handle for hygdata_v3")
            return
        }
        defer { fclose(fileHandle) }
        
        let yearsToAdvance: Float = 100
        let initialRA = 0.001470
        let initialDec = 20.036114
        let perYearMilliArcSecondsRA = -208.12
        let perYearMilliArcSecondsDec = -200.79
        var expectedRA = initialRA + perYearMilliArcSecondsRA * Double(yearsToAdvance) / (1000 * 13600) * (360 / 24)
        if expectedRA < 0 { expectedRA += 24.0 }
        let expectedDec = initialDec + perYearMilliArcSecondsDec * Double(yearsToAdvance) / (1000 * 13600)
        let lines = lineIteratorC(file: fileHandle)
        var count = 0
        if let linePtr = lines.dropFirst(8).first(where: { _ in true }) {
            defer { free(linePtr) }
            let star = RadialStar(rowPtr :linePtr, advanceByYears: yearsToAdvance)
            guard let ra = star?.starData?.value.right_ascension, let dec = star?.starData?.value.declination else {
                XCTFail("Failed to load starData dbID 2 in row 3")
                return
            }
            XCTAssertEqual(ra, Float(expectedRA), accuracy: Float.ulpOfOne,
                           "Right Asc. precessed by \(yearsToAdvance)y should be correct")
            XCTAssertEqual(dec, Float(expectedDec), accuracy: Float.ulpOfOne,
                           "Dec precessed by \(yearsToAdvance)y should be correct")
        } else {
            XCTFail("Failed to load star dbID 2 in row 3")
        }
    }
    
    func test_07_RadialStarCoding() {
        // FIXME
    }

    func test_08_Star3DCoding() {
        // FIXME
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
    
    private func saveStars(stars: [Star3D]?, fileName: String, predicate: ((Star3D) -> Bool)? = nil ) {
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
        guard let filePath = path(for: fileName) else { return nil }

        let startLoading = Date()
        let stars: [RadialStar]? = SwiftyHYGDB.loadCSVData(from: filePath.path)
        print("Time to load \(stars?.count ?? 0) stars: \(Date().timeIntervalSince(startLoading))s from \(filePath)")
        XCTAssertNotNil(stars, "Expected \(fileName) to not be empty")
        return stars
    }

    private func loadStars(fileName: String) -> [Star3D]? {
        guard let filePath = path(for: fileName) else { return nil }
        
        let startLoading = Date()
        let stars: [Star3D]? = SwiftyHYGDB.loadCSVData(from: filePath.path)
        print("Time to load \(stars?.count ?? 0) stars: \(Date().timeIntervalSince(startLoading))s from \(filePath)")
        XCTAssertNotNil(stars, "Expected \(fileName) to not be empty")
        return stars
    }
    
    private func path(for fileName: String) -> URL? {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first.flatMap { (path) -> URL in
            return URL(fileURLWithPath: path).appendingPathComponent(fileName)
        }
    }
}
