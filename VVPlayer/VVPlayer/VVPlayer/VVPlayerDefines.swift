//
//  VVPlayerDefines.swift
//  VVPlayer
//
//  Created by 王海洋 on 2017/10/12.
//  Copyright © 2019 王海洋. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

//MARK: 播放加载状态
enum VVPLayerLoadState: String {
    /** 加载中，状态还未可知*/
    case unknown
    /** 加载成功，可以播放*/
    case readyToPlay
    /** 加载失败*/
    case faild
}

// MARK: 播放器全屏方向
@objc enum VVPlayerDirection: Int {
    
    case landscapeRight
    case landscapeLeft
    case portraitUpsideDown
    case portrait
}

/** 播放器必须实现的协议
    通过协议提供统一调用的方法
 */
@objc protocol VVPlayerProtocol {
    
    func load(_ resourse: URL)
    func play()
    func pause()
    func stop()
    func seekToTime(_ time: CMTime)
    
    // 屏幕相关
    @objc optional func landscapeLeft()
    @objc optional func landscaoeRight()
    @objc optional func portrait()
}


// MARK: 播放器加载状态
protocol VVPlayerLoad: NSObjectProtocol{
    
    func vvPlayer(_ player: VVPlayerProtocol, loadState state: VVPLayerLoadState)
    
}

// MARK: 播放器控制
@objc protocol VVPlayerOperation: NSObjectProtocol {
    
    /// Play
    @objc optional func willPlay(_ player: VVPlayerProtocol)
    @objc optional func didPlay(_ player: VVPlayerProtocol)
    
    /// Pause
    @objc optional func willPause(_ player: VVPlayerProtocol)
    @objc optional func didPause(_ player: VVPlayerProtocol)
        
}

// MARK: 播放器播放中状态
@objc protocol VVPlayerState: NSObjectProtocol {
    
    /// 加载卡顿
    /// - Parameter player:
    @objc optional func playStalled(_ player: VVPlayerProtocol)
    
    /// 播放完成
    /// - Parameter player:
    @objc optional func playDidFinish(_ player: VVPlayerProtocol)
    
    /// 播放失败
    /// - Parameter player:
    @objc optional func playDidFaild(_ player: VVPlayerProtocol)
    
}

// MARK: 时间线
@objc protocol VVPlayerTimeLine: NSObjectProtocol {
    
    /// 时长
    /// - Parameter Player:
    /// - Parameter duration:
    @objc optional func vvPlayer(_ player: VVPlayerProtocol, duration: Double)
    
    /// 当前已播放的时间
    /// - Parameter player:
    /// - Parameter time:
    @objc optional func vvPlayer(_ player: VVPlayerProtocol, playbackTime time: Double)
    
    
    /// 播放进度
    /// - Parameter player:
    /// - Parameter progress:
    @objc optional func vvplayer(_ player: VVPlayerProtocol, playProgress progress: Double)
    
    
    /// 缓存进度
    /// - Parameter player:
    /// - Parameter progress:
    @objc optional func vvPlayer(_ player: VVPlayerProtocol, bufferProgress progress: Double)
    
    
}


// MARK: 网络状态
protocol VVPlayerNet {
    
    func vvPlayer(_ player: VVPlayerView, playerNetEnvironment environment: NetEnvironment)
}

// MARK: 播放器活跃(进入前台、后台)
@objc protocol VVPlayerActive: NSObjectProtocol {
    
    /// 播放器进入前台活跃状态
    /// - Parameter player:
    @objc optional func playerBecomeActive(_ player: VVPlayerView)
       
    /// 播放器被系统中断（Phone Call）或进入后台
    /// - Parameter player:
    @objc optional func playerResignActive(_ player: VVPlayerView)
}


// MARK: 播放器（屏幕旋转）
@objc protocol VVPlayerScreen: NSObjectProtocol {
    
    /// 屏幕向上
    /// - Parameter player:
    @objc optional func faceUp(_ player: VVPlayerView)
    
    /// 屏幕向下
    /// - Parameter player:
    @objc optional func faceDown(_ player: VVPlayerView)
    
    /// 进入全屏
    /// - Parameter player:
    @objc optional func enterFullScreen(_ player: VVPlayerView, fullScreen direction: VVPlayerDirection)
    
    /// 退出全屏
    /// - Parameter player: 
    @objc optional func exitFullScreen(_ player: VVPlayerView, screen direction: VVPlayerDirection)

}
