//
//  RegistrationViewModel.swift
//  Calendar Exam
//
//  Created by Allen Jeffrey Crisostomo on 3/26/23.
//

import RxSwift
import RxRelay

class RegistrationViewModel {
    private let disposeBag = DisposeBag()
    
    var usernameInput = BehaviorRelay<String?>(value: nil)
    var passwordInput = BehaviorRelay<String?>(value: nil)
    
    var shouldEnableSignupButton: Observable<Bool>?
    var userExistingError = PublishSubject<Bool>()
    var signupSuccess = PublishSubject<Bool>()
    init() {
        shouldEnableSignupButton = Observable.combineLatest(usernameInput, passwordInput) { username, password in
            guard let username = username, let password = password else { return false }
            return !username.isEmpty && !password.isEmpty
        }
    }
    
    func registerUser() {
        let username = usernameInput.value ?? ""
        let password = passwordInput.value ?? ""
        let creds = UserCredential(username: username, password: password)
        
        let userDefaults = UserDefaults.standard
        
        if let userCredData = userDefaults.object(forKey: UserDefaultKeys.users) as? Data, var users = try? JSONDecoder().decode([UserCredential].self, from: userCredData) {
            if isExisting(user: username, users: users) {
                userExistingError.onNext(true)
            } else {
                users.append(creds)
                storeData(forUsers: users)
                self.signupSuccess.onNext(true)
            }
        } else {
            storeData(forUsers: [creds])
            self.signupSuccess.onNext(true)
        }
    }
    
    private func isExisting(user: String, users: [UserCredential]) -> Bool {
        users.contains { creds in
            return creds.username == user
        }
    }
    
    private func storeData(forUsers users: [UserCredential]) {
        let userDefaults = UserDefaults.standard
        if let usersData = try? JSONEncoder().encode(users) {
            userDefaults.setValue(usersData, forKey: UserDefaultKeys.users)
        } else {
            print()
        }
    }
}
