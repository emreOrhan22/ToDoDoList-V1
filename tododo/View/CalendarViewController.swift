//
//  CalendarViewController.swift
//  ToDoDoList
//
//  Created by Emre on 19.02.2025.
//

import UIKit
import CoreData

class CalendarViewController: UIViewController {
    @IBOutlet weak var calendarPicker: UIDatePicker!
    
    @IBOutlet weak var taskTableView: UITableView!
    
    var tasks: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskTableView.delegate = self
        taskTableView.dataSource = self
        
        fetchTasks(for: Date())
        
        NotificationCenter.default.addObserver(self, selector: #selector(taskCompleted(_:)), name: NSNotification.Name("TaskCompleted"), object: nil)
        
    }
    
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        fetchTasks(for: sender.date)
    }
    
    func fetchTasks(for selectedDate: Date) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let context = appDelegate.persistentContainer.viewContext
        
        let request : NSFetchRequest<Task> = Task.fetchRequest()
        
        //seçilen tarihe göre filtreleme
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1 , to: startOfDay)!
        
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate , endOfDay as NSDate)
        
        do {
            tasks = try context.fetch(request)
            taskTableView.reloadData()
        }catch{
            print("Görevler getirilemedi: \(error.localizedDescription)")
        }
    }
    @objc func taskCompleted(_ notification: Notification) {
        if let completedTask = notification.object as? Task {
            tasks.removeAll { $0 == completedTask }
            taskTableView.reloadData()
        }
    }
}

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.taskName
        cell.detailTextLabel?.text = task.comment
        cell.accessoryType = task.isCompleted ? .checkmark : .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            performSegue(withIdentifier: "toSecondDetailView", sender: tasks[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "toSecondDetailView",
               let destinationVC = segue.destination as? DetailView,
               let selectedTask = sender as? Task {
                destinationVC.task = selectedTask
        }
    }
    
}
    
    

