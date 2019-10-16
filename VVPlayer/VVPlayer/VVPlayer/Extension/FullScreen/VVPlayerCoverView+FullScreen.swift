//
//  VVPlayerCoverView+FullScreen.swift
//  VVPlayer
//
//  Created by 王海洋 on 2018/10/15.
//  Copyright © 2019 王海洋. All rights reserved.
//

import Foundation
import UIKit

private var FullScreenKey: Void?
private var ShrikenScreenKey: Void?
private var FullScreenActionKey: Void?
private var FullScreenObservationKey: Void?

// Layout params
private let FullScreenBtnWidth: CGFloat = 44
private let FullScreenBtnPadding: CGFloat = 10

// 全屏 Action protocol
@objc protocol VVPlayerFullScreenAction: NSObjectProtocol {
    
    func enterFullScreen(_ coverView: VVPlayerCoverView)
    func exitFullScreen(_ coverView: VVPlayerCoverView)

}

/// Public Method
extension VVPlayerCoverView {
    
    func addFullScreenView() {
        
        fullScreenBtn = UIButton()
        fullScreenBtn.setTitle("Full", for: .normal)
        fullScreenBtn.addTarget(self, action: #selector(enterFullScreen(_:)), for: .touchUpInside)
        bottomPanel.addSubview(fullScreenBtn)
        
        shrikenScreenBtn = UIButton()
        shrikenScreenBtn.setTitle("Shrik", for: .normal)
        shrikenScreenBtn.addTarget(self, action: #selector(exitFullScreen(_:)), for: .touchUpInside)
        shrikenScreenBtn.isHidden = true
        bottomPanel.addSubview(shrikenScreenBtn)
        
        layoutFullScreen()
    }
    
    func showFullScennButton() {
        
        fullScreenBtn.isHidden = false
        shrikenScreenBtn.isHidden = true
        
    }
    
    func showShrikenScreenButton() {
        
        fullScreenBtn.isHidden = true
        shrikenScreenBtn.isHidden = false
    }
}

///  Action
extension VVPlayerCoverView {
    
    @objc fileprivate func enterFullScreen(_ sender: UIButton) {
        
        guard let delegate = fullScreenAction, delegate.responds(to: #selector(delegate.enterFullScreen(_:))) else { return }
        delegate.enterFullScreen(self)
        showShrikenScreenButton()
    }
    
    @objc fileprivate func exitFullScreen(_ sender: UIButton) {
           
        guard let delegate = fullScreenAction, delegate.responds(to: #selector(delegate.exitFullScreen(_:))) else { return }
        delegate.exitFullScreen(self)
        showFullScennButton()
    }
    
}

/// Layout
extension VVPlayerCoverView {
    
    fileprivate func layoutFullScreen() {
        
        fullScreenBtn.snp.makeConstraints { (make) in
            make.right.equalTo(self.snp.right).offset(-FullScreenBtnPadding)
            make.bottom.equalTo(self.snp.bottom).offset(-FullScreenBtnPadding)
            make.width.height.equalTo(FullScreenBtnWidth)
        }
        
        shrikenScreenBtn.snp.makeConstraints { (make) in
            make.right.equalTo(self.snp.right).offset(-FullScreenBtnPadding)
            make.bottom.equalTo(self.snp.bottom).offset(-FullScreenBtnPadding)
            make.width.height.equalTo(FullScreenBtnWidth)
        }
    }
}

/// Dynamic Property
extension VVPlayerCoverView {
    
    fileprivate var fullScreenBtn: UIButton {
        
        get {
            
            let btn = objc_getAssociatedObject(self, &FullScreenKey) as? UIButton
            if let btn = btn {
                return btn
            }
            return UIButton()
        }
        
        set {
            
            objc_setAssociatedObject(self, &FullScreenKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate var shrikenScreenBtn: UIButton {
        
        get {
            
            let btn = objc_getAssociatedObject(self, &ShrikenScreenKey) as? UIButton
            if let btn = btn {
                return btn
            }
            return UIButton()
        }
        
        set {
            
            objc_setAssociatedObject(self, &ShrikenScreenKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
    var fullScreenAction: VVPlayerFullScreenAction? {
        
        get {
            return objc_getAssociatedObject(self, &FullScreenActionKey) as? VVPlayerFullScreenAction
        }
        
        set {
            objc_setAssociatedObject(self, &FullScreenActionKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    
    fileprivate var fullScreenObservation: NSKeyValueObservation? {
        get {
            return objc_getAssociatedObject(self, &FullScreenObservationKey) as? NSKeyValueObservation
        }
        set {
            objc_setAssociatedObject(self, &FullScreenObservationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}
