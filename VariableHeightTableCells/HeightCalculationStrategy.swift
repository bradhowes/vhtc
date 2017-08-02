//
//  HeightCalculationStrategy.swift
//  VariableHeightTableCells
//
//  Created by Brad Howes on 1/6/17.
//  Copyright © 2017 Brad Howes. All rights reserved.
//

import UIKit

protocol HeightCalculationStrategy {

    var cellWidth: CGFloat {get set}

    /**
     Obtain the height of a cell when it holds a given sent of content
     - parameter content: data to put into the cell
     - parameter indexPath: the index of the cell being measured
     - returns: calculated height of the cell as it would appear in the table
     */
    func getHeight(for content: Content, at indexPath: IndexPath) -> CGFloat
}

/**
 Base class for height calculation strategies.
 */
class BaseHeightCalculationStrategy: HeightCalculationStrategy {

    fileprivate let tableView: UITableView
    fileprivate var verticalSpacing: CGFloat { return tableView.separatorInset.top + tableView.separatorInset.bottom }
    fileprivate var sizers = [CellIdent:Cell]()

    /// Be aware when the cell width changes and take action when it does
    var cellWidth: CGFloat = 0.0 {
        didSet {
            if cellWidth != oldValue {
                cellWidthChanged()
            }
        }
    }

    /**
     Initialize new instance.
     - parameter cellIdent: the identifier to use for the cell that has variable height
     - parameter tableView: the table view that has variable height cells
     */
    init(idents: [CellIdent], tableView: UITableView) {
        self.tableView = tableView

        // Fetch an instance of the cell view from the main bundle to use for sizing operations.
        //
        for ident in idents {
            let cell = UINib(nibName: ident.rawValue, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! Cell
            self.sizers[ident] = cell
        }
    }

    /**
     Notification that the internal cellWidth value changed. Prepare to recalculate all of the cell heights.
     */
    fileprivate func cellWidthChanged() {
        for (_, v) in self.sizers {
            v.cellWidth = self.cellWidth
        }
        tableView.reloadData()
    }

    /**
     Obtain the height of a cell when it holds a given sent of content
     - parameter content: data to put into the cell
     - parameter indexPath: the index of the cell being measured
     - returns: calculated height of the cell as it would appear in the table
     */
    func getHeight(for content: Content, at indexPath: IndexPath) -> CGFloat {
        return (sizers[content.ident]!.setup(content: content).cellHeightForContent + verticalSpacing).rounded(.up)
    }
}

/** 
 Cell height calculation strategy that leverages UITableView's `estimatedRowHeight` setting. As long as the estimate is
 fairly representative of the cells in the table, this is the best approach for speed.
 */
class EstimatedHeightCalculationStrategy: BaseHeightCalculationStrategy {

    /**
     Initialize new instance.
     - parameter cellIdent: the identifier to use for the cell that has variable height
     - parameter tableView: the table view that has variable height cells
     - parameter estimatedHeight: an estimate of the cell height
     */
    public init(idents: [CellIdent], tableView: UITableView, estimatedHeight: CGFloat) {
        super.init(idents: idents, tableView: tableView)

        // Key!
        //
        tableView.estimatedRowHeight = estimatedHeight
    }
}

/** 
 Cell height calculation strategy that maintains a cache of height values. This is fast, but there are problems for 
 large table sizes due to the stall that takes place when recalculating them all.
 */
class CachedHeightArrayStrategy: BaseHeightCalculationStrategy {

    private var heights: [CGFloat] = [CGFloat]()
    private let dataSource: DataSource

    /**
     Initialize new instance.
     - parameter cellIdent: the identifier to use for the cell that has variable height
     - parameter tableView: the table view that has variable height cells
     - parameter dataSource: the data source for the table
     */
    init(idents: [CellIdent], tableView: UITableView, dataSource: DataSource) {
        self.dataSource = dataSource
        super.init(idents: idents, tableView: tableView)
    }

    /**
     Notification that the internal cellWidth value changed. Forget the cached height values.
     */
    override func cellWidthChanged() {
        heights.removeAll(keepingCapacity: true)
        super.cellWidthChanged()
    }

    /**
     Obtain the height of a cell when it holds a given sent of content
     - parameter content: data to put into the cell
     - parameter indexPath: the index of the cell being measured
     - returns: calculated height of the cell as it would appear in the table
     */
    override func getHeight(for content: Content, at indexPath: IndexPath) -> CGFloat {
        if heights.count == 0 {
            heights = dataSource.map { (sizers[$0.ident]!.setup(content: $0).cellHeightForContent + verticalSpacing).rounded(.up) }
        }
        return heights[indexPath.row]
    }
}
