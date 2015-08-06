//
//  LMRefreshHeader.swift
//  LMRefresh
//
//  Created by 刘明 on 15/7/23.
//  Copyright (c) 2015年 Ming. All rights reserved.
//

import UIKit
import Foundation

typealias BeginRefreshingBlock = () -> Void

let PULL_TO_REFRESH = "下拉刷新"
let RELEASE_TO_REFRESH = "松开刷新"
let TYPEING = "正在载入..."

class LMRefreshHeader: NSObject {
    
    var lastPosition: CGFloat!
    var contentHeight: CGFloat!
    var headerHeight: CGFloat!
    var isRefresh: Bool!
    
    var headerLabel: UILabel?
    var headerView: UIView?
    var headerIV: UIImageView?
    var activityView: UIActivityIndicatorView?
    
    var scrollView: UIScrollView?
    var beginRefreshingBlock: BeginRefreshingBlock = {}
    
    func header() {
        
        isRefresh = false
        lastPosition = 0
        headerHeight = 35
        
        var scrollWidth = scrollView!.frame.size.width
        var imageWidth: CGFloat = 13
        var imageHeight = headerHeight
        var labelWidth: CGFloat = 130
        var labelHeight = headerHeight
        
        headerView = UIView()
        headerView!.frame = CGRectMake(0, -headerHeight-10, scrollView!.frame.size.width, headerHeight)
        scrollView!.addSubview(headerView!)
        
        headerLabel = UILabel()
        headerLabel!.frame = CGRectMake((scrollWidth-labelWidth)/2, 0, labelWidth, labelHeight)
        headerLabel!.textAlignment = NSTextAlignment.Center
        headerLabel!.text = "下拉刷新"
        headerLabel!.font = UIFont.systemFontOfSize(14)
        headerView!.addSubview(headerLabel!)
        
        headerIV = UIImageView()
        headerIV!.frame = CGRectMake((scrollWidth-labelWidth)/2-imageWidth, 0, imageWidth, imageHeight)
        headerIV!.image = UIImage(named: "down")
        headerView!.addSubview(headerIV!)
        
        activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activityView!.frame = CGRectMake((scrollWidth-labelWidth)/2-imageWidth, 0, imageWidth, imageHeight)
        headerView!.addSubview(activityView!)
        
        activityView!.hidden = true
        headerView!.hidden = false
        
        scrollView!.addObserver(self,
            forKeyPath: "contentOffset",
            options: NSKeyValueObservingOptions.New | NSKeyValueObservingOptions.Old,
            context: nil)
    }
    
    /**
     *  当属性的值发生变化时，自动调用此方法
     */
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        if keyPath != "contentOffset" {
            return
        }
        
        // 获取scrollView的contentSize
        contentHeight = scrollView!.contentSize.height
        
        // 判断是否在拖动scrollView
        if scrollView!.dragging {
            var currentPosition = scrollView!.contentOffset.y
            // 判断是否正在刷新  否则不做任何操作
            if !isRefresh {
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    // 当currentPostion 小于某个值时变换状态
                    if currentPosition < (-self.headerHeight * 1.5) {
                        self.headerLabel!.text = RELEASE_TO_REFRESH
                        self.headerIV!.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
                    } else {
                        var currentPosition = self.scrollView!.contentOffset.y
                        // 判断滑动方向 以让“松开以刷新”变回“下拉可刷新”状态
                        if currentPosition - self.lastPosition > 5 {
                            self.lastPosition = currentPosition
                            self.headerLabel!.text = PULL_TO_REFRESH
                            self.headerIV!.transform = CGAffineTransformMakeRotation(CGFloat(M_PI*2))
                        } else if self.lastPosition - currentPosition > 5 {
                            self.lastPosition = currentPosition
                        }
                    }
                })
            }
        } else {
            if headerLabel!.text == RELEASE_TO_REFRESH {
                beginRefreshing()
            }
        }
    }
    
    /**
     *  开始刷新操作 如果正在刷新则不做操作
     */
    func beginRefreshing() {
        if !isRefresh {
            isRefresh = true
            
            headerLabel!.text = TYPEING
            headerIV!.hidden = true
            activityView!.hidden = false
            activityView!.startAnimating()
            
            // 设置刷新状态_scrollView的位置
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.scrollView!.contentInset = UIEdgeInsetsMake(self.headerHeight*1.5, 0, 0, 0)
            })
            
            // 回调
            beginRefreshingBlock()
        }
    }
    
    /**
     *  关闭刷新操作 加在UIScrollView数据刷新后，如[tableView reloadData];
     */
    func endRefreshing() {
        isRefresh = false
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.scrollView!.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
                self.headerIV!.hidden = false
                self.headerIV!.transform = CGAffineTransformMakeRotation(CGFloat(M_PI*2))
                self.activityView!.hidden = true
                self.activityView!.stopAnimating()
            })
        })
    }
    
    deinit {
        scrollView!.removeObserver(self, forKeyPath: "contentOffset", context: nil)
        println("LMRefreshHeader is being deInitialized.")
    }
}
