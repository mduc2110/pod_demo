//
//  MainViewController.swift
//  PrintOnDemand
//
//  Created by duczxje on 15/11/25.
//
import UIKit

final class MainViewController: ViewController, MainViewContext {
    private lazy var mainViewModel = MainViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setContentView(
            content: MainScreen(viewContext: self)
        )
    }

    func getMainViewModel() -> MainViewModel {
        mainViewModel
    }
}

protocol MainViewContext: AnyObject, ViewContext {
    func getMainViewModel() -> MainViewModel
}
