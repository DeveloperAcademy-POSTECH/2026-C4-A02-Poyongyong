//
//  AppDelegate.swift
//  Mogapa
//
//  Created by Sue on 7/22/26.
//

import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.portrait

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        AppDelegate.orientationLock
    }
}

extension AppDelegate {
    static func lock(to mask: UIInterfaceOrientationMask) {
        orientationLock = mask

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }

        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: mask))
        windowScene.windows.first?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
    }
}
