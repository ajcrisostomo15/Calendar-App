//
//  RegistrationViewController.swift
//  Calendar Exam
//
//  Created by Allen Jeffrey Crisostomo on 3/26/23.
//

import UIKit
import RxSwift
import RxCocoa

class RegistrationViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    
    weak var coordinator: MainCoordinator?
    private var viewModel: RegistrationViewModel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = RegistrationViewModel()
        setupBindings()
        setupInterface()
    }
    
    private func setupInterface() {
        title = "Sign Up"
    }
    
    private func setupBindings() {
        usernameTextField.rx.text
            .orEmpty
            .bind(to: viewModel.usernameInput)
            .disposed(by: self.disposeBag)
        
        passwordTextField.rx.text
            .orEmpty
            .bind(to: viewModel.passwordInput)
            .disposed(by: self.disposeBag)
        
        signupButton.rx.tap
            .bind {
                self.viewModel.registerUser()
                self.view.endEditing(true)
            }.disposed(by: self.disposeBag)
        
        viewModel.shouldEnableSignupButton?
            .bind(to: signupButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
        
        viewModel.userExistingError.subscribe(onNext: { isExisting in
            if isExisting {
                self.showUserExisitingError()
            }
        }).disposed(by: self.disposeBag)
        
        viewModel.signupSuccess.subscribe(onNext: { _ in
            self.showSignupSuccess()
        }).disposed(by: self.disposeBag)
    }
    
    private func showUserExisitingError() {
        let alertController = UIAlertController(title: "Oops", message: "User already existing", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Ok", style: .default)
        alertController.addAction(action)
        
        present(alertController, animated: true)
    }
    
    private func showSignupSuccess() {
        let alertController = UIAlertController(title: "Hooray!", message: "Sign UP Success", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Ok", style: .default) { _ in
            self.resetFields()
        }
        alertController.addAction(action)
        
        present(alertController, animated: true)
    }
    
    private func resetFields() {
        self.usernameTextField.text = nil
        self.usernameTextField.sendActions(for: .valueChanged)
        self.usernameTextField.resignFirstResponder()
        self.passwordTextField.text = nil
        self.passwordTextField.sendActions(for: .valueChanged)
        self.passwordTextField.resignFirstResponder()
    }
}

extension RegistrationViewController: Storyboarded {
    
}
