//
//  ViewController.swift
//  ToDoList
//
//  Created by Erick Borges on 31/05/21.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    
    @IBOutlet weak var addNewItem: UIBarButtonItem!
    
    var itemArray = [Item]()

    //1 - persistir dados
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //4 - persistir dados
        print("open this file\(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))")
        loadItems()
    }
    
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
    
    func saveItems() {
        
        //3 - persistir dados
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadItems() {
        //5 - persistir dados
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from \(error)")
        }
    }
    
    //MARK: - TableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none

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
