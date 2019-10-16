//
//  VVPlayerCoverView+PlayControl.swift
//  VVPlayer
//
//  Created by 王海洋 on 2018/10/14.
//  Copyright © 2019 王海洋. All rights reserved.
//

import Foundation
import UIKit
/** 播放、暂停控制UI*/

private var PlayKey: Void?
private var PauseKey: Void?
private var PlayControlKey: Void?

// Layout params
private let PlayBtnWidth: CGFloat = 44
private let PlayBtnPadding: CGFloat = 10

@objc protocol VVPlayerPlayControlAction: NSObjectProtocol {
    
    @objc optional func play(_ coverView: VVPlayerCoverView)
    
    @objc optional func pause(_ coverView: VVPlayerCoverView)
    
}

extension VVPlayerCoverView {

    func addControlView() {
        
        playBtn = UIButton()
        playBtn.setTitle("Play", for: .normal)
        playBtn.addTarget(self, action: #selector(playAction(_:)), for: .touchUpInside)
        pauseBtn = UIButton()
        pauseBtn.setTitle("Paus", for: .normal)
        pauseBtn.isHidden = true
        pauseBtn.addTarget(self, action: #selector(pauseAction(_:)), for: .touchUpInside)

        bottomPanel.addSubview(playBtn)
        bottomPanel.addSubview(pauseBtn)
        
        layoutControlView()
    }
    
    func showPlayBtn() {
        
        playBtn.isHidden = false
        pauseBtn.isHidden = true
    }
    
    func showPauseBtn() {
        
        playBtn.isHidden = true
        pauseBtn.isHidden = false
        
    }
    
}

extension VVPlayerCoverView {


    @objc fileprivate func playAction(_ sender: UIButton) {
        
        guard let delegate = controlAction, delegate.responds(to: #selector(delegate.play(_:))) else { return }
        delegate.play?(self)
       
    }
    
    @objc fileprivate func pauseAction(_ sender: UIButton) {
        
        guard let delegate = controlAction, delegate.responds(to: #selector(delegate.pause(_:))) else { return }
        delegate.pause?(self)
    }
    
    fileprivate func layoutControlView() {
        
        playBtn.snp.makeConstraints { (maker) in
            maker.left.equalTo(self.snp.left).offset(PlayBtnPadding)
            maker.bottom.equalTo(self.snp.bottom).offset(-PlayBtnPadding)
            maker.width.height.equalTo(PlayBtnWidth)
        }
        
        pauseBtn.snp.makeConstraints { (maker) in
                   maker.left.equalTo(self.snp.left).offset(PlayBtnPadding)
                   maker.bottom.equalTo(self.snp.bottom).offset(-PlayBtnPadding)
                   maker.width.height.equalTo(PlayBtnWidth)
        }
        
    }
}


extension VVPlayerCoverView {
    
    private var playBtn: UIButton {
        
        get {
            let pBtn = objc_getAssociatedObject(self, &PlayKey) as? UIButton
            
            if let pBtn = pBtn {
                return pBtn
            }
            
            return  UIButton()
        }
        
        set {
            objc_setAssociatedObject(self, &PlayKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
    private var pauseBtn: UIButton {
        
        get {
            let pBtn = objc_getAssociatedObject(self, &PauseKey) as? UIButton
            
            if let pBtn = pBtn {
                return pBtn
            }
            
            return  UIButton()
        }
        
        set {
            objc_setAssociatedObject(self, &PauseKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var controlAction: VVPlayerPlayControlAction? {
           
           get {
               return objc_getAssociatedObject(self, &PlayControlKey) as? VVPlayerPlayControlAction
           }
           set {
               
               objc_setAssociatedObject(self, &PlayControlKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
           }
       }
}
