//
//  VVPlayerView+ActivityMonitor.swift
//  VVPlayer
//
//  Created by 王海洋 on 2017/10/14.
//  Copyright © 2019 王海洋. All rights reserved.
//

import Foundation
import UIKit
private var ActivityKey: Void?
/**监听播放器进入前台播放、退到后台*/
extension VVPlayerView {
    
    
    /// 开启播放器活跃监听
    public func startActiveMonitor() {
        NotificationCenter.default.addObserver(self, selector: #selector(enterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
           
    }
      
    /// 移除监听
    public func stopActiveMonitor() {
        NotificationCenter.default.removeObserver(self)
//        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
//        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc fileprivate func enterForeground() {
        
        if let active = active, active.responds(to: #selector(active.playerBecomeActive(_:))) {
            active.playerBecomeActive?(self)
        }
    }
    
    @objc fileprivate func enterBackground() {
        
        if let active = active, active.responds(to: #selector(active.playerResignActive(_:))) {
            active.playerResignActive?(self)
        }
    }
    
}

extension VVPlayerView {
    
    /// 播放器活跃状态
    var active: VVPlayerActive? {
        
        get {
            return objc_getAssociatedObject(self, &ActivityKey) as? VVPlayerActive
        }
        
        set {
            
            objc_setAssociatedObject(self, &ActivityKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
