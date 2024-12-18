//
//  ShoppingListViewController.swift
//  RecipeFinderApp
//
//  Created by Aisha Karzhauova on 16.12.2024.
//

import UIKit
import CoreData

class ShoppingListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    private var shoppingItems: [String] = []
    private var selectedItems: Set<String> = []
    private let tableView = UITableView()
    
    private let selectAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select All", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.addTarget(self, action: #selector(selectAllItems), for: .touchUpInside)
        return button
    }()
    
    private let deleteAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Trash All", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.addTarget(self, action: #selector(trashAllItems), for: .touchUpInside)
        return button
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Shopping List"
        setupUI()
        fetchShoppingItems()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshShoppingList), name: .shoppingListUpdated, object: nil)
    }
    
 
    private func setupUI() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Select All",
            style: .plain,
            target: self,
            action: #selector(selectAllItems)
        )
        navigationItem.leftBarButtonItem?.setTitleTextAttributes(
            [.font: UIFont.boldSystemFont(ofSize: 16), .foregroundColor: UIColor.systemBlue],
            for: .normal
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "trash"),
            style: .plain,
            target: self,
            action: #selector(trashAllItems)
        )
        navigationItem.rightBarButtonItem?.tintColor = .red
        
  
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }


    @objc private func fetchShoppingItems() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ShoppingItem")
        
        do {
            let results = try context.fetch(fetchRequest)
            shoppingItems = results.compactMap { ($0 as? NSManagedObject)?.value(forKey: "name") as? String }
            selectedItems.removeAll()
            tableView.reloadData()
        } catch {
            print("Failed to fetch shopping list: \(error)")
        }
    }
    
    @objc private func refreshShoppingList() {
        fetchShoppingItems()
    }
    

    @objc private func selectAllItems() {
        if selectedItems.count == shoppingItems.count {
            selectedItems.removeAll()
            selectAllButton.setTitle("Select All", for: .normal)
        } else {
            selectedItems = Set(shoppingItems)
            selectAllButton.setTitle("Deselect All", for: .normal)
        }
        tableView.reloadData()
    }
    
   
    @objc private func trashAllItems() {
        let alert = UIAlertController(title: "Delete All Items?", message: "This action cannot be undone.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.deleteAllFromCoreData()
        }))
        present(alert, animated: true)
    }
    
    private func deleteAllFromCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ShoppingItem")
        
        do {
            let results = try context.fetch(fetchRequest)
            for result in results {
                context.delete(result as! NSManagedObject)
            }
            try context.save()
            shoppingItems.removeAll()
            selectedItems.removeAll()
            tableView.reloadData()
            print("All items deleted.")
        } catch {
            print("Failed to delete all items: \(error)")
        }
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let itemName = shoppingItems[indexPath.row]
        let isSelected = selectedItems.contains(itemName)
        
        var content = cell.defaultContentConfiguration()
        content.text = itemName
        content.image = UIImage(systemName: isSelected ? "checkmark.circle.fill" : "circle")
        content.imageProperties.tintColor = isSelected ? .systemBlue : .gray
        cell.contentConfiguration = content
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let itemName = shoppingItems[indexPath.row]
        
        if selectedItems.contains(itemName) {
            selectedItems.remove(itemName)
        } else {
            selectedItems.insert(itemName)
        }
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension Notification.Name {
    static let shoppingListUpdated = Notification.Name("shoppingListUpdated")
}

