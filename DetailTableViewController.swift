//
//  DetailTableViewController.swift
//  CheckList
//
//  Created by Guru Ranganathan on 8/19/20.
//  Copyright © 2020 Guru. All rights reserved.
//

import UIKit


class DetailTableViewController: UITableViewController {
    
    @IBOutlet weak var textField: UITextField!
    var item: Checklist?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
         title  = "Edit Item"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(updateItem))

        if let checklist = item {
            
            textField.text = checklist.item
            
        }

    }
    
    @objc func updateItem() {
        
        if let text = textField.text, !text.isEmpty{
            item?.item = text
            try? context.save()
            navigationController?.popViewController(animated: true)
        }
        
        
    }

}
