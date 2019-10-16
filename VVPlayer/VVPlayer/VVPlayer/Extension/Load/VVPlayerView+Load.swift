//
//  VVPlayerView+Load.swift
//  VVPlayer
//
//  Created by 王海洋 on 2018/10/16.
//  Copyright © 2019 王海洋. All rights reserved.
//

import Foundation

extension VVPlayerView {
    
    func loadExtension() {
        //播放器
        player.load = self
        coverView.loadAction = self
        netDelegate = self
        coverView.showLoading()
        startNetMonitor()
        
    }
}

extension VVPlayerView: VVPlayerLoad {
    
    func vvPlayer(_ player: VVPlayerProtocol, loadState state: VVPLayerLoadState) {
        print("加载状态 = \(state)  \(hasNet)")
        if state == .readyToPlay {
            if autoPlay {
                player.play()
            }
            coverView.hiddenLoading()
        }
        
        if state == .faild {
            if !hasNet {
                // 网络错误
                coverView.showNetException(.loseNet)
            }else {
                // 加载错误
                coverView.showLoadError()
            }
            
        }
    }
}

extension VVPlayerView: VVNetMonitor {
    
    func netChanged(_ state: NetEnvironment) {
        print("网络= \(state)")
        if state == .celluar {
            coverView.showNetException(.celluar)
            player.pause()
        }
    }
    
}

// MARK: 加载错误 UI Action
extension VVPlayerView: VVPlayerLoadAction {
    
   
    func reload(_ coverView: VVPlayerCoverView) {
        
        if let resouce = player.currentResource {
            player.exchange(resouce)
            coverView.showLoading()
        }
    }
    
    func celluarPlay(_ coverView: VVPlayerCoverView) {
        
        player.play()
    }
    
    func celluarStop(_ coverView: VVPlayerCoverView) {
        
    }
    
}


