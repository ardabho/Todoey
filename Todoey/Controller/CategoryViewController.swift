//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Arda Büyükhatipoğlu on 24.04.2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
    }
    
    // MARK: - Table view data source methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categories?[indexPath.row] {
            cell.textLabel?.text = category.name
            cell.backgroundColor = UIColor(hexString: category.categoryColor)
            cell.textLabel?.textColor = ContrastColorOf(UIColor(hexString: category.categoryColor)!, returnFlat: true)
        } else {
            cell.textLabel?.text = "No categories added yet"
            cell.backgroundColor = UIColor.flatRed()
        }
        
        
        return cell
    }
    
    //MARK: - Table view Delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "GoToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexpath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexpath.row]
        }
    }
    
    //MARK: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        super.updateModel(at: indexPath)
        
        if let categoryForDeletion = categories?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(categoryForDeletion)
                }
            } catch {
                print("Error deleting category \(error)")
            }
        }
    }
    
    //MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { Action in
            let newCategory = Category()
            
            newCategory.name = textField.text!
            
            newCategory.categoryColor = RandomFlatColor().hexValue()
            
            self.save(category: newCategory)
            
            self.tableView.reloadData()
        }
        
        alert.addAction(action)
        
        alert.addTextField { field in
            textField = field
            textField.placeholder = "Add new Category"
        }
        
        present(alert, animated: true, completion: nil)
    }
    //MARK: - Data Manipulation Methods
    
    func save(category: Category) {
        
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving Category \(error)")
        }
        
    }
    
    func loadCategories() {
        
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
}
