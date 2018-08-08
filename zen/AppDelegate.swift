import Firebase
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    lazy var challengesService = ChallengesService()
    lazy var storageService = StorageService()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?)
        -> Bool {

        FirebaseApp.configure()
        configureAppearance()
        configureTabBarIcons()
        return true
    }

    private func configureAppearance() {
        UITabBar.appearance().barTintColor = UIColor.skinColor
        UINavigationBar.appearance().barStyle = .black
    }

    private func configureTabBarIcons() {
        guard let tabBarController = window?.rootViewController as? UITabBarController else {
            assertionFailure("Failed to get tab bar controller")
            return
        }
        let challengeTabBarItem = tabBarController.tabBar.items?[0]
        challengeTabBarItem?.title = "tab_bar_challenge_title".localized
        challengeTabBarItem?.image = UIImage(named: "ic_menu_challenge")
        challengeTabBarItem?.selectedImage = UIImage(named: "ic_menu_challenge")

        let journalTabBarItem = tabBarController.tabBar.items?[1]
        journalTabBarItem?.title = "tab_bar_journal_title".localized
        journalTabBarItem?.image = UIImage(named: "baseline_star_black_24pt")
        journalTabBarItem?.selectedImage = UIImage(named: "baseline_star_black_24pt")

        let helpTabBarItem = tabBarController.tabBar.items?[2]
        helpTabBarItem?.title = "tab_bar_help_title".localized
        helpTabBarItem?.image = UIImage(named: "baseline_help_black_24pt")
        helpTabBarItem?.selectedImage = UIImage(named: "baseline_help_black_24pt")
    }
}
