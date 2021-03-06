//
//  ViewController.swift
//  ToDoList
//
//  Created by Erick Borges on 31/05/21.
//

import UIKit
import CoreData
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {
    
    //MARK: - IBOutlet
    @IBOutlet weak var addNewItem: UIBarButtonItem!
    @IBOutlet weak var searchItems: UISearchBar!
    
    //MARK: - Properties
    var itemArray = [Item]()
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }

    //1 - persistir dados
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchItems.delegate = self
        tableView.separatorStyle = .none
    
        //4 - persistir dados
        print("open this file\(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let colorHex = selectedCategory?.color {
            let navBarAppearence = UINavigationBarAppearance()
            let contrastColor = ContrastColorOf(UIColor(hexString: colorHex) ?? .cyan, returnFlat: true)
            guard let navBar = navigationController?.navigationBar else { fatalError("Navigation controller does not exist")}
            title = selectedCategory!.name
            navBarAppearence.largeTitleTextAttributes = [.foregroundColor: contrastColor]
            navBarAppearence.backgroundColor = UIColor(hexString: colorHex)
            navBar.standardAppearance = navBarAppearence
            navBar.scrollEdgeAppearance = navBarAppearence
            navBar.tintColor = contrastColor
        }
    }
    
    //MARK: - IBActions
    @IBAction func addButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        var tf = UITextField()
        
        alert.addTextField { (textField) in
            textField.placeholder = "Create new item"
            
            tf = textField
        }
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            //2 - persistir dados | iniciar configurando o AppDelegate e incluindo o DataModel.xcdatamodeld
            let newItem = Item(context: self.context)
            newItem.title = tf.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            
            if tf.text != "" {
                self.itemArray.append(newItem)
            } else {
                self.itemArray.append(Item())
            }
            self.saveItems()
        }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Methods
    func saveItems() {
        
        //3 - persistir dados
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        //5 - persistir dados
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error loading data from \(error)")
        }
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        self.context.delete(self.itemArray[indexPath.row])
        self.itemArray.remove(at: indexPath.row)
        print("entrou no updateModel")
        do {
            try self.context.save()
        } catch {
            print("Error deleting category: \(error)")
        }
    }
    
    //MARK: - TableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        
        let iP = CGFloat(indexPath.row)
        let iA = CGFloat(itemArray.count)
        if let color = UIColor(hexString: selectedCategory!.color!)?.darken(byPercentage: iP / iA) {
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(color , returnFlat: true)
            
            cell.accessoryType = item.done ? .checkmark : .none
        }
        return cell
    }
    
    //MARK: - TableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //remover a linha da tableview e do CoreData
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}

//MARK: - UISearchBarDelegate
extension ToDoListViewController: UISearchBarDelegate {
    
    //pesquisar items na tableView com UISearchBar
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        
        guard searchBar.text != nil else { return }
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
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
