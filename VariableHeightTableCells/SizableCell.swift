//
//  SizableCell.swift
//  VariableHeightTableCells
//
//  Created by Brad Howes on 8/1/17.
//  Copyright © 2017 Brad Howes. All rights reserved.
//

import UIKit

/** 
 Protocol for types that support variable-height cells
 */
protocol SizableCell {

    /// The height of the cell for the current content
    var cellHeightForContent: CGFloat { get }

    /// The current width of the cell.
    var cellWidth: CGFloat { get set }
}

