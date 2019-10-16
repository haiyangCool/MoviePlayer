//
//  VVPlayerView+NetMonitor.swift
//  VVPlayer
//
//  Created by 王海洋 on 2018/10/16.
//  Copyright © 2019 王海洋. All rights reserved.
//

import Foundation
import UIKit
import Reachability
private var ReachablityKey: Void?
private var NetDelegateKey: Void?
private var NetStateKey: Void?

// MARK: 所处网络环境
@objc enum NetEnvironment: Int {
    case wifi
    case celluar
    case none
}
@objc protocol VVNetMonitor: NSObjectProtocol {
    
    @objc optional func netChanged(_ state: NetEnvironment)
}
// MARK: 网络监听

extension VVPlayerView {
    
    public func startNetMonitor() {
        hasNet = true
        if reachablity == nil {
            reachablity = Reachability.init()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(netChange(_:)), name: NSNotification.Name.reachabilityChanged, object: reachablity)
        
        try? reachablity?.startNotifier()
    }
    
    public func stopNetMonitor() {
        NotificationCenter.default.removeObserver(self)
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.reachabilityChanged, object: reachablity)
    }
}

extension VVPlayerView {
    
    @objc private func netChange(_ noti: Notification) {
        
        let reachability:Reachability = noti.object as! Reachability
        var netState: NetEnvironment = .none
        let connection = reachability.connection
        if connection == .none {
            hasNet = false
            netState = .none
        }
        if connection == .wifi {
            netState = .wifi
        }
        if connection == .cellular {
            netState = .celluar
        }
        guard let delegate = netDelegate, delegate.responds(to: #selector(delegate.netChanged(_:))) else { return }
        delegate.netChanged?(netState)
    }
}

extension VVPlayerView {
    
    var reachablity: Reachability? {
       get {
           return objc_getAssociatedObject(self, &ReachablityKey) as? Reachability
       }
       set {
           objc_setAssociatedObject(self, &ReachablityKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
       }
   }
    
    var netDelegate: VVNetMonitor? {
        
        get {
            
            return objc_getAssociatedObject(self, &NetDelegateKey) as? VVNetMonitor
        }
        
        set {
            objc_setAssociatedObject(self, &NetDelegateKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    var hasNet: Bool {
        
        get {
            let net = objc_getAssociatedObject(self, &NetStateKey) as? Bool
            if let net = net {
                return net
            }
            return true
        }
        
        set {
            objc_setAssociatedObject(self, &NetStateKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
            
        }
    }
    
}
