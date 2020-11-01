//
//  Category.swift
//  RecipeProject
//
//  Created by Owen Bick on 10/31/20.
//

import Foundation

struct Categories: Codable {
    var categories: [Category]
}


struct Category: Codable {
    var idCategory: String?
    var strCategory: String?
    var strCategoryThumb: String?
}
