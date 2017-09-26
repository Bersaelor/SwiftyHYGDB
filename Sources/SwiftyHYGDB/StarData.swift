//
//  StarData.swift
//  SwiftyHYGDB
//
//  Created by Konrad Feiler on 11.09.17.
//

import Foundation

// swiftlint:disable variable_name

public struct StarData: Codable {
    public let right_ascension: Float
    public let declination: Float
    public let db_id: Int32
    public let hip_id: Int32
    public let hd_id: Int32
    public let hr_id: Int32
    public let gl_id: String
    public let bayer_flamstedt: String
    public let properName: String
    public let distance: Double
    public let rv: Double
    public let mag: Double
    public let absmag: Double
    public let spectralType: [CChar]
    public let colorIndex: Float

    enum CodingKeys: String, CodingKey {
        case right_ascension = "r"
        case declination     = "d"
        case db_id           = "i"
        case hip_id          = "hi"
        case hd_id           = "hd"
        case hr_id           = "hr"
        case gl_id           = "gl"
        case bayer_flamstedt = "b"
        case properName      = "p"
        case distance        = "e"
        case rv              = "v"
        case mag             = "m"
        case absmag          = "a"
        case spectralType    = "s"
        case colorIndex      = "c"
    }
}

extension StarData {
    init(right_ascension: Float, declination: Float,
         db_id: Int32,
         hip_id: Int32?,
         hd_id: Int32?,
         hr_id: Int32?,
         gl_id: String?,
         bayer_flamstedt: String?,
         properName: String?,
         distance: Double, rv: Double?,
         mag: Double, absmag: Double,
         spectralType: String?, colorIndex: Float?) {
        
        self.right_ascension = right_ascension
        self.declination = declination
        self.db_id = db_id
        self.hip_id = hip_id ?? -1
        self.hd_id = hd_id ?? -1
        self.hr_id = hr_id ?? -1
        self.gl_id = gl_id ?? ""
        self.bayer_flamstedt = bayer_flamstedt ?? ""
        self.properName = properName ?? ""
        self.distance = distance
        self.rv = rv ?? 0
        self.mag = mag
        self.absmag = absmag
        self.spectralType = (spectralType ?? "").cString(using: .utf8) ?? []
        self.colorIndex = colorIndex ?? 0
    }
}

extension StarData {
    public var csvLine: String {
        var result = (db_id.description).appending(",")
        result.append((hip_id != -1 ? hip_id.description : "").appending(","))
        result.append((hd_id != -1 ? hd_id.description : "").appending(","))
        result.append((hr_id != -1 ? hr_id.description : "").appending(","))
        result.append((gl_id.description).appending(","))
        result.append((bayer_flamstedt).appending(","))
        result.append((properName).appending(","))
        result.append(right_ascension.compressedString.appending(","))
        result.append(declination.compressedString.appending(","))
        result.append(distance.compressedString.appending(","))
        result.append((rv.compressedString).appending(","))
        result.append(mag.compressedString.appending(","))
        result.append(absmag.compressedString.appending(","))
        result.append((String(cString: spectralType)).appending(","))
        result.append((colorIndex.compressedString).appending(","))
        return result
    }
}
