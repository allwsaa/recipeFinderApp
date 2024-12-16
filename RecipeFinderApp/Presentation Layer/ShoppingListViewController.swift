//
//  ShoppingListViewController.swift
//  RecipeFinderApp
//
//  Created by Aisha Karzhauova on 16.12.2024.
//

import UIKit
import CoreData

class ShoppingListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
    private var shoppingItems: [String] = []
    private let tableView = UITableView()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Shopping List"
        setupTableView()
        fetchShoppingItems()
        
        // Listen for updates from NotificationCenter
        NotificationCenter.default.addObserver(self, selector: #selector(refreshShoppingList), name: .shoppingListUpdated, object: nil)
    }

    // MARK: - Setup UI
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Core Data Fetch
    @objc private func fetchShoppingItems() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ShoppingItem")
        fetchRequest.predicate = NSPredicate(format: "isChecked == YES")
        
        do {
            let results = try context.fetch(fetchRequest)
            shoppingItems = results.compactMap { ($0 as? NSManagedObject)?.value(forKey: "name") as? String }
            tableView.reloadData()
        } catch {
            print("Failed to fetch shopping list: \(error)")
        }
    }
    
    @objc private func refreshShoppingList() {
        fetchShoppingItems()
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = shoppingItems[indexPath.row]
        return cell
    }
    
    // MARK: - Swipe to Delete
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            let ingredientToDelete = self.shoppingItems[indexPath.row]
            self.deleteFromCoreData(ingredient: ingredientToDelete)
            self.shoppingItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completionHandler(true)
        }
        deleteAction.backgroundColor = .red
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
    
    // MARK: - Delete from Core Data
    private func deleteFromCoreData(ingredient: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ShoppingItem")
        fetchRequest.predicate = NSPredicate(format: "name == %@", ingredient)
        
        do {
            let results = try context.fetch(fetchRequest)
            for result in results {
                context.delete(result as! NSManagedObject)
            }
            try context.save()
            print("Deleted ingredient: \(ingredient)")
        } catch {
            print("Failed to delete ingredient: \(error)")
        }
    }
}


extension Notification.Name {
    static let shoppingListUpdated = Notification.Name("shoppingListUpdated")
}
