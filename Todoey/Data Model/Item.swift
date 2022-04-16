//
//  DataModel.swift
//  Todoey
//
//  Created by Arda Büyükhatipoğlu on 16.04.2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation

class Item: Codable {
    
    var title: String = ""
    var completion: Bool = false
    
}
