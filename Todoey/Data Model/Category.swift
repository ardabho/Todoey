//
//  Category.swift
//  Todoey
//
//  Created by Arda Büyükhatipoğlu on 25.04.2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var categoryColor: String = ""
    let items = List<Item>()
}
