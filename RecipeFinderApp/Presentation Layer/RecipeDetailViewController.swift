//
//  RecipeDetailViewController.swift
//  RecipeFinderApp
//
//  Created by ntvlbl on 13.12.2024.
//

import UIKit
import SnapKit

class RecipeDetailViewController: UIViewController {
    
    private let recipeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .leading
        return stackView
    }()
    
    private let ingredientsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    var recipeID: Int
    private var recipeDetail: RecipeDetail?

    init(recipeID: Int) {
        self.recipeID = recipeID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        fetchRecipeDetail()
    }


    private func setupUI() {

        view.addSubview(recipeImageView)
        view.addSubview(titleLabel)
        view.addSubview(infoStackView)
        view.addSubview(ingredientsLabel)
        

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

        infoStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        ingredientsLabel.snp.makeConstraints { make in
            make.top.equalTo(infoStackView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }

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

        infoStackView.addArrangedSubview(createInfoLabel(text: "Health Score: \(recipe.healthScore ?? 0)"))
        infoStackView.addArrangedSubview(createInfoLabel(text: "Ready in: \(recipe.readyInMinutes ?? 0) minutes"))
        infoStackView.addArrangedSubview(createInfoLabel(text: "Servings: \(recipe.servings ?? 0)"))

        let veganText = recipe.vegan == true ? "Yes" : "No"
        let glutenFreeText = recipe.glutenFree == true ? "Yes" : "No"

        infoStackView.addArrangedSubview(createInfoLabel(text: "Vegan: \(veganText)"))
        infoStackView.addArrangedSubview(createInfoLabel(text: "Gluten-Free: \(glutenFreeText)"))

        if let ingredients = recipe.extendedIngredients {
            ingredientsLabel.text = "Ingredients:\n" + ingredients.map { $0.original ?? "Unknown ingredient" }.joined(separator: "\n")
        } else {
            ingredientsLabel.text = "Ingredients not available."
        }
    }



    private func createInfoLabel(text: String) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = text
        return label
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
