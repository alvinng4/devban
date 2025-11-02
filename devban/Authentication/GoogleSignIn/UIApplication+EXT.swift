//
//  SignInWithGoogle.swift
//
//
//  Created by Nick Sarno on 10/25/23.
//
import Foundation
import UIKit

extension UIApplication
{
    private static func rootViewController() -> UIViewController?
    {
        let rootVC: UIViewController? = UIApplication
            .shared
            .connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .last?
            .rootViewController

        return rootVC
    }

    @MainActor static func topViewController(controller: UIViewController? = nil) -> UIViewController?
    {
        let controller = controller ?? rootViewController()

        if let navigationController = controller as? UINavigationController
        {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController
        {
            if let selected = tabController.selectedViewController
            {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController
        {
            return topViewController(controller: presented)
        }
        return controller
    }
}
