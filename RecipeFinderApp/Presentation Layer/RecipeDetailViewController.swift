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
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    private let contentView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        return stackView
    }()
    
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
    
    private let caloriesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .left
        return label
    }()
    
    private let stepsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textColor = .black
        return label
    }()
    
    private let stepLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .left
        label.text = "Steps: "
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
    
    private let rowThree: UIStackView = {
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
        // Add scrollView and contentView
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // Setup scrollView constraints
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        // Setup contentView constraints
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide) // Ensure contentView matches scrollView width
        }

        // Add UI components to contentView
        contentView.addArrangedSubview(recipeImageView)
        contentView.addArrangedSubview(titleLabel)
        contentView.addArrangedSubview(caloriesLabel)
        contentView.addArrangedSubview(infoContainer)
        contentView.addArrangedSubview(stepLabel)
        contentView.addArrangedSubview(stepsLabel)
        contentView.addArrangedSubview(showIngredientsButton)

        // Add rows to infoContainer
        infoContainer.addArrangedSubview(rowOne)
        infoContainer.addArrangedSubview(rowTwo)
        infoContainer.addArrangedSubview(rowThree)

        // Recipe Image
        recipeImageView.snp.makeConstraints { make in
            make.height.equalTo(200)   // Fixed height
            make.width.equalTo(300)    // Fixed width
            make.centerX.equalToSuperview() // Center horizontally
        }

        // Title Label
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
        }

        // Calories Label
        caloriesLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
        }

        // InfoContainer
        infoContainer.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
        }

        // Step Title Label
        stepLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
        }

        // Steps Content Label
        stepsLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
        }

        // Show Ingredients Button
        showIngredientsButton.snp.makeConstraints { make in
            make.height.equalTo(44) // Button height
            make.leading.trailing.equalToSuperview().inset(20)
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
    
    
    private func configureUI() {
        guard let recipe = recipeDetail else { return }

        titleLabel.text = recipe.title

        if let imageUrl = URL(string: recipe.image) {
            recipeImageView.loadImage(from: imageUrl)
        }
        
        

        // Clear existing arrangedSubviews to avoid duplicates
        rowOne.arrangedSubviews.forEach { $0.removeFromSuperview() }
        rowTwo.arrangedSubviews.forEach { $0.removeFromSuperview() }
        rowThree.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add labels to rowOne
        rowTwo.addArrangedSubview(createInfoLabel(text: "Skill: Easy"))
        rowTwo.addArrangedSubview(createInfoLabel(text: "Time: \(recipe.readyInMinutes ?? 0) min"))
        rowTwo.addArrangedSubview(createInfoLabel(text: "⭐ \(recipe.healthScore ?? 0)"))

        // Add labels to rowTwo
        let servingsLabel = createInfoLabel(text: "Servings: \(recipe.servings ?? 0)")
        let veganLabel = createInfoLabel(text: "Vegan: \(recipe.vegan == true ? "Yes" : "No")")
        let glutenFreeLabel = createInfoLabel(text: "Gluten-Free: \(recipe.glutenFree == true ? "Yes" : "No")")

        rowThree.addArrangedSubview(servingsLabel)
        rowThree.addArrangedSubview(veganLabel)
        rowThree.addArrangedSubview(glutenFreeLabel)
        
        if let nutrients = recipe.nutrition?.nutrients {
            if let calories = nutrients.first(where: { $0.name == "Calories" }) {
                caloriesLabel.text = "Calories: \(calories.amount) \(calories.unit)"
                print(calories.amount)
            }
            if let fat = nutrients.first(where: { $0.name == "Fat" }) {
                rowOne.addArrangedSubview(createInfoLabel(text: "Fat: \(fat.amount) \(fat.unit)"))
            }
            if let carbs = nutrients.first(where: { $0.name == "Carbohydrates" }) {
                rowOne.addArrangedSubview(createInfoLabel(text: "Carbs: \(carbs.amount) \(carbs.unit)"))
            }
            if let protein = nutrients.first(where: { $0.name == "Protein" }) {
                rowOne.addArrangedSubview(createInfoLabel(text: "Protein: \(protein.amount) \(protein.unit)"))
            }
        }
        
        if let analyzedInstructions = recipe.analyzedInstructions?.first?.steps {
            let stepsText = analyzedInstructions.enumerated().map { index, step in
                return "Step \(index + 1): \(step.step)"
            }.joined(separator: "\n\n")
            stepsLabel.text = stepsText
        } else {
            stepsLabel.text = "Steps are not available."
        }

//        // Update ingredients
//        if let ingredients = recipe.extendedIngredients {
//            ingredientsLabel.attributedText = formatIngredientsList(ingredients)
//        } else {
//            ingredientsLabel.text = "Ingredients not available."
//        }
    }
    
    private let showIngredientsButton: UIButton = {
        let button = UIButton()
        button.setTitle("Show Ingredient List", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(showIngredients), for: .touchUpInside)
        return button
    }()
    @objc private func showIngredients() {
        let ingredientsVC = IngredientsViewController()
        ingredientsVC.ingredients = recipeDetail?.extendedIngredients ?? []
        let navController = UINavigationController(rootViewController: ingredientsVC)
        present(navController, animated: true)
    }



    
    // MARK: - Helpers
//    private func createInfoLabel(text: String) -> UILabel {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
//        label.textAlignment = .center
//        label.text = text
//        return label
//    }
    
    private func createInfoLabel(text: String) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.text = text
        label.textAlignment = .left
        label.textColor = .black
        return label
    }
    
//    private static func createActionButton(title: String) -> UIButton {
//        let button = UIButton()
//        button.setTitle(title, for: .normal)
//        button.backgroundColor = .systemGreen
//        button.setTitleColor(.white, for: .normal)
//        button.layer.cornerRadius = 8
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
//        return button
//    }
    
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
