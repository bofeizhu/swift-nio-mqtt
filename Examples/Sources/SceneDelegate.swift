//
//  SceneDelegate.swift
//  NIOMQTTExample
//
//  Created by Bofei Zhu on 8/30/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        let messageView = MessageView()

        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: messageView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}
