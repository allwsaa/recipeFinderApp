//
//  IngredientsSearchViewController.swift
//  RecipeFinderApp
//
//  Created by ntvlbl on 15.12.2024.
//

import Foundation
import UIKit
import SnapKit

class IngredientsSearchViewController: UIViewController {

    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter ingredients (comma separated)"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        return textField
    }()

    private let searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Search Recipes", for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 8
        button.tintColor = .white
        return button
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(RecipeCell.self, forCellReuseIdentifier: "RecipeCell")
        tableView.isHidden = true
        tableView.separatorStyle = .none
        return tableView
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Search results will appear here..."
        label.textAlignment = .center
        label.textColor = .gray
        label.numberOfLines = 0
        return label
    }()

    
    private var recipes: [Recipe] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Search Recipes"

        setupUI()
        setupActions()
        setupTableView()
    }

    
    private func setupUI() {
        view.addSubview(searchTextField)
        view.addSubview(searchButton)
        view.addSubview(messageLabel)
        view.addSubview(tableView)

        searchTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        searchButton.snp.makeConstraints { make in
            make.top.equalTo(searchTextField.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(200)
        }

        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(searchButton.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchButton.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func setupActions() {
        searchButton.addTarget(self, action: #selector(searchRecipes), for: .touchUpInside)
    }

    
    @objc private func searchRecipes() {
        guard let ingredients = searchTextField.text, !ingredients.isEmpty else {
            showMessage("Please enter ingredients to search.")
            return
        }

        let ingredientsArray = ingredients.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        showMessage("Searching for recipes...")

        NetworkManager.shared.fetchRecipes(by: ingredientsArray) { [weak self] recipes, error in
            if let error = error {
                print("Error fetching recipes: \(error)")
                self?.showMessage("Failed to fetch recipes. Please try again.")
                return
            }

            self?.recipes = recipes ?? []
            DispatchQueue.main.async {
                if self?.recipes.isEmpty == true {
                    self?.showMessage("No recipes found for the given ingredients.")
                } else {
                    self?.messageLabel.isHidden = true
                    self?.tableView.isHidden = false
                    self?.tableView.reloadData()
                }
            }
        }
    }

    private func showMessage(_ message: String) {
        messageLabel.text = message
        messageLabel.isHidden = false
        tableView.isHidden = true
    }
}


extension IngredientsSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath) as! RecipeCell
        let recipe = recipes[indexPath.row]
        cell.configure(with: recipe)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRecipe = recipes[indexPath.row]
        let detailVC = RecipeDetailViewController(recipeID: selectedRecipe.id)
        detailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
