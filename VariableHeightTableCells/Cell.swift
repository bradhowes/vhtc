//
//  Cell.swift
//  VariableHeightTableCells
//
//  Created by Brad Howes on 1/5/17.
//  Copyright © 2017 Brad Howes. All rights reserved.
//

import UIKit

/** 
 Derivation of a UITableViewCell which will properly size itself so that the internal UITextView is properly laid out.
 */
final class Cell: UITableViewCell {
    @IBOutlet weak var heading: UILabel!
    @IBOutlet weak var content: FullTextView!
    @IBOutlet weak var avatar: UIImageView!

    /**
     Fill in the cell fields with given content values
     - parameter content: the content to fill in
     - returns: ourselves
     */
    func setup(content: Content) -> Cell {
        self.heading.text = content.title
        self.content.text = content.text
        self.avatar.image = content.image
        contentView.layoutIfNeeded()
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
