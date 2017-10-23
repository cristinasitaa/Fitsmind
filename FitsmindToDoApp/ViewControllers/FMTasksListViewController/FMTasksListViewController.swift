//
//  FMNotesListViewController.swift
//  FitsmindToDoApp
//
//  Created by Cristina on 22/10/2017.
//  Copyright © 2017 Cristina. All rights reserved.
//

import UIKit
import RealmSwift

class FMTasksListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
   
    @IBOutlet weak var tableView: UITableView!
  
    @IBOutlet weak var searchBar: UISearchBar!
    
    var tasks : Results<FMTask>!
    
    var isEditingMode = false {
        didSet {
            if (isEditingMode) {
                self.navigationController?.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.didClickOnEditButton(_:)))
            } else {
                self.navigationController?.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.didClickOnEditButton(_:)))
            }
        }
    }
    
    var shouldShowSearchResults = false
    
    var currentCreateAction:UIAlertAction!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "taskCell")
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.didClickOnAddButton))
        self.navigationController?.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.didClickOnEditButton(_:)))
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        readTasks()
    }
    
    func readTasks(){
        tasks = FMDataManager.sharedInstance.getTasks()
        self.tableView.setEditing(false, animated: true)
        self.isEditingMode = false
        self.tableView.reloadData()
    }
    
    // MARK: - User Actions -
    
    
    @IBAction func didSelectSortCriteria(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            self.tasks = self.tasks.sorted(byKeyPath: "createdAt", ascending: false)
        }
        else{
            self.tasks = self.tasks.sorted(byKeyPath: "priorityRaw")
        }
        self.tableView.reloadData()
    }
    
    @IBAction func didClickOnEditButton(_ sender: UIBarButtonItem) {
        isEditingMode = !isEditingMode
        
        self.tableView.setEditing(isEditingMode, animated: true)
    }
    
    @IBAction func didClickOnAddButton(_ sender: UIBarButtonItem) {
        displayAlertToAddTask(nil)
    }
    
    @objc func taskNameFieldDidChange(_ textField:UITextField){
        self.currentCreateAction.isEnabled = (textField.text?.characters.count)! > 0
    }
    
    @objc func taskPriorityFieldDidChange(_ textField:UITextField){
        self.currentCreateAction.isEnabled = (textField.text?.characters.count)! > 0
    }
    
    func displayAlertToAddTask(_ updatedTask:FMTask!){
        
        var title = "New Task"
        var doneTitle = "Create"
        if updatedTask != nil{
            title = "Update Task"
            doneTitle = "Update"
        }
        
        let alertController = UIAlertController(title: title, message: "Write the name of your task.", preferredStyle: UIAlertControllerStyle.alert)
        let createAction = UIAlertAction(title: doneTitle, style: UIAlertActionStyle.default) { (action) -> Void in
            
            let taskName = alertController.textFields?.first?.text
            
            if let priorityValue = Int(alertController.textFields![1].text!) {
                if (priorityValue >= 3) {
                    self.diplayErrorAlert()
                } else {
                    let priority = FMPriority(rawValue: priorityValue)
                    
                    if updatedTask != nil{
                        FMDataManager.sharedInstance.updateTask(updatedTask:updatedTask, withName: taskName!, andPriority: priority!)
                        self.readTasks()
                    } else{
                        
                        let newTask = FMTask()
                        newTask.name = taskName!
                        newTask.priorityRaw = (priority?.rawValue)!
                        newTask.priority = priority!
                        
                        FMDataManager.sharedInstance.addTask(newTask: newTask)
                        self.readTasks()
                    }
                }
               
            } else {
               self.diplayErrorAlert()
            }
        }
        
        alertController.addAction(createAction)
        createAction.isEnabled = false
        self.currentCreateAction = createAction
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        alertController.addTextField { (textField) -> Void in
            textField.placeholder = "Task Name"
            textField.addTarget(self, action: #selector(FMTasksListViewController.taskNameFieldDidChange(_:)), for: UIControlEvents.editingChanged)
            if updatedTask != nil{
                textField.text = updatedTask.name
            }
        }
        
        alertController.addTextField { (textField) -> Void in
            textField.placeholder = "Priority (0,1,2)"
            textField.addTarget(self, action: #selector(FMTasksListViewController.taskPriorityFieldDidChange(_:)), for: UIControlEvents.editingChanged)
            if updatedTask != nil{
                textField.text = String(describing: updatedTask.priorityRaw)
            }
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func displayAlertToShowInfo(_ taskSelected:FMTask!){
        let alertController = UIAlertController(title: "Task Info", message: "Name: \(taskSelected.name) \n Date: \(taskSelected.createdAt) \n Priority: \(taskSelected.priority)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func diplayErrorAlert() {
        let alertControllerError = UIAlertController(title: "Error", message: "Add priority as 0, 1 or 2", preferredStyle: .alert)
        alertControllerError.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alertControllerError, animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource -
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let listsTasks = tasks {
            return listsTasks.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell")
        
        let task = tasks[indexPath.row]
        
        cell?.textLabel?.text = task.name
        cell?.detailTextLabel?.text = "Priotiry \(task.priority) "
        return cell!
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (deleteAction, indexPath) -> Void in
            
            let taskToBeDeleted = self.tasks[indexPath.row]
            FMDataManager.sharedInstance.deleteTask(taskToBeDeleted: taskToBeDeleted)
            self.readTasks()
        }
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Edit") { (editAction, indexPath) -> Void in
            let taskToBeUpdated = self.tasks[indexPath.row]
            self.displayAlertToAddTask(taskToBeUpdated)
            
        }
        return [deleteAction, editAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let taskSelected = self.tasks[indexPath.row]
        self.displayAlertToShowInfo(taskSelected)
    }
    
    //MARK: - UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.tasks = FMDataManager.sharedInstance.getTasks().filter("name CONTAINS[c] '\(searchText)'")
        
        self.shouldShowSearchResults = true
        
        if searchText.isEmpty {
            self.searchBar.resignFirstResponder()
            self.shouldShowSearchResults = false
            self.tasks = FMDataManager.sharedInstance.getTasks()
        }
        
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }


}
