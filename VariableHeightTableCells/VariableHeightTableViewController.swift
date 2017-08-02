//
//  VariableHeightTableViewController
//  VariableHeightTableCells
//
//  Created by Brad Howes on 1/5/17.
//  Copyright © 2017 Brad Howes. All rights reserved.
//

import UIKit

enum Strategy {
    case estimated
    case cached
}

/**
 Adaptation of UITableViewController for one with cells that have varying heights. Relies on an instance of DataSource
 to provide data for the table, and a height calculating strategy class which hopefully provides fast answers to the
 question of how high a cell is.
 */
final class VariableHeightTableViewController: UITableViewController {

    private var dataSource: DataSource!
    private var heightCalculationStrategy: HeightCalculationStrategy!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = DataSource(count: 300)
        tableView.dataSource = dataSource
        for ident in CellIdent.all {
            tableView.register(ident: ident)
        }
        heightCalculationStrategy = make(strategy: .cached)
    }

    /**
     Notification that the managed view is about to appear to the user. Make sure that our height calculating strategy
     is ready with accurate answers.

     - parameter animated: true if the view will appear in an animation
     */
    override func viewWillAppear(_ animated: Bool) {
        heightCalculationStrategy.cellWidth = view.frame.width
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.tableView.scrollToRow(at: IndexPath(row: self.dataSource.count - 1, section: 0), at: .bottom,
                                       animated: false)
        }
    }

    /**
     Notification that the managed view is about to transform in size. Causes the recalculation of cell heights after
     the transformation is complete.

     - parameter size: the new size for the view
     - parameter coordinator: the object that is managing the transformation
     */
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in }) { _ in
            self.heightCalculationStrategy.cellWidth = size.width
        }
    }

    /**
     Tell table view how many sections there are
    
     - parameter tableView: the table to inform
     - returns: 1
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    /**
     Tell table view the height of a specific row element
    
     - parameter tableView: the table to inform
     - parameter indexPath: the index of the row to report on
     - returns: the height
     */
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightCalculationStrategy.getHeight(for: self.dataSource[indexPath.row], at: indexPath)
    }

    /*
     Notification that memory is running low.
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /**
     Create the desired height calculation strategy.
    
     - parameter useFast: create
     - returns: strategy instance
     */
    private func make(strategy: Strategy) -> HeightCalculationStrategy {
        switch strategy {
        case .estimated:
            return EstimatedHeightCalculationStrategy(idents: CellIdent.all, tableView: tableView,
                                                      estimatedHeight: 80.0)
        case .cached: return CachedHeightArrayStrategy(idents: CellIdent.all, tableView: tableView,
                                                       dataSource: dataSource)
        }
    }
}
