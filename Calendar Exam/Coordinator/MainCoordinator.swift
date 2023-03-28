//
//  MainCoordinator.swift
//  Calendar Exam
//
//  Created by Allen Jeffrey Crisostomo on 3/26/23.
//

import UIKit

class MainCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = LandingViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func goToRegistration() {
        let vc = RegistrationViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func goToCalendarList() {
        let vc = CalendarListViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
