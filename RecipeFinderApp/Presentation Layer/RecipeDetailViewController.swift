//
//  RecipeDetailViewController.swift
//  RecipeFinderApp
//
//  Created by ntvlbl on 13.12.2024.
//

import UIKit
import SnapKit

class RecipeDetailViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let recipeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    

    private let rowOne: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .fill
        stack.distribution = .fillEqually
        return stack
    }()

    private let rowTwo: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .fill
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let infoContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical             // Ensures rows are stacked vertically
        stack.spacing = 12                 // Adds spacing between rows
        stack.alignment = .fill            // Ensures rows take full width
        stack.distribution = .equalSpacing // Distributes rows evenly
        return stack
    }()
    private lazy var skillLabel: UILabel = createInfoLabel(text: "Skill: Easy")
    private lazy var prepTimeLabel: UILabel = createInfoLabel(text: "Prep Time: 20 min")
    private lazy var ratingLabel: UILabel = createInfoLabel(text: "⭐⭐⭐⭐⭐")
    
    private let ingredientsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    private let glutenFreeButton: UIButton = createActionButton(title: "Make this Gluten Free!")
    private let paleoButton: UIButton = createActionButton(title: "Make this Paleo!")
    
    // MARK: - Properties
    var recipeID: Int
    private var recipeDetail: RecipeDetail?

    // MARK: - Initializers
    init(recipeID: Int) {
        self.recipeID = recipeID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        fetchRecipeDetail()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Add subviews
        view.addSubview(recipeImageView)
        view.addSubview(titleLabel)
        view.addSubview(infoContainer)
        view.addSubview(ingredientsLabel)
        view.addSubview(glutenFreeButton)
        view.addSubview(paleoButton)
        
        infoContainer.addArrangedSubview(rowOne)
        infoContainer.addArrangedSubview(rowTwo)

        
        // Layout constraints
        recipeImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(200)
            make.width.equalTo(300)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(recipeImageView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        infoContainer.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        ingredientsLabel.snp.makeConstraints { make in
            make.top.equalTo(infoContainer.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        glutenFreeButton.snp.makeConstraints { make in
            make.top.equalTo(ingredientsLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }

        paleoButton.snp.makeConstraints { make in
            make.top.equalTo(glutenFreeButton.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
    }



    
    // MARK: - Fetch and Configure Data
    private func fetchRecipeDetail() {
        NetworkManager.shared.fetchRecipeDetail(by: recipeID) { [weak self] recipeDetail, error in
            if let error = error {
                print("Error fetching recipe details: \(error.localizedDescription)")
                return
            }
            guard let self = self, let recipeDetail = recipeDetail else { return }
            self.recipeDetail = recipeDetail
            
            DispatchQueue.main.async {
                self.configureUI()
            }
        }
    }
    
    private func createInfoLabel(text: String) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.text = text
        label.textAlignment = .left
        label.textColor = .darkGray
        return label
    }
    
    private func configureUI() {
        guard let recipe = recipeDetail else { return }

        titleLabel.text = recipe.title

        if let imageUrl = URL(string: recipe.image) {
            recipeImageView.loadImage(from: imageUrl)
        }

        // Clear existing arrangedSubviews to avoid duplicates
        rowOne.arrangedSubviews.forEach { $0.removeFromSuperview() }
        rowTwo.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add labels to rowOne
        rowOne.addArrangedSubview(createInfoLabel(text: "Skill: Easy"))
        rowOne.addArrangedSubview(createInfoLabel(text: "Time: \(recipe.readyInMinutes ?? 0) min"))
        rowOne.addArrangedSubview(createInfoLabel(text: "⭐ \(recipe.healthScore ?? 0)"))

        // Add labels to rowTwo
        let servingsLabel = createInfoLabel(text: "Servings: \(recipe.servings ?? 0)")
        let veganLabel = createInfoLabel(text: "Vegan: \(recipe.vegan == true ? "Yes" : "No")")
        let glutenFreeLabel = createInfoLabel(text: "Gluten-Free: \(recipe.glutenFree == true ? "Yes" : "No")")

        rowTwo.addArrangedSubview(servingsLabel)
        rowTwo.addArrangedSubview(veganLabel)
        rowTwo.addArrangedSubview(glutenFreeLabel)

        // Update ingredients
        if let ingredients = recipe.extendedIngredients {
            ingredientsLabel.attributedText = formatIngredientsList(ingredients)
        } else {
            ingredientsLabel.text = "Ingredients not available."
        }
    }



    
    // MARK: - Helpers
//    private func createInfoLabel(text: String) -> UILabel {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
//        label.textAlignment = .center
//        label.text = text
//        return label
//    }
    
    private static func createActionButton(title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return button
    }
    
    private func formatIngredientsList(_ ingredients: [Ingredient]) -> NSAttributedString {
        let formattedString = NSMutableAttributedString()
        let bullet = "• "
        ingredients.forEach { ingredient in
            let line = "\(bullet)\(ingredient.original)\n"
            let attributedLine = NSAttributedString(string: line, attributes: [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.darkGray
            ])
            formattedString.append(attributedLine)
        }
        return formattedString
    }
}

extension UIImageView {
    func loadImage(from url: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
    }
}
