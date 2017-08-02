//
//  DataSource.swift
//  VariableHeightTableCells
//
//  Created by Brad Howes on 1/6/17.
//  Copyright © 2017 Brad Howes. All rights reserved.
//

import UIKit

extension RandomGenerator {
    public mutating func bounded(lower: Int, upper: Int) -> Int {
        return Int(randomClosed() * Double(upper - lower)) + lower
    }
}

/**
 Content provider for the table view. Each cell contains a title in a UILabel, a block of text in a UITextField, and an
 image shown in a UIImageView.
 */
final class DataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    var count: Int { return contents.count }
    private var contents = [Content]()

    /**
     Intiialize content data
     - parameter cellIdent: the identifier to use when registering a cell in the table view
     - parameter count: the number of cells to create in the table
     */
    init(count: Int) {
        var randomGenerator = Xoroshiro(seed: (123, 123))
        let lig = LoremIpsumGenerator(randomGenerator: randomGenerator)
        let dates = lig.poissonIntervals(count: count, duration: 60 * 60 * 24 * 30)
        contents.append(Content(when: dates.first!))
        for index in 0..<count {
            let title = lig.title()
            let text = lig.sentences(count: randomGenerator.bounded(lower: 1, upper: 3)) + " END"
            let image = lig.imagePlaceholder(size: CGSize(width: 48.0, height: 48.0))
            let when = dates[index]
            let content = Content(title: title, text: text, image: image, when: when)
            if !contents.last!.sameDay(when) {
                contents.append(Content(when: when))
            }
            contents.append(content)
        }
    }

    /**
     Obtain the number of elements in the table
     - parameter tableView: the UITableView being queried
     - parameter section: the section in the table being queried (always 0 here)
     - returns: row count
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }

    /**
     Obtain a formatted Cell instance for displaying in the table view.
     - parameter tableView: the UITableView being displayed
     - parameter indexPath: the row being shown
     - returns: the UITableViewCell instance holding the data to show in the cell
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let content = self.contents[indexPath.row]
        switch content.ident {
        case .DataCell:
            let cell: DataCell = tableView.dequeueReusableCell(withIdentifier: content.ident.rawValue) as! DataCell
            return cell.setup(content: content)
        case .DayMarkerCell:
            let cell: DayMarkerCell = tableView.dequeueReusableCell(withIdentifier: content.ident.rawValue) as! DayMarkerCell
            return cell.setup(content: content)
        }
    }

    /** 
     Support indexing, forwarding request to the internal content array.
     */
    subscript(index: Int) -> Content {
        return contents[index]
    }

    /**
     Support the map operation to convert the held array of content into an array of cell heights.
     - parameter closure: the closure to operate on each element in the content array
     - returns: array of cell heights
     */
    func map(_ closure: (Content) -> CGFloat) -> [CGFloat] {
        return contents.map(closure)
    }
}
