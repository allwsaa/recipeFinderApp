//
//  Recipe.swift
//  RecipeFinderApp
//
//  Created by ntvlbl on 13.12.2024.
//

import Foundation

// Response for recipe search
struct RecipeSearchResponse: Codable {
    let results: [Recipe]
}


struct Recipe: Codable {
    let id: Int
    let title: String
    let image: String
    let readyInMinutes: Int? 
    let nutrition: NutritionInfo?
}

struct RecipeDetail: Codable {
    let id: Int
    let title: String
    let image: String
    let readyInMinutes: Int?
    let servings: Int?
    let summary: String
    let vegan: Bool?
    let glutenFree: Bool?
    let healthScore: Int?
    let nutrition: NutritionInfo?
    let extendedIngredients: [Ingredient]?
    let analyzedInstructions: [Instruction]?
}

struct Instruction: Codable {
    let name: String
    let steps: [Step]
}

struct Step: Codable {
    let number: Int
    let step: String
}

struct Ingredient: Codable {
    let id: Int
    let name: String
    let original: String
    let amount: Double
    let unit: String
    let image: String
}


struct NutritionInfo: Codable {
    let nutrients: [Nutrient]
}

struct Nutrient: Codable {
    let name: String
    let amount: Double
    let unit: String
}
