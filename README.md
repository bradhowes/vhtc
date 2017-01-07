# Variable Height UITextView in UITableView Cells

The project shows how to properly create UITableView cells with UITextView elements so that the cells quickly
and properly adjust their height to account for the UITextView content while honoring existing Auto Layout
constraints. The animation below shows how fast the resizing can be with a table containing 10,000 UTextView
cells of varying content.

![](http://i.giphy.com/l4JyYzNPNl6j37DUY.gif)

## Approach

The class `FullTextView` is a derivative of
[`UITextView`](https://developer.apple.com/reference/uikit/uitextview) which simply keeps up-to-date its
`intrinsicContentSize` so that it matches the size obtained by its internal `NSLayoutManager`. Doing so allows
Auto Layout to proprerly adjust surrounding cells to honor their constraints, and for the parent view to update
its size to match that of its content.

The class `Cell` is a derivative of
[`UITableViewCell`](https://developer.apple.com/reference/uikit/uitableviewcell) which offers a method
`cellHeightForContent` that properly queries the cell's content view for its best layout size. This is the value
that will be the basis for the answer to the table view's question, "How tall is this cell?"

I created two height calculation strategies to help with measuring performance, especially with large number of
items:

* EstimatedHeightCalculatingStrategy - provides `UITableView` with an constant estimate of row height, and then
  an accurate value later when asked by `UITableView`.

* CachedHeightArrayStrategy - calculates row heights up-front, always returning an accurate value to
  `UITableView`.

The first approach is by far the fastest for very large cell counts. Using a background thread to help with the
recalculations might help the second approach but I'm not sure the complexity is really worth the effort given
how fast and simple the first strategy is. For anything above a cell count of 500 or so, the second approach
demands too much time before the table appears to the user.

## License

This project is licensed under the terms of the [MIT license](blob/master/LICENSE).
