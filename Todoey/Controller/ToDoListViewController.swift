//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework


class ToDoListViewController: SwipeTableViewController {
    
    var toDoItems : Results<Item>?
    @IBOutlet weak var itemSearchBar: UISearchBar!
    
    let realm = try! Realm()
    
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(hexString: selectedCategory!.categoryColor)
        self.navigationItem.standardAppearance = navBarAppearance
        self.navigationItem.scrollEdgeAppearance = navigationItem.standardAppearance
        self.navigationItem.title = selectedCategory?.name
        
        navigationController?.navigationBar.tintColor = ContrastColorOf(UIColor(hexString: selectedCategory!.categoryColor)!, returnFlat: true)
        navigationController?.navigationBar.largeTitleTextAttributes = [ NSAttributedString.Key.foregroundColor : ContrastColorOf(UIColor(hexString: selectedCategory!.categoryColor)!, returnFlat: true)]
        
        itemSearchBar.barTintColor = UIColor(hexString: selectedCategory!.categoryColor)
        itemSearchBar.searchTextField.backgroundColor = .white
        
    }
    
    //MARK: - TableView Data Source Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return toDoItems?.count ?? 1
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = toDoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.completion ? .checkmark : .none
            let categoryColour = UIColor(hexString: selectedCategory!.categoryColor)
            
            if let colour = categoryColour?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(toDoItems!.count)) {
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
            
        } else {
            cell.textLabel?.text = "No Items Added"
            cell.backgroundColor = UIColor.flatRed()
        }
        
        return cell
    }
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = toDoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.completion = !item.completion
                }
            } catch {
                print("Error saving done status \(error)")
            }
        }
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //Add Button
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            
            if let currentCategory = self.selectedCategory {
                
                do {
                    try self.realm.write {
                        
                        if let safeText = textField.text {
                            if safeText != "" {
                                
                                let item = Item()
                                item.title = safeText
                                item.dateCreated = Date()
                                currentCategory.items.append(item)
                            }
                        }
                    }
                } catch {
                    print("Error while writing to realm \(error)")
                }
            }
            self.tableView.reloadData()
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model Manipulation Methods
    
    func loadItems() {
        
        toDoItems =  selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
        
    }
    
    //MARK: - Delete data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        super.updateModel(at: indexPath)
        
        if let itemForDeletion = toDoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(itemForDeletion)
                }
            } catch {
                print("Error deleting category \(error)")
            }
        }
    }
    
}
//MARK: - Search Bar Methods

extension ToDoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: false)
        
        tableView.reloadData()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
