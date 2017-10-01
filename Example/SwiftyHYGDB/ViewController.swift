//
//  ViewController.swift
//  SwiftyHYGDB
//
//  Created by Bersaelor on 09/10/2017.
//  Copyright (c) 2017 Bersaelor. All rights reserved.
//

import UIKit
import SwiftyHYGDB

class ViewController: UIViewController {

    var stars: [RadialStar]? {
        didSet {
            oldValue?.forEach { $0.starData?.ref.release() }
        }
    }
    var visibleStars: [RadialStar]? {
        didSet {
            oldValue?.forEach { $0.starData?.ref.release() }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("String: size: \(MemoryLayout<String>.size),alignment: \(MemoryLayout<String>.alignment)")
        print("Int32: size: \(MemoryLayout<Int32>.size),alignment: \(MemoryLayout<Int32>.alignment),max: \(Int32.max)")
        print("Int16: size: \(MemoryLayout<Int16>.size),alignment: \(MemoryLayout<Int16>.alignment),max: \(Int16.max)")
        print("RadialStar: size: \(MemoryLayout<RadialStar>.size),alignment: \(MemoryLayout<RadialStar>.alignment)")
        print("Star3D: size: \(MemoryLayout<Star3D>.size),alignment: \(MemoryLayout<Star3D>.alignment)")
        print("StarData: size: \(MemoryLayout<StarData>.size), alignment: \(MemoryLayout<StarData>.alignment), stride: \(MemoryLayout<StarData>.stride)")

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @IBAction func loadDBTapped(_ sender: Any) {
        guard let filePath = Bundle.main.path(forResource: "hygdata_v3", ofType:  "csv") else { return }
        DispatchQueue.global(qos: .background).async { [weak self] in
            let startLoading = Date()
            let stars: [RadialStar]? = SwiftyHYGDB.loadCSVData(from: filePath, precess: true)
            print("Time to load \(stars?.count ?? 0) stars: \(Date().timeIntervalSince(startLoading))s")
            self?.stars = stars

            DispatchQueue.main.async {
                self?.saveStars(fileName: "visibleStars.csv",
                                predicate: { $0.starData?.value.mag ?? Float.infinity < SwiftyHYGDB.maxVisibleMag })
            }
        }
    }
    
    func saveStars(fileName: String, predicate: ((RadialStar) -> Bool)? = nil ) {
        guard let stars = stars,
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first,
            let filePath = NSURL(fileURLWithPath: path).appendingPathComponent(fileName) else { return }

        do {
            let startLoading = Date()
            let visibleStars = predicate.flatMap({ stars.filter($0) }) ?? stars
            try SwiftyHYGDB.save(stars: visibleStars, to: filePath.path)
            print("Writing file to \( filePath ) took \( Date().timeIntervalSince(startLoading) )")
        } catch {
            print("Error trying to saving visible stars: \( error )")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
