//
//  StarData.swift
//  SwiftyHYGDB
//
//  Created by Konrad Feiler on 11.09.17.
//

import Foundation

// swiftlint:disable variable_name

public struct StarData: Codable {
    let right_ascension: Float
    let declination: Float
    let hip_id: Int32?
    let hd_id: Int32?
    let hr_id: Int32?
    let gl_id: String?
    let bayer_flamstedt: String?
    let properName: String?
    let distance: Double
    let pmra: Double
    let pmdec: Double
    let rv: Double?
    let mag: Double
    let absmag: Double
    let spectralType: String?
    let colorIndex: Float?
    
    enum CodingKeys: String, CodingKey {
        case right_ascension = "r"
        case declination     = "d"
        case hip_id          = "hi"
        case hd_id           = "hd"
        case hr_id           = "hr"
        case gl_id           = "gl"
        case bayer_flamstedt = "b"
        case properName      = "p"
        case distance        = "i"
        case pmra            = "pr"
        case pmdec           = "pd"
        case rv              = "v"
        case mag             = "m"
        case absmag          = "a"
        case spectralType    = "s"
        case colorIndex      = "c"
    }
}
