//
//  Recipe.swift
//  RecipeProject
//
//  Created by Owen Bick on 10/4/20.
//

import Foundation


struct Recipes: Codable {
    var meals: [Recipe]
}


struct Recipe: Codable {
    var idMeal: String?
    var strMeal: String?
    var strCategory: String?
    var strMealThumb: String?
}


