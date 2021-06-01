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
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("items.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
            print("success")
            print(tf.text!)
            
            var newItem = Item()
            newItem.title = tf.text!
            
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
        //2 - persistir dados
        let encoder = PropertyListEncoder()
        
        //3 - persistir dados
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        } catch {
            print("Error enconding item array, \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadItems() {
        //4 - persistir dados
        //obs: colocar o objeto Item como Codable
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print(error)
            }
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
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}
