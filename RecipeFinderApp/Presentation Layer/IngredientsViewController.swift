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
    
    private let addToShoppingListButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add to Shopping List", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.tintColor = .white
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(addToShoppingList), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Ingredients"
        view.backgroundColor = .white
        view.addSubview(tableView)
        view.addSubview(addToShoppingListButton)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(addToShoppingListButton.snp.top).offset(-10)
        }
        
        addToShoppingListButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(50)
        }
    }
    
    @objc private func addToShoppingList() {
        guard !checkedIngredients.isEmpty else {
            showAlert(title: "No Ingredients Selected", message: "Please select ingredients to add to the shopping list.")
            return
        }
        
        var addedIngredients = [String]()
        for ingredient in checkedIngredients {
            if addIngredientToCoreData(ingredient) {
                addedIngredients.append(ingredient)
            }
        }
        
        if addedIngredients.isEmpty {
            showAlert(title: "No New Ingredients Added", message: "All selected ingredients already exist in the shopping list.")
        } else {
            showAlert(title: "Ingredients Added", message: "\(addedIngredients.joined(separator: ", ")) added to the shopping list.")
        }
        
        checkedIngredients.removeAll()
        tableView.reloadData()
    }
    
    private func addIngredientToCoreData(_ ingredientName: String) -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ShoppingItem")
        fetchRequest.predicate = NSPredicate(format: "name == %@", ingredientName)
        
        do {
            let results = try context.fetch(fetchRequest)
            
            if !results.isEmpty {
                return false
            }
            
            let entity = NSEntityDescription.entity(forEntityName: "ShoppingItem", in: context)!
            let newShoppingItem = NSManagedObject(entity: entity, insertInto: context)
            newShoppingItem.setValue(ingredientName, forKey: "name")
            newShoppingItem.setValue(true, forKey: "isChecked") // Explicitly set isChecked
            
            try context.save()
            NotificationCenter.default.post(name: .shoppingListUpdated, object: nil)
            return true
        } catch {
            print("Failed to add ingredient: \(error)")
            return false
        }
    }

    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}


extension IngredientsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let ingredient = ingredients[indexPath.row].original
        let isChecked = checkedIngredients.contains(ingredient)
        
        var content = cell.defaultContentConfiguration()
        content.text = ingredient
        content.image = UIImage(systemName: isChecked ? "checkmark.circle.fill" : "circle")
        content.imageProperties.tintColor = .systemGreen
        cell.contentConfiguration = content
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let ingredient = ingredients[indexPath.row].original

        if let index = checkedIngredients.firstIndex(of: ingredient) {
            checkedIngredients.remove(at: index)
        } else {
            checkedIngredients.append(ingredient)
        }
        tableView.reloadData()
    }
}
