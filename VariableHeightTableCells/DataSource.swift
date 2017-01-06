//
//  DataSource.swift
//  VariableHeightTableCells
//
//  Created by Brad Howes on 1/6/17.
//  Copyright © 2017 Brad Howes. All rights reserved.
//

import UIKit

public struct Content {
    let title: String
    let text: String
    let image: UIImage
}

/** 
 Content provider for the table view. Each cell contains a title in a UILabel, a block of text in a UITextField, and an
 image shown in a UIImageView.
 */
final public class DataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    public let cellIdent: String
    public var count: Int { return content.count }
    private var content = [Content]()

    /**
     Intiialize content data
     - parameter cellIdent: the identifier to use when registering a cell in the table view
     - parameter count: the number of cells to create in the table
     */
    init(cellIdent: String, count: Int) {
        self.cellIdent = cellIdent

        let lig = LoremIpsumGenerator()
        for _ in 0..<count {
            let title = lig.title()
            let text = lig.words(count: randomInt(lowerBound: 1, upperBound: 30)) + " END"
            let image = lig.imagePlaceholder(size: CGSize(width: 48.0, height: 48.0))
            content.append(Content(title: title, text: text, image: image))
        }
    }

    /**
     Obtain the number of elements in the table
     - parameter tableView: the UITableView being queried
     - parameter section: the section in the table being queried (always 0 here)
     - returns: row count
     */
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content.count
    }

    /**
     Obtain a formatted Cell instance for displaying in the table view.
     - parameter tableView: the UITableView being displayed
     - parameter indexPath: the row being shown
     - returns: the UITableViewCell instance holding the data to show in the cell
     */
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdent) as! Cell
        return cell.setup(content: content[indexPath.row])
    }

    /** 
     Support indexing, forwarding request to the internal content array.
     */
    public subscript(index: Int) -> Content {
        return content[index]
    }

    /**
     Support the map operation to convert the held array of content into an array of cell heights.
     - parameter closure: the closure to operate on each element in the content array
     - returns: array of cell heights
     */
    public func map(_ closure: (Content) -> CGFloat) -> [CGFloat] {
        return content.map(closure)
    }
}
