//
//  UITableView+Extensions.swift
//  VariableHeightTableCells
//
//  Created by Brad Howes on 8/1/17.
//  Copyright © 2017 Brad Howes. All rights reserved.
//

import UIKit

extension UITableView {

    /**
     Register a UITableViewCell prototype found in a NIB file. The name of the NIB file is based on the given
     CellIdent's `rawValue` value (see UINib+Extensions) as is the reuse identifier.

     - parameter kind: the value to register under
     */
    func register(ident: CellIdent) {
        register(UINib(ident: ident), forCellReuseIdentifier: ident.rawValue)
    }

    /**
     Obtain a previously-registered UITableViewCell instance

     - parameter ident: which cell type to load
     - parameter indexPath: the row of the UITableView the cell will represent
     - returns: the cell instance to use
     */
    func dequeueReusableCell<T>(withIdentifier ident: CellIdent, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: ident.rawValue, for: indexPath) as! T
    }
}
