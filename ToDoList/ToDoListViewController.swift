//
//  ViewController.swift
//  ToDoList
//
//  Created by Erick Borges on 31/05/21.
//

import UIKit

class ToDoListViewController: UITableViewController {
    
    @IBOutlet weak var addNewiTEM: UIBarButtonItem!
    
    
    var itemArray = ["Study", "Go to gym", "Watch TV", "Talk with mom"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            
            if tf.text != "" {
                self.itemArray.append(tf.text!)
            } else {
                self.itemArray.append("New item")
            }
            
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
        cell.textLabel?.text = itemArray[indexPath.row]
        
        return cell
    }
    
    //MARK: - TableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        let selectedRow = tableView.cellForRow(at: indexPath)

        switch selectedRow?.accessoryType {
        case .checkmark:
            selectedRow?.accessoryType = .none
        default:
            selectedRow?.accessoryType = .checkmark
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
      
    }
    
}

