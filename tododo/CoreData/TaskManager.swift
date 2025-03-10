//
//  TaskManager.swift
//  ToDoDoList
//
//  Created by Emre on 20.02.2025.
//

import UIKit
import CoreData
 
 class TaskManager {
 static let shared = TaskManager()
     let context = (UIApplication.shared.delegate as! AppDelegate ).persistentContainer.viewContext
     
     func addTask(taskName:String, comment:String, category:String, date: Date) {
         let newTask = Task(context: context)
         newTask.taskName = taskName
         newTask.comment = comment
         newTask.category = category
         newTask.date = date
         newTask.completedSubtasks = 0
         newTask.totalSubtasks = Int16(comment.components(separatedBy: " | ").count)
         newTask.isCompleted = false
         
         
         saveContext()
     }
     
     func saveContext() {
         do {
             try context.save()
             print("Görev kaydedildi")
         }catch{
             print("Görev Kaydedilemedi")
         }
     }
     
     func deleteTask(task: Task) {
            context.delete(task)
            saveContext()
        }
     
     func fetchRequest() -> [Task] {
         let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
         let request: NSFetchRequest<Task> = Task.fetchRequest()
         
         do {
             return try context?.fetch(request) ?? []  // ✅ Eğer fetch başarısız olursa boş dizi döndür
         } catch {
             print("HATA: Görevler getirilemedi: \(error.localizedDescription)")
             return []
         }
     }



     func markTaskAsCompleted(task: Task) {
             task.isCompleted = true
             saveContext()
    }
 }
 
