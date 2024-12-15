//
//  ViewController.swift
//  RecipeFinderApp
//
//  Created by ntvlbl on 13.12.2024.
//

//
//  ViewController.swift
//  RecipeFinderApp
//
//  Created by ntvlbl on 13.12.2024.
//

import UIKit
import SnapKit
import CoreData

class ViewController: UIViewController {

    private var recipes: [Recipe] = []
    private var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.separatorStyle = .none
        table.backgroundColor = .systemGroupedBackground
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
        searchController.searchBar.delegate = self

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filters",style: .plain, target: self, action: #selector(openFilters))

      
    
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

    private func addToFavorites(recipe: Recipe) {
        let fetchRequest: NSFetchRequest<RecipeEntity> = RecipeEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", recipe.id)

        do {
            let results = try context.fetch(fetchRequest)
            if !results.isEmpty {
                showNotification("Recipe already in Favorites!")
                return
            }
            
            let newFavorite = RecipeEntity(context: context)
            newFavorite.id = Int64(recipe.id)
            newFavorite.title = recipe.title
            newFavorite.image = recipe.image

            try context.save()
            showNotification("Added to Favorites!")
            
            NotificationCenter.default.post(name: NSNotification.Name("favoritesUpdated"), object: nil)
            
        } catch {
            print("Failed to add favorite: \(error.localizedDescription)")
        }
    }

    private func showNotification(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        self.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            alert.dismiss(animated: true)
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
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

    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let addToFavoritesAction = UIContextualAction(style: .normal, title: "Favorite") { [weak self] _, _, completionHandler in
            let recipe = self?.recipes[indexPath.row]
            if let recipe = recipe {
                self?.addToFavorites(recipe: recipe)
                completionHandler(true)
            }
        }
        addToFavoritesAction.backgroundColor = .systemGreen
        addToFavoritesAction.image = UIImage(systemName: "heart.fill")
        return UISwipeActionsConfiguration(actions: [addToFavoritesAction])
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
