//
//  ViewController.swift
//  ToDoDoList
//
//  Created by Emre on 19.02.2025.
//

import UIKit
import CoreData
import Lottie

class ViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var tasks: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        tableView.delegate = self
        tableView.dataSource = self

        tableView.backgroundColor = UIColor.systemBackground
        
        setupNotifications()
        setupUI()
    }
    
    // fetchTasks
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: NSNotification.Name("TaskCompleted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: NSNotification.Name("TaskSaved"), object: nil)
    }
    @objc func reloadTableView() {
        fetchTasks()
    }
    
    func fetchTasks() {
        let allTasks = TaskManager.shared.fetchRequest() 
        tasks = allTasks.filter { !$0.isCompleted }

        DispatchQueue.main.async {
        self.tableView.reloadData()
        }
    }
    
    // tableView settings

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return tasks.count
        }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
            
        let task = tasks[indexPath.row]

        cell.textLabel?.text = task.taskName
        cell.textLabel?.textColor = UIColor.label  
        cell.backgroundColor = UIColor.secondarySystemBackground
            
        let categoryText = task.category ?? "No Category"

        if let dueDate = task.date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let formattedDate = dateFormatter.string(from: dueDate)

        let remainingTime = timeRemainingText(for: task)
                
        cell.detailTextLabel?.text = "\(formattedDate) - \(remainingTime)"
        cell.detailTextLabel?.textColor = UIColor.secondaryLabel
    } else {
        cell.detailTextLabel?.text = "\(categoryText) - No End Date"
        cell.detailTextLabel?.textColor = UIColor.secondaryLabel
        }
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTask = tasks[indexPath.row]
        performSegue(withIdentifier: "toDetailView", sender: selectedTask)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailView",
           let destinationVC = segue.destination as? DetailView,
           let selectedTask = sender as? Task {
            destinationVC.task = selectedTask
        }
    }
    
    func timeRemainingText(for task : Task) -> String {
        guard let dueDate = task.date else {return "No End Date"}
        
        let now = Date()
        let diff = Calendar.current.dateComponents([.day, .hour, .minute], from: now, to: dueDate)
        
        if let daysLeft = diff.day, let hoursLeft = diff.hour, let minuteLeft = diff.minute {
            if daysLeft > 0 {
                return "\(daysLeft) Day, \(hoursLeft) Hour, \(minuteLeft) Minute"
            }else if hoursLeft > 0{
                return "\(hoursLeft) Hour, \(minuteLeft) Minute"
            }else if minuteLeft > 0 {
                return "\(minuteLeft) Minute"
            }else {
                return "Time is OVER!"
            }
        }
        return "End Date Unknown"
    }
    
    @objc func taskCompleted(_ notification: Notification) {
        guard let completedTask = notification.object as? Task else {return}
        
        if let index = tasks.firstIndex(of: completedTask) {
            tasks.remove(at: index)
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
        }
        playCompletionAnimation()
    }
    
    func playCompletionAnimation() {
        let animationView = LottieAnimationView(name: "confetti")
        animationView.frame = view.bounds
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .playOnce
        view.addSubview(animationView)
        
        animationView.play { (finished) in
            animationView.removeFromSuperview()
        }
    }
    
    // done - delete slide
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let task = tasks[indexPath.row]
            let completeAction = UIContextualAction(style: .normal, title: "Done") { _, _, completionHandler in
                self.completeTask(task: task, indexPath: indexPath)
                completionHandler(true)
            }
            completeAction.backgroundColor = .systemGreen
            return UISwipeActionsConfiguration(actions: [completeAction])
        }
    
    func completeTask(task: Task, indexPath: IndexPath) {
        playCompletionAnimation()
        
        task.isCompleted = true
        TaskManager.shared.saveContext()
        tasks.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        
        NotificationCenter.default.post(name: NSNotification.Name("TaskCompleted"), object: task)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, completionHandler in
                let taskToDelete = self.tasks[indexPath.row]
                TaskManager.shared.deleteTask(task: taskToDelete)
                self.tasks.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                completionHandler(true)
            }
            deleteAction.backgroundColor = .systemRed
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }
    
    
    func checkForExpiredTasks() {
        var expiredTaskFound = false

        for task in tasks {
            if let dueDate = task.date, dueDate < Date(), !task.isCompleted {
                expiredTaskFound = true
                break
            }
        }

        if expiredTaskFound {
            showBombAnimation()
        }

        tasks.removeAll { task in
            if let dueDate = task.date, dueDate < Date(), !task.isCompleted {
                TaskManager.shared.deleteTask(task: task)
                return true
            }
            return false
        }

        guard let tableView = self.tableView else {
            return
        }
        
        tableView.reloadData()
    }

    func showBombAnimation() {
        let animationView = LottieAnimationView(name: "bomb")
        animationView.frame = view.bounds
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .playOnce
        view.addSubview(animationView)

        animationView.play { (finished) in
            animationView.removeFromSuperview()
        }
    }

// Add Button
    let addButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("+", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
            button.layer.cornerRadius = 30
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(addTask), for: .touchUpInside)
            button.backgroundColor = UIColor.systemBlue 
            return button
        }()
    
    func setupUI() {
            view.addSubview(addButton)
            
            NSLayoutConstraint.activate([
                addButton.widthAnchor.constraint(equalToConstant: 60),
                addButton.heightAnchor.constraint(equalToConstant: 60),
                addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
            ])
            
        addButton.backgroundColor = ThemeManager.Colors.buttonBackgroundColor
        }
    
    @objc func addTask() {
        performSegue(withIdentifier: "toTaskVC", sender: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkForExpiredTasks()
        reloadTableView()
    }
    
}



