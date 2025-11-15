//
//  ViewController.swift
//  PrintOnDemand
//
//  Created by duczxje on 15/11/25.
//
import SwiftUI

public protocol ScreenView: View {}

class ViewController: UIViewController {
    private var hostingContainer: ScreenContainer<AnyView>?

    func setContentView<T: View>(content: T) {
        let wrapped = AnyView(content)
        let hostingContainer = ScreenContainer(rootView: wrapped)
        self.hostingContainer = hostingContainer

        addChild(hostingContainer)
        view.addSubview(hostingContainer.view)
        hostingContainer.view.frame = view.bounds
        hostingContainer.didMove(toParent: self)
    }
}

extension UIViewController {
    @objc open func viewFinalized() {
        Logger.i("UIViewController", "view controller: \(self)")
    }
}
