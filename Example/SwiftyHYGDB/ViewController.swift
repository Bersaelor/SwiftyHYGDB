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

    var stars: [Star]?
    var visibleStars: [Star]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let filePath = Bundle.main.path(forResource: "hygdata_v3", ofType:  "csv") else { return }
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            let startLoading = Date()
            let stars = SwiftyHYGDB.loadCSVData(from: filePath)
            self?.stars = stars
            print("Time to load \(stars?.count ?? 0) stars: \(Date().timeIntervalSince(startLoading))s")
            DispatchQueue.main.async {
                self?.saveStars(fileName: "visibleStars.csv",
                                predicate: { $0.starData?.value.mag ?? Double.infinity < SwiftyHYGDB.maxVisibleMag })
            }
        }
    }
    
    func saveStars(fileName: String, predicate: ((Star) -> Bool)? = nil ) {
        guard let stars = stars,
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first,
            let filePath = NSURL(fileURLWithPath: path).appendingPathComponent(fileName) else { return }

        do {
            let startLoading = Date()
            let visibleStars = predicate.flatMap({ stars.filter($0) }) ?? stars
            try SwiftyHYGDB.save(stars: visibleStars, to: filePath)
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

