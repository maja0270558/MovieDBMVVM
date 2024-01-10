//
//  SceneDelegate.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2023/12/19.
//

import UIKit

class RootViewController: UIViewController {
    override func loadView() {
        super.loadView()
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        self.window = (scene as? UIWindowScene).map { UIWindow(windowScene: $0) }
        self.window?.rootViewController = UIViewController()
//        self.window?.rootViewController = UINavigationController(rootViewController: MovieViewController())
        self.window?.makeKeyAndVisible()
    }
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        return true
    }
}
