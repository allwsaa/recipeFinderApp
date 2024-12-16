//
//  IngredientsViewController.swift
//  RecipeFinderApp
//
//  Created by Aisha Karzhauova on 16.12.2024.
//

import UIKit
import CoreData

class IngredientsViewController: UIViewController {
    
    var ingredients: [Ingredient] = []
    private var checkedIngredients: [String] = []
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private func fetchCheckedIngredients() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ShoppingItem")
        
        do {
            let results = try context.fetch(fetchRequest)
            checkedIngredients = results.compactMap { ($0 as? NSManagedObject)?.value(forKey: "name") as? String }
            tableView.reloadData()
        } catch {
            print("Failed to fetch checked ingredients: \(error)")
        }
    }
    
    private func saveCheckedIngredient(name: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "ShoppingItem", in: context)!
        let newItem = NSManagedObject(entity: entity, insertInto: context)
        newItem.setValue(name, forKey: "name")
        
        do {
            try context.save()
            print("Ingredient saved: \(name)")
            
            // Post a notification to inform the shopping list
            NotificationCenter.default.post(name: .shoppingListUpdated, object: nil)
        } catch {
            print("Failed to save ingredient: \(error)")
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Ingredients"
        view.backgroundColor = .white
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        fetchCheckedIngredients() // Preload checked ingredients from Core Data
    }

}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension IngredientsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let ingredient = ingredients[indexPath.row].original
        let isChecked = checkedIngredients.contains(ingredient)
        
        // Update the cell UI with checkmark or empty circle
        var content = cell.defaultContentConfiguration()
        content.text = ingredient
        content.image = UIImage(systemName: isChecked ? "checkmark.circle.fill" : "circle")
        content.imageProperties.tintColor = .systemBlue
        cell.contentConfiguration = content
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let ingredient = ingredients[indexPath.row].original

        if let index = checkedIngredients.firstIndex(of: ingredient) {
            checkedIngredients.remove(at: index)
            removeFromCoreData(ingredient)
        } else {
            checkedIngredients.append(ingredient)
            addIngredientToShoppingList(ingredient) // Replaces saveToCoreData
        }
        tableView.reloadData()
    }

}

// MARK: - Core Data
extension IngredientsViewController {
    
    private func addIngredientToShoppingList(_ ingredientName: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        // Check for duplicate
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ShoppingItem")
        fetchRequest.predicate = NSPredicate(format: "name == %@", ingredientName)
        
        do {
            let results = try context.fetch(fetchRequest)
            
            // If the ingredient already exists, exit early
            if !results.isEmpty {
                print("Ingredient already exists in shopping list: \(ingredientName)")
                return
            }
            
            // If no duplicate found, add to Core Data
            let entity = NSEntityDescription.entity(forEntityName: "ShoppingItem", in: context)!
            let newShoppingItem = NSManagedObject(entity: entity, insertInto: context)
            newShoppingItem.setValue(ingredientName, forKey: "name")
            newShoppingItem.setValue(true, forKey: "isChecked") // Default checked state

            try context.save()
            print("Added to shopping list: \(ingredientName)")

            // Post notification to refresh shopping list
            NotificationCenter.default.post(name: .shoppingListUpdated, object: nil)
        } catch {
            print("Failed to add ingredient to shopping list: \(error)")
        }
    }
    
    
    private func saveToCoreData(_ ingredient: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ShoppingItem")
        fetchRequest.predicate = NSPredicate(format: "name == %@", ingredient)

        do {
            let results = try context.fetch(fetchRequest)
            if results.isEmpty {
                let newItem = NSEntityDescription.insertNewObject(forEntityName: "ShoppingItem", into: context)
                newItem.setValue(ingredient, forKey: "name")
                newItem.setValue(true, forKey: "isChecked")
                try context.save()
                
                // Notify the shopping list VC
                NotificationCenter.default.post(name: .shoppingListUpdated, object: nil)
            }
        } catch {
            print("Error saving to Core Data: \(error)")
        }
    }


    private func removeFromCoreData(_ ingredient: String) {
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
            
            // Notify the shopping list VC
            NotificationCenter.default.post(name: .shoppingListUpdated, object: nil)
        } catch {
            print("Error removing from Core Data: \(error)")
        }
    }

}

