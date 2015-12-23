//
//  LMRefreshFooter.swift
//  LMRefresh
//
//  Created by 刘明 on 15/7/23.
//  Copyright (c) 2015年 Ming. All rights reserved.
//

import UIKit


class LMRefreshFooter: NSObject {
    
    var contentHeight: CGFloat!
    var scrollFrameHeight: CGFloat!
    var footerHeight: CGFloat!
    var scrollWidth: CGFloat!
    var isAdd: Bool!    //是否添加了footer,默认是false
    var isRefresh: Bool!
    
    var footerView: UIView?
    var activityView: UIActivityIndicatorView?
    
    var scrollView: UIScrollView?
    var beginFoooterRefreshingBlock: BeginRefreshingBlock = {}
    
    func footer() {
        
        scrollWidth = scrollView!.frame.size.width
        footerHeight=35;
        scrollFrameHeight = scrollView!.frame.size.height
        isAdd = false
        isRefresh = false
        
        footerView = UIView()
        activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        
        scrollView!.addObserver(self,
            forKeyPath: "contentOffset",
            options: [NSKeyValueObservingOptions.New, NSKeyValueObservingOptions.Old],
            context: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath != "contentOffset" {
            return
        }
        
        contentHeight = scrollView!.contentSize.height
        
        if !isAdd {
            isAdd = true
            
            footerView!.frame = CGRectMake(0, contentHeight, scrollWidth, footerHeight)
            scrollView!.addSubview(footerView!)
            
            activityView!.frame = CGRectMake((scrollWidth-footerHeight)/2, 0, footerHeight, footerHeight)
            footerView!.addSubview(activityView!)
        }
        
        footerView!.frame = CGRectMake(0, contentHeight, scrollWidth, footerHeight)
        activityView!.frame = CGRectMake((scrollWidth-footerHeight)/2, 0, footerHeight, footerHeight)
        
        let currentPosition = scrollView!.contentOffset.y
        
        if (currentPosition > contentHeight - scrollFrameHeight) && (contentHeight > scrollFrameHeight) {
            self.beginRefreshing()
        }
    }
    
    func beginRefreshing() {
        if !isRefresh {
            isRefresh = true
            activityView!.startAnimating()
            
            // 设置刷新状态_scrollView的位置
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.scrollView!.contentInset = UIEdgeInsetsMake(0, 0, self.footerHeight, 0)
            })
            
            // 回调
            beginFoooterRefreshingBlock()
        }
    }
    
    func endRefreshing() {
        isRefresh = false
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.activityView!.stopAnimating()
            
            self.scrollView!.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
            self.footerView!.frame = CGRectMake(0, self.contentHeight, UIScreen.mainScreen().bounds.size.width, self.footerHeight)
        })
    }
    
    deinit {
        scrollView!.removeObserver(self, forKeyPath: "contentOffset", context: nil)
        print("LMRefreshHeader is being deInitialized.")
    }
}
