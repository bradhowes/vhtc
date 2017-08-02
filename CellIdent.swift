//
//  CellIdent.swift
//  VariableHeightTableCells
//
//  Created by Brad Howes on 8/1/17.
//  Copyright © 2017 Brad Howes. All rights reserved.
//

import Foundation

/**
 Enumeration of the different UITableViewCell derivatives used by the application. The `rawString` value of the enum
 must match the name of a NIB file (*.xib) and a class (*.swift).
 */
enum CellIdent: String {

    /** 
     UITableViewCell that shows a variable-height text view
     */
    case DataCell

    /** 
     UITableViewCell that shows the day when chat message took place
     */
    case DayMarkerCell

    /// Collection of all cell types
    static let all: [CellIdent] = [.DataCell, .DayMarkerCell]
}
