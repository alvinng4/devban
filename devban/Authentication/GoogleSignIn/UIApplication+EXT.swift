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
    /// Finds the root view controller of the application.
    ///
    /// - Returns: The root view controller, or nil if not found
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

    /// Recursively finds the topmost visible view controller.
    ///
    /// This method traverses the view controller hierarchy to find the currently visible
    /// view controller, accounting for navigation controllers, tab bar controllers, and
    /// presented view controllers.
    ///
    /// - Parameter controller: The starting view controller (defaults to root)
    /// - Returns: The topmost visible view controller, or nil if not found
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
