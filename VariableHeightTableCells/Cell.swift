//
//  Cell.swift
//  VariableHeightTableCells
//
//  Created by Brad Howes on 8/1/17.
//  Copyright © 2017 Brad Howes. All rights reserved.
//

import UIKit

class Cell: UITableViewCell, SizableCell {

    var cellIdent: CellIdent { fatalError("deriving class must override") }

    func setup(content: Content) -> Cell {
        return self
    }

    /// Calculate and return the height of this cell using whatever content is currently in the views.
    var cellHeightForContent: CGFloat {
        contentView.layoutIfNeeded()
        return (contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height + 0.5).rounded(.up)
    }

    /// The current cell width. Adjust to recalculate cell heights.
    var cellWidth: CGFloat = 0.0 {
        didSet {
            contentView.frame = CGRect(x: 0.0, y: 0.0, width: cellWidth, height: 9999.0)
            contentView.layoutIfNeeded()
        }
    }
}
