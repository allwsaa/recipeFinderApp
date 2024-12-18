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
    private var isLoading = false
    private var currentOffset = 0
    private let pageSize = 10

    private var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }

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
        guard !isLoading else { return }
        isLoading = true
        
        NetworkManager.shared.fetchRecipes(offset: currentOffset, number: pageSize) { [weak self] newRecipes, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                if let newRecipes = newRecipes, !newRecipes.isEmpty {
                    self.recipes.append(contentsOf: newRecipes)
                    self.currentOffset += self.pageSize
                    self.tableView.reloadData()
                } else if let error = error {
                    print("Error fetching recipes: \(error.localizedDescription)")
                } else {
                    print("No more recipes to load.")
                }
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
        if let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath) as? RecipeCell {
            let recipe = recipes[indexPath.row]
            cell.configure(with: recipe)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == recipes.count - 1 && !isLoading {
            fetchRecipes()
        }
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
    func applyFilters(filters: [String: String], sortOption: String?) {
        NetworkManager.shared.fetchRecipes(filters: filters) { [weak self] recipes, error in
            if let error = error {
                print("Error applying filters: \(error)")
                return
            }
            self?.recipes = recipes ?? []

            if let sortOption = sortOption {
                switch sortOption {
                case "cookingTime":
                    self?.recipes.sort { ($0.readyInMinutes ?? 0) < ($1.readyInMinutes ?? 0) }
                case "calories":
                    self?.recipes.sort {
                        let calories1 = $0.nutrition?.nutrients.first(where: { $0.name.lowercased() == "calories" })?.amount ?? 0
                        let calories2 = $1.nutrition?.nutrients.first(where: { $0.name.lowercased() == "calories" })?.amount ?? 0
                        print("Calories1: \(calories1), Calories2: \(calories2)") // Debug output
                        return calories1 < calories2
                    }
                default:
                    break
                }
            }

            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}
