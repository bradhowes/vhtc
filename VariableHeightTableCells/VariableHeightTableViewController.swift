//
//  VariableHeightTableViewController
//  VariableHeightTableCells
//
//  Created by Brad Howes on 1/5/17.
//  Copyright © 2017 Brad Howes. All rights reserved.
//

import UIKit

/**
 Adaptation of UITableViewController for one with cells that have varying heights. Relies on an instance of DataSource
 to provide data for the table, and a height calculating strategy class which hopefully provides fast answers to the
 question of how high a cell is.
 */
final public class VariableHeightTableViewController: UITableViewController {

    private var cellIdent: String!
    private var dataSource: DataSource!
    private var heightCalculationStrategy: HeightCalculationStrategy!

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.cellIdent = "Cell"
        self.dataSource = DataSource(cellIdent: cellIdent, count: 100)
        tableView.dataSource = dataSource
        tableView.register(UINib(nibName: cellIdent, bundle: nil), forCellReuseIdentifier: cellIdent)

        heightCalculationStrategy = makeStrategy(useFast: false)
    }

    /**
     Notification that the managed view is about to appear to the user. Make sure that our height calculating strategy
     is ready with accurate answers.

     - parameter animated: true if the view will appear in an animation
     */
    public override func viewWillAppear(_ animated: Bool) {
        heightCalculationStrategy.cellWidth = view.frame.width
        super.viewWillAppear(animated)
    }

    /**
     Notification that the managed view is about to transform in size. Causes the recalculation of cell heights after
     the transformation is complete.

     - parameter size: the new size for the view
     - parameter coordinator: the object that is managing the transformation
     */
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in }) { _ in
            self.heightCalculationStrategy.cellWidth = size.width
        }
    }

    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightCalculationStrategy.getHeight(for: self.dataSource[indexPath.row], at: indexPath)
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func makeStrategy(useFast: Bool) -> HeightCalculationStrategy {
        if useFast {
            return EstimatedHeightCalculationStrategy(cellIdent: cellIdent,
                                                      tableView: tableView,
                                                      estimatedHeight: 86.0)
        }
        else {
            return CachedHeightArrayStrategy(cellIdent: cellIdent,
                                             tableView: tableView,
                                             dataSource: dataSource)
        }
    }
}
