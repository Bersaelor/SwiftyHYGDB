//
//  StarHelper.swift
//
//  Created by Konrad Feiler on 28.03.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation

public class SwiftyHYGDB: NSObject {
    static let maxVisibleMag = 6.5
    
    private static var yearsSinceEraStart: Int {
        let dateComponents = DateComponents(year: 2000, month: 3, day: 21, hour: 1)
        guard let springEquinox = Calendar.current.date(from: dateComponents) else { return 0 }
        let components = Calendar.current.dateComponents([.year], from: springEquinox, to: Date())
        
        return components.hour ?? 0
    }

    /// Loads Stars from CSV file line by line using line iterator.
    /// Be advised that Stardata is not memory managed so `star.starData?.ref.release()` has to be called manually
    /// for every star when no longer needed
    ///
    /// - Parameters:
    ///   - filePath: the path of the csv encoded HYG database file (see http://www.astronexus.com/hyg )
    ///   - precess: Bool to opt into preceeding positions
    ///   - completion: returns the loaded stars
    public static func loadCSVData(from filePath: String, precess: Bool = false, completion: ([Star]?) -> Void) {
        guard let fileHandle = fopen(filePath, "r") else {
            completion(nil)
            return
        }
        defer { fclose(fileHandle) }
        
        let yearsToAdvance = precess ? Float(yearsSinceEraStart) : nil
        let lines = lineIteratorC(file: fileHandle)
        let stars = lines.dropFirst().flatMap { linePtr -> Star? in
            defer { free(linePtr) }
            let star = Star(rowPtr :linePtr, advanceByYears: yearsToAdvance)
            return star
        }
        
        completion(stars)
    }

}
