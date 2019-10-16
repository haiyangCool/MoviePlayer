//
//  VVPlayerView+FullScreen.swift
//  VVPlayer
//
//  Created by 王海洋 on 2018/10/16.
//  Copyright © 2019 王海洋. All rights reserved.
//

import Foundation
import UIKit

// MARK: 播放器全屏（扩展）
private var FullScreenKey: Bool?

extension VVPlayerView {
    
    func fullScreenExtension() {
        coverView.fullScreenAction = self
        screen = self
        startScreenOrientationMonitor()
    }
}

// MARK: UI Action
extension VVPlayerView: VVPlayerFullScreenAction {
    
    func enterFullScreen(_ coverView: VVPlayerCoverView) {
        landscapeLeft()
    }
    
    func exitFullScreen(_ coverView: VVPlayerCoverView) {
        portraitLayout()
    }
}

extension VVPlayerView: VVPlayerScreen {
    
    func faceUp(_ player: VVPlayerView) {
        
    }
    func faceDown(_ player: VVPlayerView) {
        
    }
    
    func enterFullScreen(_ player: VVPlayerView, fullScreen direction: VVPlayerDirection) {
        
        if direction == .landscapeLeft {
            landscapeLeft()
        }
        if direction == .landscapeRight {
            landscapeRight()
        }
        coverView.showShrikenScreenButton()
    }
    
    func exitFullScreen(_ player: VVPlayerView, screen direction: VVPlayerDirection) {
        
        portraitLayout()
        coverView.showFullScennButton()
    }
    
}

// MARK: Private rotate screen
extension VVPlayerView {
    
    // default fullScreen layout
    private func landscapeLeft() {
        if isFullScreen {
            if UIDevice.current.orientation == .landscapeLeft {
                // 180·
                UIView.animate(withDuration: 0.5) {
                    self.layer.transform = CATransform3DIdentity
                    self.layer.transform = CATransform3DMakeRotation(.pi/2, 0, 0, 1)
                }
                return
            }
            return
        }
        self.isFullScreen = true
        let fullScreenFrame = fullScreenFrameForIPhone()
        UIView.animate(withDuration: 0.3, animations: {
            self.reLayoutPlayer(frame: fullScreenFrame)
            self.layer.transform = CATransform3DMakeRotation(.pi/2.0, 0, 0, 1)
        }) { (flag) in
        }
    }
    
    private func landscapeRight() {
        if isFullScreen {
            if UIDevice.current.orientation == .landscapeRight {
                // 180·
                UIView.animate(withDuration: 0.5) {
                    self.layer.transform = CATransform3DIdentity
                    self.layer.transform = CATransform3DMakeRotation(-.pi/2, 0, 0, 1)
                }
                return
            }
            return
        }
        self.isFullScreen = true
        let fullScreenFrame = fullScreenFrameForIPhone()
        UIView.animate(withDuration: 0.3, animations: {
            self.reLayoutPlayer(frame: fullScreenFrame)
            self.layer.transform = CATransform3DMakeRotation(-.pi/2.0, 0, 0, 1)
        }) { (flag) in
        }
    }
    
    // shriken screen
    private func portraitLayout() {
        if !isFullScreen {
            return
        }
        self.isFullScreen = false
        UIView.animate(withDuration: 0.35, animations: {
            self.layer.transform = CATransform3DIdentity
            self.reLayoutPlayer(frame: self.initFrame)
        }) { (flag) in
        }
    }

    
    // iPhone fullScreen size
      private func fullScreenFrameForIPhone() -> CGRect {
          let fullScreenWidth  = UIScreen.main.bounds.size.height
          let fullScreenHeight = UIScreen.main.bounds.size.width
          let fullScreenFrame = CGRect.init(x: (fullScreenHeight-fullScreenWidth)/2.0, y: (fullScreenWidth-fullScreenHeight)/2.0, width: fullScreenWidth, height: fullScreenHeight)
          return fullScreenFrame
      }
      
      private func reLayoutPlayer(frame:CGRect) {
          /// Only get frame width and height ，x and y set 0
            let newFrame = CGRect.init(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
            player.frame = newFrame
            coverView.frame = newFrame
            player.transfrom(newFrame)
            coverView.loadViewTransform(newFrame)
            coverView.loadErrorViewTransform(newFrame)
            coverView.netErrorViewTransform(newFrame)
            self.frame = frame
      }
}


extension VVPlayerView {
    
    private(set) var isFullScreen: Bool {
        
        get {
            let full = objc_getAssociatedObject(self, &FullScreenKey) as? Bool
            if let full = full {
                return full
            }
            return false
        }
        
        set {
            objc_setAssociatedObject(self, &FullScreenKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}
