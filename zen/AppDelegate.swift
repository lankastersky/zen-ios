import Firebase
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private enum NavigationTab: Int {
        case challenge
        case journal
        case settings
        case help
    }

    var window: UIWindow?
    lazy var challengesService = ChallengesService()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions:
        [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()
        configureAppearance()
        configureTabBarIcons()

        let notificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)

        FeaturesService().storeAppVersion()
        
        return true
    }

    func application(_ application: UIApplication, didReceive note: UILocalNotification) {
        print("Notification fired with user info \(String(describing: note.userInfo))")
        if application.applicationState == .active {
            // Don't show challenge view controller when app is active
            return
        }
        guard let tabBarController = window?.rootViewController as? UITabBarController else {
            assertionFailure("Failed to get tab bar controller")
            return
        }
        tabBarController.selectedIndex = NavigationTab.challenge.rawValue
        guard let challengeNavigationViewController =
            tabBarController.selectedViewController as? UINavigationController else {
            assertionFailure("Failed to get challenge navigation controller")
            return
        }
        guard let challengeViewController =
            challengeNavigationViewController.topViewController as? ChallengeViewController else {
            assertionFailure("Failed to get challenge view controller")
            return
        }
        challengeViewController.scrollToTop()
    }

    private func configureAppearance() {
        // White non-transucent navigatio bar, supports dark appearance
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()

            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.backgroundColor = UIColor.skinColor

            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            
            
            guard let tabBarController = window?.rootViewController as? UITabBarController else {
                assertionFailure("Failed to get tab bar controller")
                return
            }
            
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            tabBarAppearance.backgroundColor = UIColor.skinColor
            
            tabBarController.tabBar.standardAppearance = tabBarAppearance
            tabBarController.tabBar.scrollEdgeAppearance = tabBarController.tabBar.standardAppearance
        }

        UITabBar.appearance().barTintColor = UIColor.skinColor
        UITabBar.appearance().tintColor = UIColor.white
        
        UINavigationBar.appearance().barTintColor = UIColor.skinColor
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().barStyle = .black
    }

    private func configureTabBarIcons() {
        guard let tabBarController = window?.rootViewController as? UITabBarController else {
            assertionFailure("Failed to get tab bar controller")
            return
        }
        let challengeTabBarItem = tabBarController.tabBar.items?[NavigationTab.challenge.rawValue]
        challengeTabBarItem?.title = "tab_bar_challenge_title".localized
        challengeTabBarItem?.image = UIImage(named: "ic_menu_challenge")
        challengeTabBarItem?.selectedImage = UIImage(named: "ic_menu_challenge")

        // Some icons downloaded from https://material.io/tools/icons/?icon=settings&style=baseline

        let journalTabBarItem = tabBarController.tabBar.items?[NavigationTab.journal.rawValue]
        journalTabBarItem?.title = "tab_bar_journal_title".localized
        journalTabBarItem?.image = UIImage(named: "baseline_star_black_24pt")
        journalTabBarItem?.selectedImage = UIImage(named: "baseline_star_black_24pt")

        let settingsTabBarItem = tabBarController.tabBar.items?[NavigationTab.settings.rawValue]
        settingsTabBarItem?.title = "tab_bar_settings_title".localized
        settingsTabBarItem?.image = UIImage(named: "baseline_settings_black_24pt")
        settingsTabBarItem?.selectedImage = UIImage(named: "baseline_settings_black_24pt")

        let helpTabBarItem = tabBarController.tabBar.items?[NavigationTab.help.rawValue]
        helpTabBarItem?.title = "tab_bar_help_title".localized
        helpTabBarItem?.image = UIImage(named: "baseline_help_black_24pt")
        helpTabBarItem?.selectedImage = UIImage(named: "baseline_help_black_24pt")
    }
}
