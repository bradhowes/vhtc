//
//  Content.swift
//  VariableHeightTableCells
//
//  Created by Brad Howes on 8/2/17.
//  Copyright © 2017 Brad Howes. All rights reserved.
//

import UIKit

/**
 Collection of random data to show in a UITableView row
 */
struct Content {

    /// The type of cell to show
    let ident: CellIdent

    /// The title to show in the cell (only valid for DataCell cells
    let title: String

    /// The text to show in the cell (only valid for DataCell cells)
    let text: String

    /// The image to show in the cell (only valud for DataCell cells)
    let image: UIImage?

    /// The date to show in the cell (valid for both DataCell and DayMarkerCell cells)
    let when: Date

    /**
     Construct a new instance for a DataCell cell

     - parameter title: the title string
     - parameter text: the text string
     - parameter image: the avatar image
     - parameter when: the timestamp of the message
     */
    init(title: String, text: String, image: UIImage, when: Date) {
        self.ident = .DataCell
        self.title = title
        self.text = text
        self.image = image
        self.when = when
    }

    /**
     Construct a new instance for a DayMarkerCell cell

     - parameter when: the timestamp of the day
     */
    init(when: Date) {
        self.ident = .DayMarkerCell
        self.title = ""
        self.text = ""
        self.image = nil
        self.when = Calendar.current.startOfDay(for: when)
        print("DayMarkerCell: \(when) \(self.when)")
    }

    /**
     Determine if this instance took place on the same day as a given Date value

     - parameter when: the value to compare
     - returns: true if on the same day
     */
    func sameDay(_ when: Date) -> Bool {
        return Calendar.current.compare(self.when, to: when, toGranularity: .day) == .orderedSame
    }
}

