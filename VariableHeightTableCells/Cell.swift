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
public final class Cell: UITableViewCell {
    @IBOutlet weak var heading: UILabel!
    @IBOutlet weak var content: FullTextView!
    @IBOutlet weak var avatar: UIImageView!

    /**
     Fill in the cell fields with given content values
     - parameter content: the content to fill in
     - returns: ourselves
     */
    public func setup(content: Content) -> Cell {
        self.heading.text = content.title
        self.content.text = content.text
        self.avatar.image = content.image
        return self
    }

    /// Calculate and return the height of this cell using whatever content is currently in the views.
    public var cellHeightForContent: CGFloat {
        contentView.setNeedsLayout()
        contentView.layoutSubviews()
        return contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
    }

    /// The current cell width. Adjust to recalculate cell heights.
    public var cellWidth: CGFloat = 0.0 {
        didSet {
            contentView.frame = CGRect(x: 0.0, y: 0.0, width: cellWidth, height: 999.0)
            contentView.setNeedsLayout()
            contentView.layoutSubviews()
        }
    }
}
