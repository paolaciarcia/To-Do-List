//
//  CategoryTableViewController.swift
//  ToDoList
//
//  Created by Erick Borges on 02/06/21.
//

import UIKit
import CoreData
import SwipeCellKit

class CategoryTableViewController: UITableViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var addItems: UIBarButtonItem!
    @IBOutlet weak var searchItems: UISearchBar!
    
    //MARK: - Properties
    var categories = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchItems.delegate = self
        
        loadCategories()
        
        tableView.rowHeight = 80.0
    }
    
    //MARK: - IBActions
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        var tf = UITextField()
        
        alert.addTextField { (textField) in
            textField.placeholder = "Create new category"
            
            tf = textField
        }
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newCategory = Category(context: self.context)
            newCategory.name = tf.text!
            
            self.categories.append(newCategory)
            self.saveCategories()
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Methods
    
    func saveCategories() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error loading data from \(error)")
        }
        
        tableView.reloadData()
    }

    // MARK: - TableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! SwipeTableViewCell
        
        let item = categories[indexPath.row]
        
        cell.textLabel?.text = item.name
        
        cell.delegate = self
    
        return cell
    }

    // MARK: - TableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        saveCategories()
        
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let itemsViewController = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            itemsViewController.selectedCategory = categories[indexPath.row]
        }
    }
}

extension CategoryTableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        guard searchBar.text != nil else { return }
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadCategories(with: request)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadCategories()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

// MARK: - SwipeTableViewCellDelegate
extension CategoryTableViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            
            self.context.delete(self.categories[indexPath.row])
            self.categories.remove(at: indexPath.row)
                
                do {
                    try self.context.save()
                } catch {
                    print("Error deleting category: \(error)")
                }
            
                tableView.reloadData()
            }

            // customize the action appearance
            deleteAction.image = UIImage(named: "delete-icon")

            return [deleteAction]
    }
    
    
}
