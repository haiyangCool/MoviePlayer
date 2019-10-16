//
//  VVPlayerView.swift
//  VVPlayer
//
//  Created by 王海洋 on 2018/10/14.
//  Copyright © 2019 王海洋. All rights reserved.
//

import UIKit

/// 播放器图层、组合播放器（符合VVPlayerProtocol）和 Coverview
class VVPlayerView: UIView {
    
    var autoPlay: Bool = true
    
    private(set) var coverView: VVPlayerCoverView!
    private(set) var player: VVPlayer!
    private(set) var initFrame: CGRect = CGRect.zero
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .orange
        initFrame = frame
        clipsToBounds = true
    
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK - 退出播放器时必须执行该方法
    func removeAllObservers() {
        
        player.removeObservers()
        player.removeNotifications()
        stopScreenOrientationMonitor()
        stopActiveMonitor()
        stopNetMonitor()
    }
}

extension VVPlayerView {
 
    func loadResouce(_ url: URL) {
        player = VVPlayer(frame: bounds)
        player.backgroundColor = .black
        player.autoPlay = autoPlay
        player.load(url)
        addSubview(player)
        
        coverView = VVPlayerCoverView(frame: bounds)
        addSubview(coverView)
        
        /// 播放器扩展
        loadExtension()
        playControlExtension()
        timeLineExtension()
        fullScreenExtension()
        gusterExtension()
        
    }
    
    func play() {
        player.play()
    }
    
    func pause() {
        player.pause()
    }
}




