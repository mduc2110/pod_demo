//
//  ScreenContainer.swift
//  PrintOnDemand
//
//  Created by duczxje on 15/11/25.
//
import SwiftUI
import UIKit

class ScreenContainer<T: View>: UIHostingController<T> {
    private weak var weakView: UIView?

    private var tapGesture: UITapGestureRecognizer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardDismissGesture()
    }

    private func setupKeyboardDismissGesture() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(endEditing)
        )
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        tapGesture = tap
        weakView = view
    }

    @objc private func endEditing() {
        view.endEditing(true)
    }

    deinit {
        if let gesture = tapGesture,
            let view = weakView
        {
            DispatchQueue.main.async {
                view.removeGestureRecognizer(gesture)
            }
        }
    }
}
