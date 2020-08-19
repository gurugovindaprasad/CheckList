//
//  ViewController.swift
//  CheckList
//
//  Created by Guru Ranganathan on 8/19/20.
//  Copyright © 2020 Guru. All rights reserved.
//

import CoreData
import UIKit

class CheckListViewController: UITableViewController,NSFetchedResultsControllerDelegate {
    
    let checklists =  [Checklist]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var fetchedResultsController: NSFetchedResultsController<Checklist>!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title  = "CheckList"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem))
        navigationItem.leftBarButtonItem = editButtonItem
        
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteItems))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        navigationController?.toolbar.isHidden = true
        toolbarItems = [flexibleSpace, deleteButton]
        
        
        tableView.allowsMultipleSelectionDuringEditing = true
        
        fetchItems()
    }
    
    
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
        if editing {
             navigationController?.toolbar.isHidden = false
        }else{
             navigationController?.toolbar.isHidden = true
        }
        
    }
    
    func fetchItems() {
        
        if fetchedResultsController == nil {
            let checklistRequest = Checklist.createFetchRequest()
            checklistRequest.fetchBatchSize = 20
            
            let sort = NSSortDescriptor(key: "date", ascending: false)
            checklistRequest.sortDescriptors = [sort]
            
            fetchedResultsController = NSFetchedResultsController(fetchRequest: checklistRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        }
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch  {
            print("error \(error.localizedDescription)")
        }
        
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        let sectionInfo = fetchedResultsController.sections![section]
        
        return sectionInfo.numberOfObjects
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "checklist", for: indexPath)
        
        let checklist = fetchedResultsController.object(at: indexPath)
        
        cell.textLabel?.attributedText = nil
        
        if checklist.isDone == true {
            cell.textLabel?.attributedText = makeAttributedString(for: checklist.item)
        }else {
             cell.textLabel?.text = checklist.item
        }
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditing {
            return
        }else {
            let item = fetchedResultsController.object(at: indexPath)
            item.isDone = item.isDone ? false: true
            try? context.save()
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let item = fetchedResultsController.object(at: indexPath)
            context.delete(item)
            try? context.save()
            
        }
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "detail") as? DetailTableViewController {
            vc.item = fetchedResultsController.object(at: indexPath)
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    
    @objc func addItem() {
        
        let alertController = UIAlertController(title: "Add Item", message: nil, preferredStyle: .alert)
        alertController.addTextField()
        
        alertController.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self,  alertController] _ in
            
            if let text = alertController.textFields?[0].text  {
                
                let checkList = Checklist(context: (self?.context)!)
                checkList.item = text
                checkList.date = Date()
                checkList.isDone = false
                do {
                    try self?.context.save()
                }catch {
                    print(error.localizedDescription)
                }
            }
            
            
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }
    
    @objc func deleteItems() {
        
        if let selectedItems = tableView.indexPathsForSelectedRows {
        
            for indexPath in selectedItems.reversed() {
                let item = fetchedResultsController.object(at: indexPath)
                context.delete(item)
                try? context.save()
            }
        }
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            tableView.reloadData()
        case .delete:
            tableView.reloadData()
        case .update:
            tableView.reloadData()
        default:
            break
        }
        
    }
    
    
    func makeAttributedString(for item:String) -> NSAttributedString {
           let itemAttributes: [NSAttributedString.Key: Any] = [
                  .strikethroughStyle: true,
                  .strikethroughColor: UIColor.red
              ]
        
         return  NSAttributedString(string: item, attributes: itemAttributes)
    }
    
    
}

