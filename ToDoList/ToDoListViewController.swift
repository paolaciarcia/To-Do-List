//
//  ViewController.swift
//  ToDoList
//
//  Created by Erick Borges on 31/05/21.
//

import UIKit

class ToDoListViewController: UITableViewController {
    
    @IBOutlet weak var addNewItem: UIBarButtonItem!
    
    var itemArray = [Item]()
    
    //1 - persistir dados
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var newItem = Item()
        newItem.title = "Shopping"
        itemArray.append(newItem)
        
        var newItem2 = Item()
        newItem2.title = "Buy"
        itemArray.append(newItem2)
        
        var newItem3 = Item()
        newItem3.title = "do something"
        itemArray.append(newItem3)
       
        
        //4 - persistir dados
//        if let items = userDefaults.array(forKey: "ToDoListArray") as? [Item] {
//            itemArray = items
//        }
    }
    
    @IBAction func addButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        var tf = UITextField()
        
        alert.addTextField { (textField) in
            textField.placeholder = "Create new item"
            
            tf = textField
        
        }
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            print("success")
            print(tf.text!)
            
            var newItem = Item()
            newItem.title = tf.text!
            
            if tf.text != "" {
                self.itemArray.append(newItem)
            } else {
                self.itemArray.append(Item())
            }
            
            //2 - persistir dados | 3 - AppDelegate
            self.userDefaults.set(self.itemArray, forKey: "ToDoListArray")
            self.tableView.reloadData()
        }
    
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
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
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}
