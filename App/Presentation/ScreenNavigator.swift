//
//  ScreenNavigator.swift
//  PrintOnDemand
//
//  Created by duczxje on 15/11/25.
//
import UIKit

@MainActor
public final class ScreenNavigator {
    private let navigationController: UINavigationController

    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    private func getController<T: UIViewController>() -> T? {
        return navigationController.viewControllers.first { $0 is T } as? T
    }

    private func popToRootController() {
        let poppedControllers: [UIViewController]? =
            navigationController.popToRootViewController(animated: true)

        poppedControllers?.forEach {
            $0.viewFinalized()
        }
    }

    private func popToBackController(animated: Bool = true) {
        navigationController.popViewController(animated: animated)?
            .viewFinalized()
    }

    private func popToTargetController<T: UIViewController>(
        animated: Bool = true
    ) -> T? {
        let targetController: T? = getController()
        if targetController != nil {
            let poppedControllers: [UIViewController]? =
                navigationController.popToViewController(
                    targetController!,
                    animated: animated
                )

            poppedControllers?.forEach {
                $0.viewFinalized()
            }
        }
        return targetController
    }

    private func pushController(
        _ controller: UIViewController,
        animated: Bool = true
    ) {
        navigationController.pushViewController(controller, animated: animated)
    }

    private func presentController(
        _ controller: UIViewController,
        animated: Bool = true
    ) {
        navigationController.present(controller, animated: animated)
    }

    private func dismissAll(animated: Bool = true) {
        navigationController.dismiss(animated: animated)
    }

    // MARK: Screen Navigator Singleton
    nonisolated(unsafe)
        private static var _instance: ScreenNavigator!

    fileprivate static func initialize(
        navigationController: UINavigationController
    ) {
        _instance = ScreenNavigator(
            navigationController: navigationController
        )
    }

    public func toH5Container() {
        
    }
}

extension SceneDelegate {
    func installScreenNavigator(navigationController: UINavigationController) {
        ScreenNavigator.initialize(navigationController: navigationController)
    }
}
