//
//  NetworkManager.swift
//  RecipeFinderApp
//
//  Created by ntvlbl on 13.12.2024.
//

import Foundation
import Alamofire

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "https://api.spoonacular.com/recipes"
    private let apiKey = "86e3c607d21149d5ae5d3c4e7818b7e3"
    // aisha api key c00988fc3397406296476c02eb459530
    // alima api key 86e3c607d21149d5ae5d3c4e7818b7e3

    // Fetch a list of recipes
    func fetchRecipes(by ingredients: [String] = [], filters: [String: String] = [:], completion: @escaping ([Recipe]?, Error?) -> Void) {
        var url = "\(baseURL)/complexSearch?apiKey=\(apiKey)&addRecipeInformation=true"
        if !ingredients.isEmpty {
            url += "&query=\(ingredients.joined(separator: ","))"
        }
        filters.forEach { key, value in
            url += "&\(key)=\(value)"
        }

        AF.request(url).responseDecodable(of: RecipeSearchResponse.self) { response in
            switch response.result {
            case .success(let result):
                completion(result.results, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }

    func fetchRecipeDetail(by id: Int, completion: @escaping (RecipeDetail?, Error?) -> Void) {
        let url = "https://api.spoonacular.com/recipes/\(id)/information?apiKey=\(apiKey)&includeNutrition=true"
        AF.request(url).responseDecodable(of: RecipeDetail.self) { response in
            switch response.result {
            case .success(let recipeDetail):
                completion(recipeDetail, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }


}
