//
//  CalendarListTableViewCell.swift
//  Calendar Exam
//
//  Created by Allen Jeffrey Crisostomo on 3/26/23.
//

import UIKit
import EventKit

class CalendarListTableViewCell: UITableViewCell {

    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setupCell(withEvent event: EKEvent) {
        eventNameLabel.text = event.title
        startDateLabel.text = event.startDate.dateOnlyFormat
        endDateLabel.text = event.endDate.dateOnlyFormat
    }
}
