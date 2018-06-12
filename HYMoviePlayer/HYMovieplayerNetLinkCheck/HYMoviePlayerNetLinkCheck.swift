//
//  HYMoviePlayerNetLinkCheck.swift
//  HYMoviePlayer
//
//  Created by hyw on 2018/5/8.
//  Copyright © 2018年 王海洋. All rights reserved.
//
/**
    监听网络状态
    判断当前网络情况
 */
import UIKit
import Reachability
class HYMoviePlayerNetLinkCheck: NSObject {

    /// 网络监测接口
    var netLinkProtocol:HYMoviePlayerNetLinkListenProtocol?
    fileprivate var reachability:Reachability!
    override init() {
        super.init()
        reachability = Reachability.init()
    }
}
/** 被动去判断链接网络的状态*/
extension HYMoviePlayerNetLinkCheck {
    
    /// 检测是否连接网络
    func isConnectNet() -> Bool {
        return self.reachability.connection != .none
    }
    
    /// 检测是否连接的是WIFI
    func isConnectWifi() -> Bool {
        return self.reachability.connection == .wifi
    }
    
    /// 检测连接的是移动流量
    func isConnectCellular() -> Bool {
        return self.reachability.connection == .cellular
    }
}

/** 主动监听链接网络的状态*/
extension HYMoviePlayerNetLinkCheck {
    
    /// 监听网络
    func startMonitor() {
        NotificationCenter.default.addObserver(self, selector: #selector(responseNetLinkStateChange(notification:)), name: Notification.Name.reachabilityChanged, object: self.reachability)
        do {
            try self.reachability.startNotifier()
        } catch {
            print("不可用")
        }
    }
    @objc fileprivate func responseNetLinkStateChange(notification:Notification) {
        let reachability:Reachability = notification.object as! Reachability
        if reachability.connection == .none {
            /// 断开了网络
            self.netLinkProtocol?.hyMoviePlayerLoseNetLink()
        }else {
            if reachability.connection == .wifi {
                /// wifi
                self.netLinkProtocol?.hyMoviePlayerNetLinkWifi()
            }else {
                /// 移动数据
                self.netLinkProtocol?.hyMoviePlayerNetLinkCellular()
            }
        }
    }
    /// 移除网络监听
    func stopMonitor()  {
        NotificationCenter.default.removeObserver(self)
    }
}
