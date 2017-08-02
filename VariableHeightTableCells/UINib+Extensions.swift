//
//  UINib+Extensions.swift
//  VariableHeightTableCells
//
//  Created by Brad Howes on 8/1/17.
//  Copyright © 2017 Brad Howes. All rights reserved.
//

import UIKit

/** 
 Internal class that allows us to find the bundle that contains it.
 */
private class OurBundle: NSObject {

    static let name = "BundleName"

    /// Obtain the Bundle that contains ourselves and our resources
    public static var bundle: Bundle  = {

        // This is convoluted to support instantiation within Xcode due to IB processing and CocoaPods processing which
        // will have different results.
        //
        let bundle = Bundle(for: OurBundle.self)
        if let path = bundle.path(forResource: OurBundle.name, ofType: "bundle") {
            if let inner = Bundle(path: path) {

                // This is the result for proper CocoaPods support
                //
                return inner
            }
        }

        // This is the result for non-CocoaPods (e.g. Xcode) support
        //
        return bundle
    }()
}

extension UINib {

    /**
     Instantiate a new NIB using a CellIdent enumeration to determine which one. Only works if the CellIdent's 
     `rawString` value is the same as the name of a NIB file in the main bundle.

     - parameter ident: the NIB to load
     */
    convenience init(ident: CellIdent) {
        let nibName: String = ident.rawValue
        self.init(nibName: nibName, bundle: OurBundle.bundle)
    }

    /**
     Generic class method that will instantiate a NIB based on the given kind value, where T is the view class name
     for instance in the NIB.

     - parameter kind: the key to work with
     - returns: instance of T
     */
    class func instantiate<T>(ident: CellIdent) -> T {
        return UINib(ident: ident).instantiate(withOwner: nil, options: nil)[0] as! T
    }
}
