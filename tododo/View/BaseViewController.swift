//
//  BaseViewController.swift
//  ToDoDoList
//
//  Created by Emre on 3.03.2025.
//

import UIKit

class BaseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTheme()
        
        // Tema değişince güncellemek için dinleyici ekle
        NotificationCenter.default.addObserver(self, selector: #selector(updateTheme), name: .themeChanged, object: nil)
    }

    func setupTheme() {
        view.backgroundColor = UIColor.systemBackground
    }
    
    @objc func updateTheme() {
        view.backgroundColor = UIColor.systemBackground
    }
}

