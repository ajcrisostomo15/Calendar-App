//
//  CalendarListViewController.swift
//  Calendar Exam
//
//  Created by Allen Jeffrey Crisostomo on 3/25/23.
//

import UIKit
import RxSwift
import EventKit
import EventKitUI
import SnapKit

class CalendarListViewController: UIViewController {
    private let tableView = UITableView()
    private var viewModel: CalendarListViewModel!
    private let disposeBag = DisposeBag()
    weak var coordinator: MainCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = CalendarListViewModel()
        addRightNavBarItem()
        setupInterface()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    private func setupInterface() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        tableView.delegate = self
        tableView.register(UINib(nibName: "CalendarListTableViewCell", bundle: nil),
                           forCellReuseIdentifier: String(describing: "CalendarListTableViewCell"))
    }
    private func setupBindings() {
        viewModel.events.bind(to: tableView.rx.items(cellIdentifier: String(describing: CalendarListTableViewCell.self), cellType: CalendarListTableViewCell.self)) {  _, model, cell in
            cell.setupCell(withEvent: model)
        }.disposed(by: self.disposeBag)
    }
    
    private func addRightNavBarItem() {
        let button = UIButton()
        button.setTitle("Add Event", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.rx.tap
            .bind {
                self.ShowEventCreator()
            }.disposed(by: self.disposeBag)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    private func ShowEventCreator(_ event: EKEvent? = nil) {
        let eventController = EKEventEditViewController()
        if let id = event?.eventIdentifier,
             let newEvent = eventStore.event(withIdentifier: id) {
                eventController.event = newEvent
            
        } else {
            eventController.event = EKEvent(eventStore: eventStore)
        }
        eventController.eventStore = eventStore
        eventController.editViewDelegate = self
        self.present(eventController, animated: true, completion: nil)
    }
}

extension CalendarListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let event = viewModel.getEvent(atIndex: indexPath.row)
        ShowEventCreator(event)
    }
}

extension CalendarListViewController: EKEventEditViewDelegate {
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        switch action {
        case .canceled:
            break
        case .saved:
            viewModel.getCalendarEvents()
        case .deleted:
            guard let event = controller.event else { return }
            viewModel.deleteEvent(event)
            break
        @unknown default:
            break
        }
        
        controller.dismiss(animated: true)
    }
}

extension CalendarListViewController: Storyboarded {
    
}
