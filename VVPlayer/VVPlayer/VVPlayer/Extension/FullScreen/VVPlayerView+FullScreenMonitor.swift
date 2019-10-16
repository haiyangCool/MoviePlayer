//
//  VVPlayerView+FullScreen.swift
//  VVPlayer
//
//  Created by 王海洋 on 2018/10/14.
//  Copyright © 2019 王海洋. All rights reserved.
//

import Foundation
import UIKit

private var FullScreenKey: Void?
private var CanRotateKey: Void?

/** 播放器屏幕方向*/
extension VVPlayerView {
    
    /// 开启设备旋转监听
    public func startScreenOrientationMonitor() {
        NotificationCenter.default.addObserver(self, selector: #selector(screenRotate(notification:)), name: UIDevice.orientationDidChangeNotification, object: nil)
        
    }

    /// 移除监听
    public func stopScreenOrientationMonitor() {
        NotificationCenter.default.removeObserver(self)

//        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    @objc fileprivate func screenRotate(notification:Notification) {
        
        if !canRotate { return }
        
        let orientation = UIDevice.current.orientation
           switch orientation {
           case .portrait:
                if let screen = screen, screen.responds(to: #selector(screen.exitFullScreen(_:screen:))) {
                    
                    screen.exitFullScreen?(self, screen: .portrait)
                }
               break
           case .portraitUpsideDown:
                if let screen = screen, screen.responds(to: #selector(screen.exitFullScreen(_:screen:))) {
                    
                    screen.exitFullScreen?(self, screen: .portraitUpsideDown)
                }
               break
           case .landscapeLeft:
                if let screen = screen, screen.responds(to: #selector(screen.enterFullScreen(_:fullScreen:))) {
                    
                    screen.enterFullScreen?(self, fullScreen: .landscapeLeft)
                }
               break
           case .landscapeRight:
                if let screen = screen, screen.responds(to: #selector(screen.enterFullScreen(_:fullScreen:))) {
                    
                              screen.enterFullScreen?(self, fullScreen: .landscapeRight)
                }
               break
           case .faceUp:
                if let screen = screen, screen.responds(to: #selector(screen.faceUp(_:))) {
                    
                    screen.faceUp?(self)
                }
               break
           case .faceDown:
                if let screen = screen, screen.responds(to: #selector(screen.faceDown(_:))) {
                    
                    screen.faceDown?(self)
                }
               break
           default:
               break
        }
    }
}

extension VVPlayerView {
    
    var screen: VVPlayerScreen? {
        
        get {
            return objc_getAssociatedObject(self, &FullScreenKey) as? VVPlayerScreen
        }
        
        set {
            objc_setAssociatedObject(self, &FullScreenKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    
    /// 是否可以旋转 ， 默认为true
    var canRotate: Bool {
        
        get {
            let rotate = objc_getAssociatedObject(self, &CanRotateKey) as? Bool
            if let rota = rotate,rota == false {
                return false
            }
            return true
        }
        
        set {
            
            objc_setAssociatedObject(self, &CanRotateKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
}
