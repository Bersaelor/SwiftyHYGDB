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
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let filePath = Bundle.main.path(forResource: "hygdata_v3", ofType:  "csv") else { return }
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            let startLoading = Date()
            SwiftyHYGDB.loadCSVData(from: filePath) { (stars) in
                self?.stars = stars
                print("Time to load \(stars?.count ?? 0) stars: \(Date().timeIntervalSince(startLoading))s")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

