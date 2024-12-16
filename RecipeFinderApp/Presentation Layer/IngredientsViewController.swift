//
//  IngredientsViewController.swift
//  RecipeFinderApp
//
//  Created by Aisha Karzhauova on 16.12.2024.
//

import UIKit

class IngredientsViewController: UIViewController {
    var ingredients: [Ingredient] = []

    private let ingredientsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Ingredients"
        view.backgroundColor = .white
        view.addSubview(ingredientsLabel)

        ingredientsLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }

        displayIngredients()
    }

    private func displayIngredients() {
        let ingredientsText = ingredients.map { "• \($0.original)" }.joined(separator: "\n")
        ingredientsLabel.text = ingredientsText
    }
}

