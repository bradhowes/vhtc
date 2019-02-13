//
//  VariableHeightTableCellsUITests.swift
//  VariableHeightTableCellsUITests
//
//  Created by Brad Howes on 1/8/17.
//  Copyright © 2017 Brad Howes. All rights reserved.
//

import XCTest

class VariableHeightTableCellsUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launch()
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func testExample() {
        print(app.debugDescription)
        XCUIDevice.shared.orientation = .portrait
        XCTAssertEqual(XCUIApplication().tables.cells.count, 343)
    }
}
