//
//  Testhelper+StarIdentical.swift
//  SwiftyHYGDB_Tests
//
//  Created by Konrad Feiler on 16.09.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import SwiftyHYGDB

let accuracy: Float = {
    if #available(iOS 11, *) { return Float.ulpOfOne
    } else { return 35 * Float.ulpOfOne }
}()

extension StarData {
    func isIdentical(starData: StarData) -> Bool {
        return abs(starData.right_ascension - self.right_ascension) < accuracy
            && abs(starData.declination - self.declination) < accuracy
            && starData.hip_id == self.hip_id
            && starData.hd_id == self.hd_id
            && starData.hr_id == self.hr_id
            && starData.gl_id == self.gl_id
            && starData.bayer_flamstedt == self.bayer_flamstedt
            && starData.properName == self.properName
            && abs(starData.distance - self.distance) < Double.ulpOfOne
            && abs((starData.rv) - (self.rv)) < Double.ulpOfOne
            && abs(starData.mag - self.mag) < Float.ulpOfOne
            && abs(starData.absmag - self.absmag) < Float.ulpOfOne
            && starData.spectralType == self.spectralType
            && abs((starData.colorIndex) - (self.colorIndex)) < Float.ulpOfOne
    }
}

extension RadialStar {
    func isIdentical(star: RadialStar) -> Bool {
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
        if abs(x - star.x) > 15 * accuracy { return false }
        if abs(y - star.y) > 15 * accuracy { return false }
        if abs(z - star.z) > 15 * accuracy { return false }

        guard let starData = self.starData?.value, let otherStarData = star.starData?.value else {
            return self.starData?.value == nil && star.starData?.value == nil
        }
        
        return starData.isIdentical(starData: otherStarData)
    }
}
