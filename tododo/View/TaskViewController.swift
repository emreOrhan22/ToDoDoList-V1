//
//  TaskViewController.swift
//  ToDoDoList
//
//  Created by Emre on 19.02.2025.
//

import UIKit
import CoreData

class TaskViewController : UIViewController {
    @IBOutlet weak var taskTitleTextField: UITextField!
    @IBOutlet weak var subtaskAddTextField: UITextField!
    @IBOutlet weak var subtaskStackView: UIStackView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categorySelectButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    var subtasks : [String] = []
    var selectedCategory : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.minimumDate = Date()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        subtaskAddTextField.isUserInteractionEnabled = true
        subtaskAddTextField.placeholder = "Enter Subtask..."
    
    }
    
    @IBAction func subtaskAddTapped(_ sender: Any) {
        guard let subtaskText = subtaskAddTextField.text, !subtaskText.isEmpty else { return }
        
        subtasks.append(subtaskText)
        
        // StackView oluştur
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .fill
        
        // Alt görev label
        let subtaskLabel = UILabel()
        subtaskLabel.text = subtaskText
        subtaskLabel.font = UIFont.systemFont(ofSize: 16)
        
        // Silme butonu
        let deleteButton = UIButton(type: .system)
        deleteButton.setTitle("❌", for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteSubtask(_:)), for: .touchUpInside)
        
        // StackView içine ekle
        stackView.addArrangedSubview(subtaskLabel)
        stackView.addArrangedSubview(deleteButton)
        
        subtaskStackView.addArrangedSubview(stackView)
        
        subtaskAddTextField.text = ""
    }
    
    // Alt görev silme işlemi
    @objc func deleteSubtask(_ sender: UIButton) {
        if let stackView = sender.superview as? UIStackView {
            //subtasks.remove(at: index)
            stackView.removeFromSuperview()
        }
    }
    
    @IBAction func categorySelectTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Select Category", message: nil, preferredStyle: .actionSheet)
        let categories = ["Work", "Personal", "Sports", "Shopping", "Education"]
        
        for category in categories {
            alert.addAction (UIAlertAction(title: category, style: .default, handler: { action in
                self.selectedCategory = category
                self.categorySelectButton.setTitle(category, for: .normal)
                self.categorySelectButton.setTitleColor(.green, for: .normal)
                
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @IBAction func saveTaskTapped(_ sender: Any) {
        guard let taskTitle = taskTitleTextField.text, !taskTitle.isEmpty else {
            showAlert(message: "Please enter a task title.")
            return
        }
        guard let category = selectedCategory else {
            showAlert(message: "Please select a category.")
            return
        }
        let selectedDate = datePicker.date
        
        // Alt görevleri tek string olarak sakla
        let subtaskString = subtasks.joined(separator: " | ")
        
        TaskManager.shared.addTask(taskName: taskTitle, comment: subtaskString, category: category, date: selectedDate)
        
        print("Task Saved:")
        print("Title: \(taskTitle)")
        print("Category: \(category)")
        print("Date: \(selectedDate)")
        print("Subtasks: \(subtasks)")
        
        // Alt görev listesini sıfırla
        subtasks.removeAll()
        subtaskStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        NotificationCenter.default.post(name: NSNotification.Name("TaskSaved"), object: nil)
        
        navigateBackToList()
        
    }
    
    func navigateBackToList() {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
func showAlert(message: String) {
    let alert = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    present(alert, animated: true)
    }
 }
