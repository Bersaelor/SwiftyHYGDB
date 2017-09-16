//
//  Testhelper+StarIdentical.swift
//  SwiftyHYGDB_Tests
//
//  Created by Konrad Feiler on 16.09.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
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
        if abs(normalizedAscension - star.normalizedAscension) > 1 * Float.ulpOfOne { return false }
        if abs(normalizedDeclination - star.normalizedDeclination) > 1 * Float.ulpOfOne { return false }
        
        guard let starData = self.starData?.value, let otherStarData = star.starData?.value else {
            return self.starData?.value == nil && star.starData?.value == nil
        }
        
        return starData.isIdentical(starData: otherStarData)
    }
}

extension Star3D {
    func isIdentical(star: Star3D) -> Bool {
        if dbID != star.dbID { return false }
        if abs(x - star.x) > 10 * Float.ulpOfOne { return false }
        if abs(y - star.y) > 10 * Float.ulpOfOne { return false }
        if abs(z - star.z) > 10 * Float.ulpOfOne { return false }

        guard let starData = self.starData?.value, let otherStarData = star.starData?.value else {
            return self.starData?.value == nil && star.starData?.value == nil
        }
        
        return starData.isIdentical(starData: otherStarData)
    }
}
