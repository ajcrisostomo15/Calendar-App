//
//  LandingViewModel.swift
//  Calendar Exam
//
//  Created by Allen Jeffrey Crisostomo on 3/25/23.
//

import RxSwift
import RxRelay
import EventKit
import RxCocoa

struct UserDefaultKeys {
    static let users = "User List"
}

class LandingViewModel {
    var listOfUsers = BehaviorRelay<[UserCredential]>(value: [])
    var usernameInput = BehaviorRelay<String?>(value: nil)
    var passwordInput = BehaviorRelay<String?>(value: nil)
    
    var isLoginValid = BehaviorRelay<Bool?>(value: nil)
    var shouldEnableLoginButton: Observable<Bool>?
    var userNotExisting = PublishSubject<Void>()
    var userPassNotMatch = PublishSubject<Void>()
    
    private var listOfRegisteredUsers: [UserCredential] = []
    private let disposeBag = DisposeBag()
    
    init() {
        self.shouldEnableLoginButton = Observable.combineLatest(usernameInput, passwordInput) { username, password in
            guard let u = username, let p = password else { return false }
            return !u.isEmpty && !p.isEmpty
        }
        getListOfUsers()
    }
    
    func login() {
        getListOfUsers()
        guard let u = usernameInput.value, let p = passwordInput.value else { return }
        let validUsername = self.validateUsername(u)
        let validPassword = self.validatePassword(p)
        let login = validUsername  && validPassword
        isLoginValid.accept(login)
        
        if !validUsername {
            userNotExisting.onNext(())
        } else if (validUsername && !validPassword) || (!validUsername && validPassword) {
            userPassNotMatch.onNext(())
        }
    }
    
    private func validateUsername(_ string: String?) -> Bool {
        listOfRegisteredUsers.contains { creds in
            return string == creds.username
        }
    }
        
    private func validatePassword(_ string: String?) -> Bool {
        listOfRegisteredUsers.contains { creds in
            return string == creds.password
        }
    }
    
    private func getListOfUsers() {
        let userDefaults = UserDefaults.standard
        if let userCredData = userDefaults.object(forKey: UserDefaultKeys.users) as? Data, let users = try? JSONDecoder().decode([UserCredential].self, from: userCredData) {
            listOfRegisteredUsers = users
        } else {
            print()
        }
    }
    
    func deleteAllEvents() {
        let calendars = eventStore.calendars(for: .event)
        
        for calendar in calendars {
            let oneMonthAgo = Date(timeIntervalSinceNow: -130*24*3600)
            let oneMonthAfter = Date(timeIntervalSinceNow: 130*24*3600)
            let predicate =  eventStore.predicateForEvents(withStart: oneMonthAgo, end: oneMonthAfter, calendars: [calendar])
            
            let events = eventStore.events(matching: predicate)
            
            for event in events {
                do {
                    try eventStore.remove(event, span: .thisEvent, commit: true)
                } catch {
                    
                }
            }
        }
    }
}
