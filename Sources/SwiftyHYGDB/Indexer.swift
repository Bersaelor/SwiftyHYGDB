//
//  ValueIndexer.swift
//  SwiftyHYGDB
//
//  Created by Konrad Feiler on 01.10.17.
//

import Foundation

struct Indexer<Value: Hashable> {
    private var collectedValues = [Value: Int16]()

    mutating func index(for value: Value?) -> Int16 {
        guard let value = value else { return Int16(SwiftyHYGDB.missingValueIndex) }
        if let existingValueNr = collectedValues[value] {
            return existingValueNr
        } else {
            let spectralTypeNr = Int16(collectedValues.count)
            collectedValues[value] = spectralTypeNr
            return spectralTypeNr
        }
    }
    
    func indexedValues() -> [Value] {
        return collectedValues.sorted(by: { (a, b) -> Bool in
            return a.value < b.value
        }).map { $0.key }
    }
}
