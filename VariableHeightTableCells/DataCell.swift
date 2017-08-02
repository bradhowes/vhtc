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
final class DataCell: Cell {

    /// CellIdent enum that represents this cell type
    static let cellIdent: CellIdent = .DataCell

    override var cellIdent: CellIdent { return DataCell.cellIdent }

    @IBOutlet weak var heading: UILabel!
    @IBOutlet weak var content: FullTextView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var when: UILabel!

    /// DateFormatter that only shows the time of the message in the lower-right (eg 10:30 AM)
    static let timeFormatter: DateFormatter = {
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        timeFormatter.dateStyle = .none
        return timeFormatter
    }()

    /**
     Fill in the cell fields with given content values
     - parameter content: the content to fill in
     - returns: ourselves
     */
    override func setup(content: Content) -> Cell {
        let s = DataCell.timeFormatter.string(for: content.when)!
        self.when.text = s
        self.heading.text = content.title

        // Append to the text a string of non-breaking spaces which will basically force the text layout to avoid
        // overlapping the timestamp.
        //
        self.content.text = content.text + " " + String(repeating: "\u{00A0}", count: s.characters.count * 2)
        self.avatar.image = content.image
        self.contentView.layoutIfNeeded()
        return self
    }

    static func instantiate() -> DataCell {
        return UINib.instantiate(ident: cellIdent)
    }
}
