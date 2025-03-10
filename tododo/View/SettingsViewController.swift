//
//  SettingsViewController.swift
//  ToDoDoList
//
//  Created by Emre on 24.02.2025.
//

import UIKit
import Lottie

class SettingsViewController: BaseViewController {

    private let animationView: LottieAnimationView = {
        let view = LottieAnimationView(name: "darkLight") // JSON dosya adı
        view.contentMode = .scaleAspectFit
        view.loopMode = .playOnce
        view.animationSpeed = 1.0
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setInitialAnimationFrame()
    }

    private func setupUI() {
        view.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            animationView.widthAnchor.constraint(equalToConstant: 100),
            animationView.heightAnchor.constraint(equalToConstant: 100)
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleTheme))
        animationView.addGestureRecognizer(tapGesture)
        animationView.isUserInteractionEnabled = true
    }

    private func setInitialAnimationFrame() {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        let startFrame: CGFloat = isDarkMode ? 75.0 / 150.0 : 0.0
        animationView.currentProgress = startFrame
    }

    @objc private func toggleTheme() {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        
        // **Önce animasyonu başlat**
        animationView.play(
                fromProgress: isDarkMode ? 75.0 / 150.0 : 0.0,
                toProgress: isDarkMode ? 0.0 : 90.0 / 150.0,
                loopMode: .playOnce
        )
        
        // **Sonra tema değiştir**
        ThemeManager.shared.applyTheme(isDarkMode: !isDarkMode)
    }
}

