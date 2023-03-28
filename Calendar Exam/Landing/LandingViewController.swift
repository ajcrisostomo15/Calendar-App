//
//  LandingViewController.swift
//  Calendar Exam
//
//  Created by Allen Jeffrey Crisostomo on 3/25/23.
//

import UIKit
import RxSwift
import RxCocoa

class LandingViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    var viewModel: LandingViewModel!
    private let disposeBag = DisposeBag()
    weak var coordinator: MainCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = LandingViewModel()
//        viewModel.deleteAllEvents()
        setupInterface()
        setupBindings()
    }
    
    private func setupInterface() {
        title = "Calender Event"
    }
    
    private func setupBindings() {
        usernameTextField.rx.text
            .orEmpty
            .bind(to: viewModel.usernameInput)
            .disposed(by: self.disposeBag)
        
        passwordTextField.rx.text
            .orEmpty
            .bind(to: self.viewModel.passwordInput)
            .disposed(by: self.disposeBag)
        
        loginButton.rx.tap
            .bind {
                self.viewModel.login()
            }.disposed(by: self.disposeBag)
        
        signupButton.rx.tap
            .bind {
                self.coordinator?.goToRegistration()
            }.disposed(by: self.disposeBag)
        
        viewModel.shouldEnableLoginButton?
            .bind(to: loginButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
        
        viewModel.isLoginValid.asObservable().subscribe(onNext: { isValid in
            guard let isValid = isValid else { return }
            if isValid {
                self.coordinator?.goToCalendarList()
                self.resetTextfields()
            }
        }).disposed(by: self.disposeBag)
        
        viewModel.userNotExisting.subscribe(onNext: {
            self.showUserNotExisting()
        }).disposed(by: self.disposeBag)
        
        viewModel.userPassNotMatch.subscribe(onNext: {
            self.showUserPassNotMatch()
        }).disposed(by: self.disposeBag)
    }
    
    private func resetTextfields() {
        usernameTextField.text = nil
        usernameTextField.sendActions(for: .valueChanged)
        usernameTextField.resignFirstResponder()
        
        passwordTextField.text = nil
        passwordTextField.sendActions(for: .valueChanged)
        passwordTextField.resignFirstResponder()
    }
    
    private func showUserNotExisting() {
        let alertController = UIAlertController(title: "Login", message: "Username not existing!", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Ok", style: .default) {_ in 
            self.resetTextfields()
        }
        alertController.addAction(action)
        
        present(alertController, animated: true)
    }
    
    private func showUserPassNotMatch() {
        let alertController = UIAlertController(title: "Login", message: "Username or Password is incorrect!", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Ok", style: .default) {_ in 
            self.resetTextfields()
        }
        alertController.addAction(action)
        
        present(alertController, animated: true)
    }
}

extension LandingViewController: Storyboarded {
    
}
