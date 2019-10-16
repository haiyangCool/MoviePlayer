//
//  VVPlayerCoverView+Guster.swift
//  VVPlayer
//
//  Created by 王海洋 on 2018/10/15.
//  Copyright © 2019 王海洋. All rights reserved.
//

import Foundation
import UIKit
/** 手势控制
 */
private var GusterKey: Void?
private var DelayTaskKey: Void?
@objc protocol VVPlayerGusterAction: NSObjectProtocol {
    
    @objc optional func singleTap(_ coverView: VVPlayerCoverView)
    @objc optional func doubleTap(_ coverView: VVPlayerCoverView)
    
    @objc optional func volume(_ coverView: VVPlayerCoverView, volume: Float)
    @objc optional func brightness(_ coverView: VVPlayerCoverView, bright: Float)
    @objc optional func progress(_ coverView: VVPlayerCoverView, progress: Float)
}

extension VVPlayerCoverView {
    
    func addGusterRecognize() {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapAction(_:)))
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        addGestureRecognizer(singleTap)
            
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction(_:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.numberOfTouchesRequired = 1
        addGestureRecognizer(doubleTap)
        singleTap.require(toFail: doubleTap)
        
        autoHiddenPanel()
    }
    
}

/// Action call
extension VVPlayerCoverView {
    
    @objc fileprivate func singleTapAction(_ sender: UITapGestureRecognizer) {
        _singleTap()
        guard let delegate = gusterAction, delegate.responds(to: #selector(delegate.singleTap(_:))) else { return  }
        delegate.singleTap?(self)
    }
    
    @objc fileprivate func doubleTapAction(_ sender: UITapGestureRecognizer) {
        guard let delegate = gusterAction, delegate.responds(to: #selector(delegate.doubleTap(_:))) else { return  }
        delegate.doubleTap?(self)
    }
    
    @objc fileprivate func adjustVolume(_ volume: Float) {
        
        guard let delegate = gusterAction, delegate.responds(to: #selector(delegate.volume(_:volume:))) else { return }
        delegate.volume?(self, volume: volume)
    }
    
    @objc fileprivate func adjustBrightness(_ bright: Float) {
        
        guard let delegate = gusterAction, delegate.responds(to: #selector(delegate.brightness(_:bright:))) else { return }
        delegate.brightness?(self, bright: bright)
    }
    
    @objc fileprivate func adjustProgress(_ progress: Float) {
        guard let delegate = gusterAction, delegate.responds(to: #selector(delegate.progress(_:progress:))) else { return }
        delegate.progress?(self, progress: progress)
    }

}

extension VVPlayerCoverView {
    
    fileprivate func _singleTap() {
        
        cancelDelayTask()
        if bottomPanel.isHidden {
            // show animate
            bottomPanel.isHidden = false
            showPanel()
            autoHiddenPanel()
        }else {
            // hidden animate
            autoHiddenPanel(timeInterval: 0)
        }
    }
    
    fileprivate func autoHiddenPanel(timeInterval: TimeInterval = 6) {
        delayTask = DispatchQueue.main.delay(timeInterval, task: {
        
            UIView.animate(withDuration: 0.4, animations: {
                self.topPanel.transform = CGAffineTransform.init(translationX: 0, y: -VV_CoverTopPanelHeight)
            }) { (f) in
                self.bottomPanel.isHidden = true
            }
           
            UIView.animate(withDuration: 0.4, animations: {
                self.bottomPanel.transform = CGAffineTransform.init(translationX: 0, y: VV_CoverBottomPanelHeight)
                
            }) { (f) in
                self.bottomPanel.isHidden = true
            }
        })
    }
    fileprivate func showPanel() {
          UIView.animate(withDuration: 0.4) {
              self.topPanel.transform = CGAffineTransform.identity
              self.bottomPanel.transform = CGAffineTransform.identity

          }
      }
      
      fileprivate func cancelDelayTask() {
          DispatchQueue.main.cancel(delayTask)
      }
    
}


extension VVPlayerCoverView {
    
    var gusterAction: VVPlayerGusterAction? {
        
        get {
            return objc_getAssociatedObject(self, &GusterKey) as? VVPlayerGusterAction
        }
        
        set {
            objc_setAssociatedObject(self, &GusterKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    fileprivate var delayTask: DispatchQueue.Task? {
        
        get {
            return objc_getAssociatedObject(self, &DelayTaskKey) as? DispatchQueue.Task
        }
        set {
            objc_setAssociatedObject(self, &DelayTaskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}
