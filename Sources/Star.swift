//
//  Star.swift
//
//  Created by Konrad Feiler on 21/03/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation

public struct Star {
    let dbID: Int32
    let normalizedAscension: Float
    let normalizedDeclination: Float
    let starData: Box<StarData>?
}

extension Star {
    var starPoint: CGPoint {
        guard let data = starData?.value else { return CGPoint.zero }
        return CGPoint(x: CGFloat(data.right_ascension), y: CGFloat(data.declination))
    }
    
    init? (row: String, advanceByYears: Float? = nil) {
        let fields = row.components(separatedBy: ",")
        
        guard fields.count > 13 else {
            print("Not enough rows in \(fields)")
            return nil
        }
        
        guard let dbID = Int32(fields[0]),
            var right_ascension = Float(fields[7]),
            var declination = Float(fields[8]),
            let dist = Double(fields[9]),
            let pmra = Double(fields[10]),
            let pmdec = Double(fields[11]),
            let mag = Double(fields[13]),
            let absmag = Double(fields[14])
            else {
                print("Invalid Row: \(row), \n fields: \(fields)")
                return nil
        }

        print("(\(right_ascension), \(declination)), pm: (\(pmra), \(pmdec))")
        Star.precess(right_ascension: &right_ascension, declination: &declination, pmra: pmra, pmdec: pmdec, advanceByYears: advanceByYears)
        print("-> (\(right_ascension), \(declination))")

        self.dbID = dbID
        self.normalizedAscension = Star.normalizedAscension(rightAscension: right_ascension)
        self.normalizedDeclination = Star.normalizedDeclination(declination: declination)
        let starData = StarData(right_ascension: right_ascension,
                                declination: declination,
                                hip_id: Int32(fields[1]),
                                hd_id: Int32(fields[2]),
                                hr_id: Int32(fields[3]),
                                gl_id: fields[4],
                                bayer_flamstedt: fields[5],
                                properName: fields[6],
                                distance: dist, pmra: pmra, pmdec: pmdec, rv: Double(fields[12]),
                                mag: mag, absmag: absmag, spectralType: fields[14], colorIndex: Float(fields[15]))
        self.starData = Box(starData)
    }
    
    init (ascension: Float, declination: Float, dbID: Int32 = -1, starData: Box<StarData>? = nil) {
        self.dbID = dbID
        self.normalizedAscension = Star.normalizedAscension(rightAscension: ascension)
        self.normalizedDeclination = Star.normalizedDeclination(declination: declination)
        self.starData = starData
    }
    
    static func precess(right_ascension: inout Float, declination: inout Float,
                        pmra: Double, pmdec: Double, advanceByYears: Float?)
    {
        guard let advanceByYears = advanceByYears, advanceByYears > 0 else { return }
        declination = Float(Double(declination) + Double(advanceByYears) * pmdec / (3600 * 1000) )
        let underMinus90 = abs(declination + 90)
        if declination < -90 {
            declination = underMinus90 - 90
            right_ascension = (right_ascension + 12 > 24) ? right_ascension - 12 : right_ascension + 12
        }
        else if declination > 90 {
            let over90 = declination - 90
            declination = 90 - over90
            right_ascension = (right_ascension + 12 > 24) ? right_ascension - 12 : right_ascension + 12
        }
        
        right_ascension = Float(Double(right_ascension) + Double(advanceByYears) * pmra / (3600 * 1000) )
        if right_ascension < 0.0 { right_ascension += Float(ascensionRange) }
        else if right_ascension > Float(ascensionRange) { right_ascension -= Float(ascensionRange) }
    }
    
    func starMoved(ascension: Float, declination: Float) -> Star {
        let normalizedAsc = self.normalizedAscension + Star.normalizedAscension(rightAscension: ascension)
        let normalizedDec = self.normalizedDeclination + Star.normalizedDeclination(declination: declination)
        return Star(ascension: Star.rightAscension(normalizedAscension: normalizedAsc),
                    declination: Star.declination(normalizedDeclination: normalizedDec),
                    dbID: self.dbID, starData: self.starData)
    }
}

let ascensionRange: CGFloat = 24.0
let declinationRange: CGFloat = 180

extension Star {
    static func normalizedAscension(rightAscension: Float) -> Float {
        return rightAscension/Float(ascensionRange)
    }
    static func normalizedDeclination(declination: Float) -> Float {
        return (declination + 90)/Float(declinationRange)
    }
    
    static func rightAscension(normalizedAscension: Float) -> Float {
        return Float(ascensionRange) * normalizedAscension
    }
    static func declination(normalizedDeclination: Float) -> Float {
        return normalizedDeclination * Float(declinationRange) - 90
    }
}

// swiftlint:enable variable_name

public func == (lhs: Star, rhs: Star) -> Bool {
    return lhs.dbID == rhs.dbID
}

extension Star: Equatable {}

extension Star: CustomDebugStringConvertible {
    public var debugDescription: String {
        let distanceString = starData?.value.distance ?? Double.infinity
        let magString = starData?.value.mag ?? Double.infinity
        return "🌠: ".appending(starData?.value.properName ?? "N.A.")
            .appending(", Hd(\(starData?.value.hd_id ?? -1)) + HR(\(starData?.value.hr_id ?? -1))")
            .appending("Gliese(\(starData?.value.gl_id ?? "")), BF(\(starData?.value.bayer_flamstedt ?? "")):")
            .appending("\(starData?.value.right_ascension ?? 100), \(starData?.value.declination ?? 100),"
            .appending(" \( distanceString ) mag: \(magString)"))
    }
}
