//
//  HYMoviePlayerActivityMonitor.swift
//  HYMoviePlayer
//
//  Created by hyw on 2018/5/10.
//  Copyright © 2018年 王海洋. All rights reserved.
//
/**
    监听播放器进入后台、前台
 */
import UIKit

class HYMoviePlayerActivityMonitor: NSObject {
    var playerActivityProtocol:HYMoviePlayerEnterBackOrForegroundProtocol?
    override init() {
        super.init()
    }
}
/// Delegate methods
extension HYMoviePlayerActivityMonitor {
    
    /// 进入后台
    @objc fileprivate func playerEnterForeground(notification:Notification) {
        self.playerActivityProtocol?.hyMoviePlayerEnterforeground()
    }
    /// 进入后台
    @objc fileprivate func playerEnterBackground(notification:Notification) {
        self.playerActivityProtocol?.hyMoviePlayerEnterBackground()
    }
    

}
/// Public methods
extension HYMoviePlayerActivityMonitor {
    /// 开启监听
    func startMonitor() {
        NotificationCenter.default.addObserver(self, selector: #selector(playerEnterForeground(notification:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerEnterBackground(notification:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    func stopMonitor() {
        NotificationCenter.default.removeObserver(self)
    }
}

