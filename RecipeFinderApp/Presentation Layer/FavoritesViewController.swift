//
//  FavoritesViewController.swift
//  RecipeFinderApp
//
//  Created by ntvlbl on 15.12.2024.
//

import Foundation
import UIKit
import CoreData

class FavoritesViewController: UIViewController {

    private var favoriteRecipes: [RecipeEntity] = []
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(RecipeCell.self, forCellReuseIdentifier: "RecipeCell")
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Favorites"
        view.backgroundColor = .white
        setupUI()
        fetchFavorites()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshFavorites), name: NSNotification.Name("favoritesUpdated"), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupUI() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @objc private func refreshFavorites() {
        fetchFavorites()
    }

    private func fetchFavorites() {
        let request: NSFetchRequest<RecipeEntity> = RecipeEntity.fetchRequest()
        do {
            favoriteRecipes = try context.fetch(request)
            tableView.reloadData()
        } catch {
            print("Error fetching favorites: \(error.localizedDescription)")
        }
    }
}

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteRecipes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath) as! RecipeCell
        let recipe = favoriteRecipes[indexPath.row]
        cell.configure(with: Recipe(id: Int(recipe.id), title: recipe.title ?? "", image: recipe.image ?? ""))
        return cell
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
            self?.deleteFavorite(at: indexPath)
            completionHandler(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    private func deleteFavorite(at indexPath: IndexPath) {
        let recipeToDelete = favoriteRecipes[indexPath.row]
        context.delete(recipeToDelete)

        do {
            try context.save()
            favoriteRecipes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch {
            print("Failed to delete favorite: \(error.localizedDescription)")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // Deselect the cell
        
        // Retrieve the selected recipe
        let selectedRecipe = favoriteRecipes[indexPath.row]
        
        // Initialize the RecipeDetailViewController with the recipe's ID
        let detailVC = RecipeDetailViewController(recipeID: Int(selectedRecipe.id))
        
        // Push the detail view controller onto the navigation stack
        navigationController?.pushViewController(detailVC, animated: true)
    }

}
