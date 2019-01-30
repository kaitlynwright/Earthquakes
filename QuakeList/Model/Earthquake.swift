//
//  Earthquake.swift
//  QuakeList
//
//  Created by Kaitlyn Wright on 1/29/19.
//  Copyright © 2019 Kaitlyn Wright. All rights reserved.
//

import Foundation
import UIKit

final class Earthquake: NSObject {
    var magnitude: String
    var place: String
    var url: String
    
    init(magnitude: String, place: String, url: String) {
        self.magnitude = magnitude
        self.place = place
        self.url = url
        
        super.init()
    }
}

