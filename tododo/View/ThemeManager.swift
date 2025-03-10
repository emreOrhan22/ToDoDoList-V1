//
//  ThemeManager.swift
//  ToDoDoList
//
//  Created by Emre on 28.02.2025.
//

import UIKit
import Lottie

class ThemeManager {
    static let shared = ThemeManager()

    func applyTheme(isDarkMode: Bool) {
        UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        
        NotificationCenter.default.post(name: .themeChanged, object: nil)
    }
    
    struct Colors {
        static var background: UIColor{
            return UserDefaults.standard.bool(forKey: "isDarkMode") ? UIColor.black : UIColor.white
        }
        static var textColor: UIColor{
            return UserDefaults.standard.bool(forKey: "isDarkMode") ? UIColor.white : UIColor.black
        }
        static var detailTextColor: UIColor{
            return UserDefaults.standard.bool(forKey: "isDarkMode") ? UIColor.white : UIColor.black
        }
        static var buttonBackgroundColor: UIColor {
            return UserDefaults.standard.bool(forKey: "isDarkMode") ? UIColor.systemGreen : UIColor.systemBlue
        }
        static var tableViewBackground: UIColor {
            return UserDefaults.standard.bool(forKey: "isDarkMode") ? UIColor.black : UIColor.white
        }
        static func timeRemainingColor(for task: Task) -> UIColor {
                    guard let dueDate = task.date else { return Colors.textColor }

                    let timeInterval = dueDate.timeIntervalSinceNow

                    switch timeInterval {
                    case ..<3600:
                        return .red
                    case 3600..<86400:
                        return isDarkMode ? UIColor.orange : UIColor.brown
                    default:
                        return Colors.textColor
                    }
                }
        
        private static var isDarkMode: Bool {
            return UserDefaults.standard.bool(forKey: "isDarkMode")
        }
    }
    func applySavedTheme() {
        let savedTheme = UserDefaults.standard.integer(forKey: "userInterfaceStyle")
        let style: UIUserInterfaceStyle = savedTheme == 1 ? .light : savedTheme == 2 ? .dark : .unspecified
        setTheme(style)
    }

    func setTheme(_ style: UIUserInterfaceStyle) {
        let themeIndex = style == .light ? 1 : style == .dark ? 2 : 0
        UserDefaults.standard.set(themeIndex, forKey: "userInterfaceStyle")

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { $0.overrideUserInterfaceStyle = style }
        }

        NotificationCenter.default.post(name: .themeChanged, object: nil)
    }
    
}

extension Notification.Name {
    static let themeChanged = Notification.Name("themeChanged")
}
