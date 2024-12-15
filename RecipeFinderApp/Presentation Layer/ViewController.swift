//
//  ViewController.swift
//  RecipeFinderApp
//
//  Created by ntvlbl on 13.12.2024.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    private var recipes: [Recipe] = []

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.separatorStyle = .none
        table.backgroundColor = .systemGroupedBackground
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 200
        return table
    }()

    private let searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.searchBar.placeholder = "Search recipes..."
        return search
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchRecipes()
    }

    private func setupUI() {
        title = "Recipes"
        view.backgroundColor = .white

        navigationItem.searchController = searchController
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filters", style: .plain, target: self, action: #selector(openFilters))
        searchController.searchBar.delegate = self

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RecipeCell.self, forCellReuseIdentifier: "RecipeCell")

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @objc private func openFilters() {
        let filterVC = FilterViewController()
        filterVC.delegate = self
        navigationController?.pushViewController(filterVC, animated: true)
    }

    private func fetchRecipes() {
        NetworkManager.shared.fetchRecipes { [weak self] recipes, error in
            if let error = error {
                print("Error fetching recipes: \(error)")
                return
            }
            self?.recipes = recipes ?? []
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 180
//    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

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
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.isEmpty else { return }
        let ingredients = query.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
        NetworkManager.shared.fetchRecipes(by: ingredients) { [weak self] recipes, error in
            if let error = error {
                print("Error fetching recipes: \(error)")
                return
            }
            self?.recipes = recipes ?? []
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}

extension ViewController: FilterViewControllerDelegate {
    func applyFilters(filters: [String: String]) {
        NetworkManager.shared.fetchRecipes(filters: filters) { [weak self] recipes, error in
            if let error = error {
                print("Error applying filters: \(error)")
                return
            }
            self?.recipes = recipes ?? []
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}
