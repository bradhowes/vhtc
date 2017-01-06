//
//  HeightCalculationStrategy.swift
//  VariableHeightTableCells
//
//  Created by Brad Howes on 1/6/17.
//  Copyright © 2017 Brad Howes. All rights reserved.
//

import UIKit

public protocol HeightCalculationStrategy {
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
public class BaseHeightCalculationStrategy: HeightCalculationStrategy {

    fileprivate let tableView: UITableView
    fileprivate var verticalSpacing: CGFloat { return tableView.separatorInset.top + tableView.separatorInset.bottom }
    fileprivate let sizer: Cell

    /// Be aware when the cell width changes and take action when it does
    public var cellWidth: CGFloat = 0.0 {
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
    public init(cellIdent: String, tableView: UITableView) {
        self.tableView = tableView

        // Fetch an instance of the cell view from the main bundle to use for sizing operations.
        //
        self.sizer = UINib(nibName: cellIdent, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! Cell
    }
    
    /**
     Notification that the internal cellWidth value changed. Prepare to recalculate all of the cell heights.
     */
    fileprivate func cellWidthChanged() {
        sizer.cellWidth = cellWidth
        tableView.reloadData()
    }

    /**
     Obtain the height of a cell when it holds a given sent of content
     - parameter content: data to put into the cell
     - parameter indexPath: the index of the cell being measured
     - returns: calculated height of the cell as it would appear in the table
     */
    public func getHeight(for content: Content, at indexPath: IndexPath) -> CGFloat {
        return (sizer.setup(content: content).cellHeightForContent + verticalSpacing).rounded()
    }
}

/** 
 Cell height calculation strategy that leverages UITableView's `estimatedRowHeight` setting. As long as the estimate is
 fairly representative of the cells in the table, this is the best approach for speed.
 */
public class EstimatedHeightCalculationStrategy: BaseHeightCalculationStrategy {

    /**
     Initialize new instance.
     - parameter cellIdent: the identifier to use for the cell that has variable height
     - parameter tableView: the table view that has variable height cells
     - parameter estimatedHeight: an estimate of the cell height
     */
    public init(cellIdent: String, tableView: UITableView, estimatedHeight: CGFloat) {
        super.init(cellIdent: cellIdent, tableView: tableView)

        // Key!
        //
        tableView.estimatedRowHeight = estimatedHeight
    }
}

/** 
 Cell height calculation strategy that maintains a cache of height values. This is fast, but there are problems for 
 large table sizes due to the stall that takes place when recalculating them all.
 */
public class CachedHeightArrayStrategy: BaseHeightCalculationStrategy {

    private var heights: [CGFloat] = [CGFloat]()
    private let dataSource: DataSource

    /**
     Initialize new instance.
     - parameter cellIdent: the identifier to use for the cell that has variable height
     - parameter tableView: the table view that has variable height cells
     - parameter dataSource: the data source for the table
     */
    public init(cellIdent: String, tableView: UITableView, dataSource: DataSource) {
        self.dataSource = dataSource
        super.init(cellIdent: cellIdent, tableView: tableView)
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
    override public func getHeight(for content: Content, at indexPath: IndexPath) -> CGFloat {
        if heights.count == 0 {
            heights = dataSource.map { (sizer.setup(content: $0).cellHeightForContent + verticalSpacing).rounded() }
        }
        return heights[indexPath.row]
    }
}
