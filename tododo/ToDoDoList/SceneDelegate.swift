//
//  SceneDelegate.swift
//  ToDoDoList
//
//  Created by Emre on 19.02.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        // 📌 Kullanıcının son seçtiği temayı uygula
        ThemeManager.shared.applySavedTheme()

        // 📌 Storyboard'u Manuel Olarak Başlat
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // Eğer storyboard ismin farklıysa güncelle!
        let initialViewController = storyboard.instantiateInitialViewController()
        window.rootViewController = initialViewController
        
        window.makeKeyAndVisible()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        ThemeManager.shared.applySavedTheme()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        ThemeManager.shared.applySavedTheme()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}



