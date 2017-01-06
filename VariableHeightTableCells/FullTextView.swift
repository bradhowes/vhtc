//
//  FullTextView.swift
//  VariableHeightTableCells
//
//  Created by Brad Howes on 1/6/17.
//  Copyright © 2017 Brad Howes. All rights reserved.
//

import UIKit

/** 
 Derivation of UITextView which supports displaying all held content properly laid out using a fixed width and a 
 variable height.
 */
final class FullTextView: UITextView, UITextViewDelegate {

    /// Holds any calculated fitted size (see updateFittedSize() below).
    var fittedSize: CGSize? = nil

    /// Override intrinsicContentSize to return calculated fittedSize if it exists
    override public var intrinsicContentSize: CGSize {
        get {
            return self.fittedSize ?? super.intrinsicContentSize
        }
    }

    /// Be aware of changes to internal text and recalculate our fitted size when it changes
    override public var attributedText: NSAttributedString! {
        didSet {
            updateFittedSize()
        }
    }

    /// Be aware of changes to internal text and recalculate our fitted size when it changes
    override public var text: String! {
        didSet {
            updateFittedSize()
        }
    }

    /**
     Recalculate the fitted size using the current layout and cell width. Will invoke `invalidateInstrinsicContentSize`
     to force the superview to reevaluate its layout.
     */
    private func updateFittedSize() {

        // Key!
        //
        let usedRect = layoutManager.usedRect(for: textContainer)
        fittedSize = CGSize(width: (usedRect.size.width + textContainerInset.left + textContainerInset.right),
                            height: (usedRect.size.height + textContainerInset.top + textContainerInset.bottom))
        invalidateIntrinsicContentSize()
    }
}
