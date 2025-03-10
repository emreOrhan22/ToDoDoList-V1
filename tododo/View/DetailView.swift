//
//  DetailView.swift
//  ToDoDoList
//
//  Created by Emre on 4.03.2025.
//

import UIKit
import CoreData
import Lottie

class DetailView : BaseViewController{
    
    @IBOutlet weak var TaskTitleLabel: UILabel!
    @IBOutlet weak var SubtaskVstack: UIStackView!
    @IBOutlet weak var ProgressLabel: UILabel!
    @IBOutlet weak var CategoryLabel: UILabel!
    @IBOutlet weak var TaskDate: UIDatePicker!
    
    var task : Task?
    var completedSubtasks = 0
    var totalSubtasks = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.systemBackground
            TaskTitleLabel.textColor = UIColor.label
            ProgressLabel.textColor = UIColor.secondaryLabel
        
        if let task = task {
            TaskTitleLabel.text = task.taskName
            CategoryLabel.text = task.category
            TaskDate.date = task.date ?? Date()
            
            TaskDate.isUserInteractionEnabled = false
            TaskDate.isEnabled = false
            
            loadSubtasks()
        }
        
    }
    
    func loadSubtasks() {
        // Önce eski alt görevleri temizleyelim
        SubtaskVstack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // StackView temel ayarları
        SubtaskVstack.axis = .vertical
        SubtaskVstack.spacing = 8
        SubtaskVstack.alignment = .leading
        SubtaskVstack.distribution = .fillProportionally
        
        // Eğer alt görevler boşsa işlemi sonlandır
        guard let subtasks = task?.comment?.components(separatedBy: " | "), !subtasks.isEmpty else {
            print("No subtasks available.")
            return
        }
        
        totalSubtasks = subtasks.count
        
        for subtask in subtasks {
            let stackItem = UIStackView()
            stackItem.axis = .horizontal
            stackItem.spacing = 10
            stackItem.alignment = .center
            stackItem.distribution = .fill
            
            let checkBox = UIButton(type: .system)
            checkBox.setTitle("⬜", for: .normal)
            checkBox.titleLabel?.font = UIFont.systemFont(ofSize: 24)
            checkBox.addTarget(self, action: #selector(checkBoxTapped(_:)), for: .touchUpInside)
            
            let label = UILabel()
            label.text = "• \(subtask)"
            label.textAlignment = .left
            label.textColor = .darkGray
            label.font = UIFont.systemFont(ofSize: 16)
            label.numberOfLines = 0
            
            // Checkbox'a sabit genişlik ve yükseklik verelim
            checkBox.translatesAutoresizingMaskIntoConstraints = false
            checkBox.widthAnchor.constraint(equalToConstant: 30).isActive = true
            checkBox.heightAnchor.constraint(equalToConstant: 30).isActive = true
            
            // Checkbox'ı ve label'ı StackView içine ekleyelim
            stackItem.addArrangedSubview(checkBox)
            stackItem.addArrangedSubview(label)
            
            // Önce stackItem'ı SubtaskVstack içine ekleyelim
            SubtaskVstack.addArrangedSubview(stackItem)
            
            // **DİKKAT:** Auto Layout kısıtlamalarını burada ekleyelim
            stackItem.translatesAutoresizingMaskIntoConstraints = false
            stackItem.leadingAnchor.constraint(equalTo: SubtaskVstack.leadingAnchor).isActive = true
            stackItem.trailingAnchor.constraint(equalTo: SubtaskVstack.trailingAnchor).isActive = true
        }
        
        updateProgress()
    }
    
    @objc func checkBoxTapped(_ sender: UIButton) {
            if sender.title(for: .normal) == "⬜" {
                sender.setTitle("✅", for: .normal)
                completedSubtasks += 1
            } else {
                sender.setTitle("⬜", for: .normal)
                completedSubtasks -= 1
            }
            
            updateProgress()
        }
    
    func updateProgress() {
        let progress = (totalSubtasks > 0) ? (Double(completedSubtasks) / Double(totalSubtasks) * 100) : 0
        ProgressLabel.text = "Task Progress: %\(Int(progress.rounded()))"
        
        if progress == 100 {
            playCompletionAnimation()
        }
    }
    func playCompletionAnimation() {
        let animationView = LottieAnimationView(name: "success")
        animationView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        animationView.center = view.center
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .playOnce
        view.addSubview(animationView)
        
        animationView.play { [weak self] _ in
            animationView.removeFromSuperview()
            self?.markTaskAsCompleted()
        }
    }
    
    func markTaskAsCompleted() {
        task?.isCompleted = true
        TaskManager.shared.saveContext()
            
        NotificationCenter.default.post(name: NSNotification.Name("TaskCompleted"), object: task)
        
        navigationController?.popViewController(animated: true)
    }
}




