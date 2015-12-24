//
//  MainTableViewController.swift
//  FoldingCell
//
//  Created by Alex K. on 21/12/15.
//  Copyright © 2015 Alex K. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController {
    
    let kCloseCellHeight: CGFloat = 179
    let kOpenCellHeight: CGFloat = 488

    let kRowsCount = 10
    
    var cellHeights: [CGFloat]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createCellHeightsArray()
        self.tableView.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
    }
    
    // PRAGMA: configure
    func createCellHeightsArray() {
        cellHeights = Array()
        for _ in 0...kRowsCount {
            cellHeights?.append(kCloseCellHeight)
        }
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if cell is FoldingCell {
            let foldingCell = cell as! FoldingCell
            foldingCell.backgroundColor = UIColor.clearColor()
            
            if cellHeights![indexPath.row] == kCloseCellHeight {
                foldingCell.selectedAnimation(false, animated: false)
            } else {
                foldingCell.selectedAnimation(true, animated: false)
            }
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FoldingCell", forIndexPath: indexPath)

        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeights![indexPath.row]
    }
    
    // PRAGMA: Table vie delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! FoldingCell
        
        var duration = 0.0
        if cellHeights![indexPath.row] == kCloseCellHeight { // open cell
            cellHeights![indexPath.row] = kOpenCellHeight
            cell.selectedAnimation(true, animated: true)
            duration = 0.5
        } else {// close cell
            cellHeights![indexPath.row] = kCloseCellHeight
            cell.selectedAnimation(false, animated: true)
            duration = 1
        }
        
        
        UIView.animateWithDuration(duration, delay: 0, options: .CurveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
        }, completion: nil)
        
    }

    
    
}
