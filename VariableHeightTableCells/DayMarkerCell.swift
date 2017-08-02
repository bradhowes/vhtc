//
//  Cell.swift
//  VariableHeightTableCells
//
//  Created by Brad Howes on 1/5/17.
//  Copyright © 2017 Brad Howes. All rights reserved.
//

import UIKit

/** 
 Derivation of a UITableViewCell which shows the day for the subsequent chat messages that follows it.
 */
final class DayMarkerCell: Cell {

    /// CellIdent enum that represents this cell type
    static let cellIdent: CellIdent = .DayMarkerCell

    override var cellIdent: CellIdent { return DayMarkerCell.cellIdent }

    @IBOutlet weak var when: UILabel!

    /// DateFormatter that converts Date values into "Month Day" values (eg August 2)
    static var monthDayFormatter: DateFormatter = {
        let monthDayFormatter = DateFormatter()
        monthDayFormatter.timeStyle = .none
        monthDayFormatter.setLocalizedDateFormatFromTemplate("MMMM d")
        return monthDayFormatter
    }()

    /// DateFormatter that converts Date values into "Month Day, Year" values (eg. August 2, 2017)
    static var monthDayYearFormatter: DateFormatter = {
        let monthDayYearFormatter = DateFormatter()
        monthDayYearFormatter.timeStyle = .none
        monthDayYearFormatter.setLocalizedDateFormatFromTemplate("MMMM d, yyyy")
        return monthDayYearFormatter
    }()

    static func formatDate(_ when: Date) -> String {
        let calendar = Calendar.current

        if calendar.isDateInToday(when) {
            return NSLocalizedString("Today", comment: "The word that means 'today'")
        }

        if calendar.isDateInYesterday(when) {
            return NSLocalizedString("Yesterday", comment: "The word that means 'yesterday'")
        }

        let now = Date()
        let components = calendar.dateComponents([.day], from: when, to: now)
        if let day = components.day {
            if day < 7 {

                // Show the weekday name (eg. Saturday)
                //
                let weekday = calendar.component(.weekday, from: when)
                let dayOfWeek = calendar.standaloneWeekdaySymbols[weekday - 1]
                return "\(dayOfWeek)"
            }

            if day < 365 {

                // Show the day as "Month Day"
                //
                return monthDayFormatter.string(from: when)
            }
        }

        // Show the day as "Month Day, Year"
        //
        return monthDayYearFormatter.string(from: when)
    }

    /**
     Fill in the cell fields with given content values
     - parameter content: the content to fill in
     - returns: ourselves
     */
    override func setup(content: Content) -> Cell {
        self.when.text = DayMarkerCell.formatDate(content.when)
        return self
    }
}
