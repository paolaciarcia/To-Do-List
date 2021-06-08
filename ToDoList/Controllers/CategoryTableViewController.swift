//
//  CategoryTableViewController.swift
//  ToDoList
//
//  Created by Erick Borges on 02/06/21.
//

import UIKit
import CoreData
import ChameleonFramework

class CategoryTableViewController: SwipeTableViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var addItems: UIBarButtonItem!
    @IBOutlet weak var searchItems: UISearchBar!

    
    //MARK: - Properties
    var categories = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext


    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let navBar = navigationController?.navigationBar else { fatalError("Navigation controller does not exist")}
        let navBarAppearence = UINavigationBarAppearance()
        navBarAppearence.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearence.backgroundColor = UIColor(hexString: "6E92D2")
        navBar.standardAppearance = navBarAppearence
        navBar.scrollEdgeAppearance = navBarAppearence
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
            
            let hexColor = UIColor.randomFlat().hexValue()
            newCategory.color = hexColor
            
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
    
    override func updateModel(at indexPath: IndexPath) {
        self.context.delete(self.categories[indexPath.row])
        self.categories.remove(at: indexPath.row)
        
        do {
            try self.context.save()
        } catch {
            print("Error deleting category: \(error)")
        }
    }

    // MARK: - TableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let item = categories[indexPath.row]
        cell.textLabel?.text = item.name
        
        let color = UIColor(hexString: categories[indexPath.row].color ?? "6E92D2")
        cell.textLabel?.textColor = ContrastColorOf(color ?? .black, returnFlat: true)
        cell.backgroundColor = color

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


