//
//  ViewController.swift
//  LMRefresh
//
//  Created by 刘明 on 15/7/23.
//  Copyright (c) 2015年 Ming. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView: UITableView!
    
    var refreshHeader: LMRefreshHeader!
    var refreshFooter: LMRefreshFooter!
    var total: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = UIRectEdge.Bottom | UIRectEdge.Left | UIRectEdge.Right
        
        self.title = "LMRefresh"
        self.automaticallyAdjustsScrollViewInsets = false
        
        var tv = UITableView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height - 64), style: .Plain)
        self.view.addSubview(tv)
        tableView = tv
        tableView.delegate = self
        tableView.dataSource = self
        
        total = 0
        
        refreshHeader = LMRefreshHeader()
        refreshHeader.scrollView = tableView
        refreshHeader.header()
        
        refreshHeader.beginRefreshingBlock = {
            dispatch_async(dispatch_get_global_queue(0, 0), { () -> Void in
                sleep(2)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.total = 10
                    self.tableView.reloadData()
                    self.refreshHeader.endRefreshing()
                })
            })
        }
        
        refreshHeader.beginRefreshing()
        
        refreshFooter = LMRefreshFooter()
        refreshFooter.scrollView = tableView
        refreshFooter.footer()
        
        refreshFooter.beginFoooterRefreshingBlock = {
            dispatch_async(dispatch_get_global_queue(0, 0), { () -> Void in
                sleep(2)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.total = self.total + 5
                    self.tableView.reloadData()
                    self.refreshFooter.endRefreshing()
                })
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return total
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "Cell")
        }
        cell!.textLabel!.text = "\(indexPath.row)"
        return cell!
    }

}

