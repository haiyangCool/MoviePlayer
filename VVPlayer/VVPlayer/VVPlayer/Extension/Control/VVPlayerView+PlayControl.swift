//
//  VVPlayerView+PlayControl.swift
//  VVPlayer
//
//  Created by 王海洋 on 2018/10/16.
//  Copyright © 2019 王海洋. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

// MARK: 播控 （播放暂停）
private var PlayingKey: Void?

extension VVPlayerView {
    
    func playControlExtension() {
        player.operation = self
        player.state = self
        active = self
        coverView.controlAction = self
        startActiveMonitor()
        
    }
}

// MARK: 播放、暂停
extension VVPlayerView: VVPlayerOperation {
    
    func willPlay(_ player: VVPlayerProtocol) {
        isPlaying = true
        coverView.showPauseBtn()
    }
    
    func willPause(_ player: VVPlayerProtocol) {
        isPlaying = false
        coverView.showPlayBtn()
    }
}

// MARK: 播放状态
extension VVPlayerView: VVPlayerState {
    
    // 播放卡顿
    func playStalled(_ player: VVPlayerProtocol) {
        coverView.showLoading()
    }
    
    // 播放完成
    func playDidFinish(_ player: VVPlayerProtocol) {
        player.seekToTime(CMTime.zero)
        coverView.setProgress(0)
        coverView.setDurationTime("00:00")
        player.pause()
    }
    
    func playDidFaild(_ player: VVPlayerProtocol) {
        coverView.showLoadError()
    }
}

// MARK: 播放器活跃状态： 是否在前台播放
extension VVPlayerView: VVPlayerActive {
    
    // 播放器进入前台
    func playerBecomeActive(_ player: VVPlayerView) {
        
        player.play()
    }
    
    // 播放器进入后台
    func playerResignActive(_ player: VVPlayerView) {
        
        player.pause()
    }
}

/// MARK: UI  操作事件
extension VVPlayerView: VVPlayerPlayControlAction {
    
    func play(_ coverView: VVPlayerCoverView) {
        player.play()
    }
    
    func pause(_ coverView: VVPlayerCoverView) {
        player.pause()
    }
}

// MARK: 新增属性
extension VVPlayerView {
    
    private(set) var isPlaying: Bool {
        
        get {
            let f = objc_getAssociatedObject(self, &PlayingKey) as? Bool
            if let f = f {
                return f
            }
            return false
        }
        
        set {
            
            objc_setAssociatedObject(self, &PlayingKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}
