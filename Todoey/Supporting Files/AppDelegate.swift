import UIKit
import RealmSwift
import ChameleonFramework

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        self.window?.tintColor = .label
        
        ///https://stackoverflow.com/questions/56556254/in-ios13-the-status-bar-background-colour-is-different-from-the-navigation-bar-i
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()

            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.label]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
            navBarAppearance.backgroundColor = FlatSkyBlue()

            UINavigationBar.appearance().standardAppearance = navBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        } else {
            let app = UINavigationBarAppearance()
            app.backgroundColor = FlatSkyBlue()
            UINavigationBar.appearance().standardAppearance = app
            UINavigationBar.appearance().scrollEdgeAppearance = app
        }

        if let realmDefaultFilePath = Realm.Configuration.defaultConfiguration.fileURL {
            print("Realm DB Location: \(realmDefaultFilePath)")
        }
        
        do {
            _ = try Realm()
        } catch {
            print("Error initialising new realm, \(error)")
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
    }

}
