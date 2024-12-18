//
//  SceneDelegate.swift
//  RecipeFinderApp
//
//  Created by ntvlbl on 13.12.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
            guard let windowScene = (scene as? UIWindowScene) else { return }
            window = UIWindow(windowScene: windowScene)
          
            let homeVC = ViewController()
            let searchVC = IngredientsSearchViewController()
            let favoritesVC = FavoritesViewController()
            
            homeVC.title = "Home"
            searchVC.title = "Search Recipes"
            favoritesVC.title = "Favorites"
            
            homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house.fill"), tag: 0)
            searchVC.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 1)
            favoritesVC.tabBarItem = UITabBarItem(title: "Favorites", image: UIImage(systemName: "heart.fill"), tag: 2)
            
            let tabBarController = UITabBarController()
        
            let homeNav = UINavigationController(rootViewController: homeVC)
            let searchNav = UINavigationController(rootViewController: searchVC)
            let favoritesNav = UINavigationController(rootViewController: favoritesVC)

            let shoppingListVC = ShoppingListViewController()
            shoppingListVC.title = "Shopping List"
            shoppingListVC.tabBarItem = UITabBarItem(title: "Shopping List", image: UIImage(systemName: "cart.fill"), tag: 3)
            let shoppingNav = UINavigationController(rootViewController: shoppingListVC)

            tabBarController.viewControllers = [homeNav, searchNav, favoritesNav, shoppingNav]


          
            window?.rootViewController = tabBarController
            window?.makeKeyAndVisible()
        }
        

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

