import Foundation
import XCTest
@testable import SwiftyHYGDB

class LoadSaveRadialStarTests: XCTestCase {
    static let allStarFileName = "allStars.csv"
    static let allStar3DFileName = "allStars3D.csv"
    let starsCountInCSV = 119614
    
    var originalDBPath: String {
        if let originalDBPath = Bundle.main.path(forResource: "hygdata_v3", ofType:  "csv") { return originalDBPath }
        return String.getOriginalRepositoryPath()! + "/Example/SwiftyHYGDB/hygdata_v3.csv"
    }
    lazy var originalStars: [RadialStar]? = {
        return SwiftyHYGDB.loadCSVData(from: originalDBPath, precess: true)
    }()
    lazy var originalStar3Ds: [Star3D]? = {
        return SwiftyHYGDB.loadCSVData(from: originalDBPath, precess: true)
    }()
    func filePath(for fileName: String) -> String {
        #if os(iOS)
            guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first,
                let filePath = NSURL(fileURLWithPath: path).appendingPathComponent(fileName) else { return "" }
            return filePath.path
        #else
            return String.getOriginalRepositoryPath()! + String.separator + fileName
        #endif
    }
    
    static var allTests = [
        ("test_01_SaveRadialStars", test_01_SaveRadialStars),
        ("test_02_ReloadRadialStars", test_02_ReloadRadialStars),
        ("test_04_Save3DStars", test_04_Save3DStars),
        ("test_05_Reload3DStars", test_05_Reload3DStars),
        ("test_06_advanceByYears", test_06_advanceByYears),
        ("test_07_RadialStarCoding", test_07_RadialStarCoding),
        ("test_08_Star3DCoding", test_08_Star3DCoding),
        ("test_09_Star3DMovement", test_09_Star3DMovement),
    ]
    
    func test_01_SaveRadialStars() {
        guard let stars = originalStars else { return }
        XCTAssertEqual(stars.count, starsCountInCSV, "Excpected hygdata_v3 to have \(starsCountInCSV) stars")
        self.saveStars(stars: stars, fileName: LoadSaveRadialStarTests.allStarFileName)
        let path = self.filePath(for: LoadSaveRadialStarTests.allStarFileName)
        XCTAssertTrue(FileManager().fileExists(atPath: path), "File should exist at \(path)")
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
        let path = self.filePath(for: LoadSaveRadialStarTests.allStarFileName)
        XCTAssertTrue(FileManager().fileExists(atPath: path), "File should exist at \(path)")
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
        guard let fileHandle = fopen(originalDBPath, "r") else {
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
        var indexers = SwiftyDBValueIndexers()

        if let linePtr = lines.dropFirst(8).first(where: { _ in true }) {
            defer { free(linePtr) }
            let star = RadialStar(rowPtr :linePtr, advanceByYears: yearsToAdvance, indexers: &indexers)
            guard let ra = star?.starData?.value.right_ascension, let dec = star?.starData?.value.declination else {
                XCTFail("Failed to load starData dbID 2 in row 3")
                return
            }
            XCTAssertEqual(ra, Float(expectedRA), accuracy: Float.ulpOfOne,
                           "Right Asc. precessed by \(yearsToAdvance)y should be correct")
            XCTAssertEqual(dec, Float(expectedDec), accuracy: Float.ulpOfOne,
                           "Dec precessed by \(yearsToAdvance)y should be correct")
        } else {
            XCTFail("Failed to load star dbID 2 in row 7")
        }
    }
    
    func test_07_RadialStarCoding() {
        guard let originalStars = originalStars else {
            XCTFail("Failed to load original Stars")
            return
        }
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let stars = Array(originalStars[10...20])
        do {
            let data = try encoder.encode(stars)
            XCTAssertGreaterThan(data.count, 10, "Data should contain")
            let decodedStars = try decoder.decode([RadialStar].self, from: data)
            for (offset, star) in decodedStars.enumerated() {
                let originalStar = stars[offset]
                if !star.isIdentical(star: originalStar) {
                    XCTFail("Reloaded Star: \(star) should have been equal: \(originalStar)")
                    print("star.cvsline: \(star.csvLine!)")
                    print("originalStar: \(originalStar.csvLine!)")
                    break
                }
            }
        } catch { XCTFail("Due to error \(error)") }
    }

    func test_08_Star3DCoding() {
        guard let originalStars = originalStar3Ds else {
            XCTFail("Failed to load original Stars")
            return
        }
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let stars = Array(originalStars[10...20])
        do {
            let data = try encoder.encode(stars)
            XCTAssertGreaterThan(data.count, 10, "Data should contain")
            let decodedStars = try decoder.decode([Star3D].self, from: data)
            for (offset, star) in decodedStars.enumerated() {
                let originalStar = stars[offset]
                if !star.isIdentical(star: originalStar) {
                    XCTFail("Reloaded Star: \(star) should have been equal: \(originalStar)")
                    print("star.cvsline: \(star.csvLine!)")
                    print("originalStar: \(originalStar.csvLine!)")
                    break
                }
            }
        } catch { XCTFail("Due to error \(error)") }
    }
    
    func test_09_Star3DMovement() {
        guard let fileHandle = fopen(originalDBPath, "r") else {
                XCTFail("Failed to get file handle for hygdata_v3")
                return
        }
        defer { fclose(fileHandle) }
        
        let yearsToAdvance: Double = 100
        let initialPoint = Point3D(x: 54.367897, y: 0.020886, z: 19.827115)
        let perYearParsecs = Point3D(x: Float(yearsToAdvance * 0.00001932),
                                     y: Float(yearsToAdvance * -0.00005838),
                                     z: Float(yearsToAdvance * -0.00005292))
        let expectedPoint = initialPoint +  perYearParsecs
        let lines = lineIteratorC(file: fileHandle)
        var indexers = SwiftyDBValueIndexers()

        if let linePtr = lines.dropFirst(8).first(where: { _ in true }) {
            defer { free(linePtr) }
            guard let star = Star3D(rowPtr :linePtr, advanceByYears: yearsToAdvance, indexers: &indexers) else {
                XCTFail("failed to load star from rowPtr")
                return
            }
            for (coo, expected) in [(star.x, expectedPoint.x), (star.y, expectedPoint.y), (star.z, expectedPoint.z)] {
                XCTAssertEqual(coo, expected, accuracy: Float.ulpOfOne,
                               "Pos. after \(yearsToAdvance)y should be correct")
            }
        } else {
            XCTFail("Failed to load star dbID 2 in row 3")
        }
    }
    
    private func saveStars(stars: [RadialStar]?, fileName: String, predicate: ((RadialStar) -> Bool)? = nil ) {
        guard let stars = stars else { return }

        print("Writing \(stars.count) stars to file \( fileName )")
        do {
            let startLoading = Date()
            let visibleStars = predicate.flatMap({ stars.filter($0) }) ?? stars
            try SwiftyHYGDB.save(stars: visibleStars, to: self.filePath(for: fileName))
            print("Writing  took \( Date().timeIntervalSince(startLoading) )")
        } catch { print("Error trying to saving stars: \( error )") }
    }
    
    private func saveStars(stars: [Star3D]?, fileName: String, predicate: ((Star3D) -> Bool)? = nil ) {
        guard let stars = stars else { return }

        print("Writing \(stars.count) stars to file \( fileName)")
        do {
            let startLoading = Date()
            let visibleStars = predicate.flatMap({ stars.filter($0) }) ?? stars
            try SwiftyHYGDB.save(stars: visibleStars, to: self.filePath(for: fileName))
            print("Writing  took \( Date().timeIntervalSince(startLoading) )")
        } catch { print("Error trying to saving stars: \( error )") }
    }
    
    private func loadStars(fileName: String) -> [RadialStar]? {
        let filePath = self.filePath(for: fileName)
        let startLoading = Date()
        let stars: [RadialStar]? = SwiftyHYGDB.loadCSVData(from: filePath)
        print("Time to load \(stars?.count ?? 0) stars: \(Date().timeIntervalSince(startLoading))s from \(filePath)")
        XCTAssertNotNil(stars, "Expected \(fileName) to not be empty")
        return stars
    }

    private func loadStars(fileName: String) -> [Star3D]? {
        let filePath = self.filePath(for: fileName)
        let startLoading = Date()
        let stars: [Star3D]? = SwiftyHYGDB.loadCSVData(from: filePath)
        print("Time to load \(stars?.count ?? 0) stars: \(Date().timeIntervalSince(startLoading))s from \(filePath)")
        XCTAssertNotNil(stars, "Expected \(fileName) to not be empty")
        return stars
    }
}
