//
//  VVPlayerView.swift
//  VVPlayer
//
//  Created by 王海洋 on 2017/10/11.
//  Copyright © 2019 王海洋. All rights reserved.
//

import UIKit
import AVFoundation
private var ItemStatuContext: String?
///
class VVPlayer: UIView {
    
    
    /** 加载（nuknown、readyToPlay、faild）
        unKnown: 还未加载完成，此时属于加载中状态，可以通过显示loading提示用户正在加载
        readyToPlay： 加载成功，可以进行播放
        faild：加载失败
     */
    weak var load: VVPlayerLoad?
    
    /** 播控（播放暂停）信息
            willPlay,didPlay
            willPause,didPause
     */
    weak var operation: VVPlayerOperation?
    
    /** TimeLine 时间线 产生的信息
        durarion:时长
        playbackTime: 已播放的时间
        playProgress: 播放进度
        buffuer: 缓存进度
     */
    weak var timeLine: VVPlayerTimeLine?
    
    
    /** 播放器播放状态
        stalled: 卡顿
        didFinish：播完
        faild: 出现错误
     */
    weak var state: VVPlayerState?
    
    /// 加载成功后是否自动播放
    var autoPlay = true
    
    /// 时长 加载成功后可获取资源   
    dynamic private(set) var duration: Double = 0
    
    /// 已播放时间
    dynamic private(set) var playbackTime: Double = 0
    
    /// 缓存
    dynamic private(set) var buffer: Double = 0
    
    dynamic private(set) var playing: Bool = false
    
    dynamic private(set) var currentResource: URL?
    
    /// 是否正在播放
    private var isPlaying: Bool = false
    /// 初始大小
    private var initFrame = CGRect.zero

    
    
    private lazy var asset: AVAsset = {
        let asset = AVAsset(url: self.currentResource!)
        return asset
    }()
    
    private lazy var playerItem: AVPlayerItem = {
        let playerItem = AVPlayerItem(asset: self.asset)
        return playerItem
    }()
    
    private lazy var player: AVPlayer = {
        let player = AVPlayer(playerItem: self.playerItem)
        return player
    }()
    
    private lazy var playerLayer: AVPlayerLayer = {
        let playerLayer = AVPlayerLayer(player: self.player)
        playerLayer.frame = self.initFrame
        return playerLayer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initFrame = CGRect(origin: CGPoint.zero, size: frame.size)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK:- Public Methods
extension VVPlayer: VVPlayerProtocol {

    /// 加载资源
    /// - Parameter resourse:
    func load(_ resourse: URL) {
        self.currentResource = resourse
        let assetKey = "tracks"
        
        var error: NSError?
        
        asset.loadValuesAsynchronously(forKeys: [assetKey]) {
            DispatchQueue.main.async {
                
                let state = self.asset.statusOfValue(forKey: assetKey, error: &error)
                
                switch state {
                case .loaded:
                    self.layer.addSublayer(self.playerLayer)
                    self.addPlayerItemObserver()
                    self.addPlayerItemNotification()
                    self.addTimeObserver()

                    break
                case .failed:
                    print("load faild")
                    if let load = self.load {
                        load.vvPlayer(self, loadState: .faild)
                    }
                    break
                default :
                    break
                }
                
            }
        }
    }
    
    /// 切换播放源
    /// - Parameter resourse:
    func exchange(_ resourse: URL) {
        removeNotifications()
        removeObservers()
        
        let avAsset = AVAsset(url: resourse)
        asset = avAsset

        let avPlayerItem = AVPlayerItem(asset: asset)
        playerItem = avPlayerItem

        let avPlayer = AVPlayer(playerItem: playerItem)
        player = avPlayer
        
        let avPlayerLayer = AVPlayerLayer(player: player)
        playerLayer = avPlayerLayer
        load(resourse)
        initFrame = frame
    }
    
    /// 播放
    func play() {

        if let op = operation, op.responds(to: #selector(op.willPlay(_:))) {
            op.willPlay?(self)
        }
        if !isPlaying {
            isPlaying = true
            player.play()
        }
        
        if let op = operation, op.responds(to: #selector(op.didPlay(_:))) {
            op.didPlay?(self)
        }
        
    }
    
    /// 暂停
    func pause() {
        if let op = operation, op.responds(to: #selector(op.willPause(_:))) {
            op.willPause?(self)
        }
        if isPlaying {
            isPlaying = false
            player.pause()
        }
        if let op = operation, op.responds(to: #selector(op.didPause(_:))) {
            op.didPause?(self)
        }
        
    }
    
    func stop() {
          
    }
      
    /// 设置播放时间
    /// - Parameter time:
    func seekToTime(_ time: CMTime) {
        player.seek(to: time) { (f) in
            self.play()
        }
    }
    
    /// 设置播放进度
    /// - Parameter progress: 进度
    func seekToProgress(_ progress: Float) {
        let pullTime = Float64(progress) * duration
        let timeScale = Int32(duration)
        let time = CMTimeMakeWithSeconds(pullTime, preferredTimescale: timeScale)
        seekToTime(time)
    }
    
    func removeObservers() {
          
         player.currentItem?.removeObserver(self, forKeyPath: "status")
         player.currentItem?.removeObserver(self, forKeyPath: "duration")
         player.currentItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")

    }
    
    func removeNotifications() {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func transfrom(_ frame: CGRect) {
        playerLayer.frame = frame
    }
}

// MARK:- KVO and Notification \ period of time
extension VVPlayer {
    
    /// KVO for load status 、duration、etc *******************************
    fileprivate func addPlayerItemObserver() {

        playerItem.addObserver(self, forKeyPath: "status", options: [.old, .new], context: &ItemStatuContext)
        playerItem.addObserver(self, forKeyPath: "duration", options: [.old, .new], context: &ItemStatuContext)
        playerItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: [.old, .new], context: &ItemStatuContext)
        
    }
    
    /// KVO
    /// - Parameter keyPath: ke yPath
    /// - Parameter object: object
    /// - Parameter change: change
    /// - Parameter context: context
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard context == &ItemStatuContext else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change, context: context)
            return
        }
        
        if keyPath == #keyPath(AVPlayerItem.status) {
            var status:AVPlayerItem.Status = .unknown
            if let newStatusNumber:NSNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: newStatusNumber.intValue)!
            }
            switch status {
            case .unknown:
                /// loading ,at this moment , we don`t  know item info
                print("unknown")
                if let load = load {
                    load.vvPlayer(self, loadState: .unknown)
                }
                break
            case .readyToPlay:
                /// ready to play, resource load success
                print("readyToPlay")
                if let load = load {
                    load.vvPlayer(self, loadState: .readyToPlay)
                }
                if autoPlay {
                    play()
                }
                break
            case .failed:
                /// resource load faild , do something
                print("failed")
                if let load = load {
                    load.vvPlayer(self, loadState: .faild)
                }

                break
            default:
                break
            }
            
        }
        
        if keyPath == #keyPath(AVPlayerItem.duration) {
            
            guard let durationTime = player.currentItem?.duration else { return }
            duration = CMTimeGetSeconds(durationTime)
            if let timeLine = timeLine, timeLine.responds(to: #selector(timeLine.vvPlayer(_:duration:))) {
                timeLine.vvPlayer?(self, duration: duration)
            }
        }
        
        if keyPath == #keyPath(AVPlayerItem.loadedTimeRanges) {
            
            guard let loadtimeRange = player.currentItem?.loadedTimeRanges,
                let loadTime = loadtimeRange.first else { return  }
            
            let bufferRange = loadTime.timeRangeValue
            buffer = CMTimeGetSeconds(bufferRange.start) + CMTimeGetSeconds(bufferRange.duration)
            if duration > 0 {
                
                guard let timeline = timeLine, timeline.responds(to: #selector(timeline.vvPlayer(_:bufferProgress:))) else { return  }
                
                timeline.vvPlayer?(self, bufferProgress: buffer/duration)
            }
            
        }
        
    }
    
    /// Notification ***************************************************
    fileprivate func addPlayerItemNotification() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(playStalled), name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: player.currentItem)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playFinished), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playHadFaild), name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: player.currentItem)
    }
    
    /// 加载停滞卡顿
    @objc fileprivate func playStalled() {
      
        print("加载卡顿")
        guard let state = state, state.responds(to: #selector(state.playStalled(_:))) else { return }
        state.playStalled?(self)
        
    }
    
    /// 播放完成
    @objc fileprivate func playFinished() {
        
        guard let state = state, state.responds(to: #selector(state.playDidFinish(_:))) else { return }
        state.playDidFinish?(self)
        
    }

    ///  播放出错了
    @objc fileprivate func playHadFaild() {
        
        guard let state = state, state.responds(to: #selector(state.playDidFaild(_:))) else { return }
        state.playDidFaild?(self)
        
    }
    
    /// 实时（每隔一秒）获取当前播放时间
    fileprivate func addTimeObserver() {
        
        player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: Int64(1.0), timescale: Int32(1.0)), queue: DispatchQueue.main) { [unowned self] (cmtime) in
            
            self.playbackTime = CMTimeGetSeconds(cmtime)
            
            guard let timeline = self.timeLine, timeline.responds(to: #selector(timeline.vvPlayer(_:playbackTime:))) else { return }
            timeline.vvPlayer?(self, playbackTime: self.playbackTime)
            if self.duration > 0 {
                
                timeline.vvplayer?(self, playProgress: self.playbackTime/self.duration)
            }
            
        }
    }
}
