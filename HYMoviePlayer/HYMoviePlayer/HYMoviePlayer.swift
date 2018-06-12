//
//  HYMoviePlayer.swift
//  HYMoviePlayer
//
//  Created by 王海洋 on 2018/5/7.
//  Copyright © 2018年 王海洋. All rights reserved.
//
/**
    AVPlayer
    播放、暂停
    全屏、
 */

protocol HYMoviePlayerDelegate {
    
    /// 加载视频完成，可以播放
    func HYMoviePlayerPrepareToPlay(player:HYMoviePlayer)
}

import UIKit
import AVFoundation
class HYMoviePlayer: UIView {

    var delefate:HYMoviePlayerDelegate?
    /// 网络监测者
    fileprivate var netCheck:HYMoviePlayerNetLinkCheck?
    /// 播放器活跃状态监听
    fileprivate var playerActivityMonitor:HYMoviePlayerActivityMonitor?
    /// 视频预览层
    fileprivate var playerLayer:AVPlayerLayer?
    /// 播放器
    fileprivate var player:AVPlayer?
    /// 播控图层
    fileprivate var playerControlPanel:HYMoviePlayControlPanel?
    /// 播放器初始大小
    fileprivate var playerInitFrame:CGRect = CGRect.zero
    /// 视频时长
    fileprivate var videoDurationSeconds:Float64? = 0
    /// 是否处于全屏状态
    fileprivate var isFullScreenState:Bool = false
    /// 是否锁屏中
    fileprivate var isLoackScreenState:Bool = false
    /// 是否设置了视频播放跳转位置
    fileprivate var isSetVideoPlayTime:Bool = false
    /// 是否正在拖动快进条
    fileprivate var isSeeking:Bool = false
    /// 是否手动暂停 - 手动暂停时，缓存充足也不会自动播放
    fileprivate var isPausePlayByHand:Bool = false
    /// 当前视频的播放地址
    fileprivate var currentPlayingVideoAddrress:String?
    /// 是否已经移除了所有的通知和监听
    fileprivate var isRemoveAllNotification:Bool = false
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.playerInitFrame = frame
        self.backgroundColor = UIColor.black
        netCheck = HYMoviePlayerNetLinkCheck.init()
        netCheck?.netLinkProtocol = self
        playerActivityMonitor = HYMoviePlayerActivityMonitor.init()
        playerActivityMonitor?.playerActivityProtocol = self
    }
    deinit {
        
        self.removeNotificationAndObserver()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
/** Public methods
    Set Video title
    Load Video PlayAddress
 */
extension HYMoviePlayer {

    /// 视频名称
    func setVideoTitle(title:String?) {
        self.playerControlPanel?.setVideoTitle(title: "测试视频")
    }
    /// 播放地址
    func loadVideoByAddress(videoAddress:String) {
        self.currentPlayingVideoAddrress = videoAddress
        self.player = self.avplyer(playAddress: videoAddress)
        self.addPlayerPlayTimeObserver()
        /// 预览层
        playerLayer = self.avPlayerLayer()
        playerLayer?.frame = self.bounds
        playerLayer?.backgroundColor = UIColor.black.cgColor
        playerLayer?.player = self.player
        self.layer.addSublayer(playerLayer!)
        
        playerControlPanel = HYMoviePlayControlPanel.init(frame: self.playerInitFrame)
        playerControlPanel?.delegate = self
        self.addSubview(playerControlPanel!)
        
        /// 监听屏幕旋转
        self.startScreenRotateMonitor()
        /// 网络监听
        self.startNetLinkAndPlayerActivityMonitor()
    }
    
    /// 更改播放地址
    func loadOthersVideoByAddress(videoAddress:String) {
        self.isPausePlayByHand = false
        self.currentPlayingVideoAddrress = videoAddress
        self.removeAllObserver()
        self.removeAllNotification()
        let newPlayerItem = self.playerItem(playAddress: videoAddress)
        self.listenPlayerLoading(playItem: newPlayerItem)
        self.startPlayerPlayStateMonitor()
        self.player?.replaceCurrentItem(with: newPlayerItem)
    
    }
    
    /// 设置播放进度
    func seekTimeToPlay(value:Float) {
        self.isSetVideoPlayTime = true     /// 暂未用到，只在该处设置了值
        if self.player == nil { return }
        self.player?.pause()
        self.isSeeking = true
        let time = self.seekTimeByValue(value: value)
        self.player?.seek(to: time, completionHandler: { (flag) in
            self.isSeeking = false
            self.player?.play()
        })
    }
    
    /// 移除通知和观察者 在退出播放器时执行该方法
    func removeNotificationAndObserver() {
        if self.isRemoveAllNotification { return }
        self.isRemoveAllNotification = true
        self.removeAllNotification()
        self.removeAllObserver()
        self.netCheck?.stopMonitor()
        self.playerActivityMonitor?.stopMonitor()
    }
}
/****************************Delegate methods************************/
/// 播控Delegate methods
extension HYMoviePlayer:HYMoviePlayControlPanelDelegate {
    
    func hyMoviePlayControlPanelButtonAction(controPanel: HYMoviePlayControlPanel, controlType: HYPlayerControlType) {
        print("播控type = \(controlType)")
        let type = controlType
        switch type {
        case .backType:
            break
        case .playType:
            self.isPausePlayByHand = false
            self.playerControlPanel?.setPlayState(isPlay: true)
            self.player?.play()
            break
        case .pauseType:
            self.isPausePlayByHand = true
            self.playerControlPanel?.setPlayState(isPlay: false)
            self.player?.pause()
            break
        case .fullScreenType:
            self.landscapeLeft()
            break
        case .shrikenScreenType:
            self.portraitOrUpsideDown()
            break
        case .lockScreenType:
            self.playerControlPanel?.setLockScreenState(isLockScreen: true)
            self.isLoackScreenState = true
            break
        case .unLockScreenType:
            self.playerControlPanel?.setLockScreenState(isLockScreen: false)
            self.isLoackScreenState = false
            break
        case .reloadType:
            /// 重新加载
            self.loadOthersVideoByAddress(videoAddress: self.currentPlayingVideoAddrress!)
            break
        default:
            break
        }
    }
    /// 播放进度
    func hyMoviePlayControlPanelGusterAction(controPanel: HYMoviePlayControlPanel, controlType: HYPlayerControlType, value: Float) {
        let type = controlType
        switch type {
        case .playPercentAdjust:
            self.setPlayProgressValue(value: value)
            break
        case .lightAdjust:
            self.setLightValue(value: value)
            break
        case .volumAdjust:
            self.setVolumChangedValue(value: value)
            break
        default:
            break
        }
    }
}
/// 网络变化的Protocol
/// Mark HYMoviePlayerNetLinkListenProtocol
extension HYMoviePlayer:HYMoviePlayerNetLinkListenProtocol {
    
    /// 链接了Wifi网络
    func hyMoviePlayerNetLinkWifi() {
        print("连接了WiFi网络")
        if self.isPausePlayByHand { return }
        self.player?.play() /// 尝试播放
    }
    /// 移动数据流量
    func hyMoviePlayerNetLinkCellular() {
        print("正在使用数据流量")
        self.player?.pause()
        /// 提示正在使用流量观看
        self.playerControlPanel?.setCellurePlayViewState()
    }
    /// 断开了网络连接
    func hyMoviePlayerLoseNetLink() {
        print("断开了网络连接")
    }
}

extension HYMoviePlayer:HYMoviePlayerEnterBackOrForegroundProtocol {
    /// 进入后台
    func hyMoviePlayerEnterBackground() {
        print("进入后台")
        self.player?.pause()
        self.playerControlPanel?.setPlayState(isPlay: false)
    }
    /// 进入前台
    func hyMoviePlayerEnterforeground() {
        print("进入前台")
        if self.isPausePlayByHand { return }
        self.player?.play()
    }
}
/****************************Delegate End************************/

/** Private methods
    移除所有通知
    AVPlayer 播放监听
    屏幕旋转监听
    网络连接状态监测 - 由NetListenProtocol实现者完成
 
 */
extension HYMoviePlayer {

    /// 移除所有通知
    fileprivate func removeAllNotification() {
        
        NotificationCenter.default.removeObserver(self)
    }
    /*************************** 加载监听 Start***************************/
    fileprivate func listenPlayerLoading(playItem:AVPlayerItem?) {
        
        playItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        playItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        playItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        playItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
       
    }
    
    /// PlayerItem 观察者
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let playItem = object as? AVPlayerItem  else { return }
        guard let keyPath = keyPath else { return }
        
        if keyPath == "status" {
            if playItem.status == .readyToPlay {
                if self.isPausePlayByHand { return }
                self.player?.play()
                self.playerControlPanel?.setPlayState(isPlay: true)
                self.playerControlPanel?.hiddenPlayStatePromptView()
                self.startPlayerPlayStateMonitor()
                /// 准备播放 的时候可以通过该接口告知Protocol的实现者做一些操作
                self.delefate?.HYMoviePlayerPrepareToPlay(player: self)
            }
            if playItem.status == .unknown {
                print("加载失败 unkown")
                self.playerControlPanel?.setLoadFaildState()
            }
            if playItem.status == .failed {
                print("加载失败 faild")
                self.playerControlPanel?.setLoadFaildState()
            }
        }
        /// 缓存
        if keyPath == "loadedTimeRanges" {
            
            guard let loadTimeRanges = self.player?.currentItem?.loadedTimeRanges, let first = loadTimeRanges.first else {fatalError("loadTimeRange some error")}
            
            let timeRange = first.timeRangeValue
            let startBufferSeconds = CMTimeGetSeconds(timeRange.start)
            let durationBuffer = CMTimeGetSeconds(timeRange.duration)
            let allBufferSeconds = startBufferSeconds + durationBuffer
            self.videoDurationSeconds  = CMTimeGetSeconds(playItem.duration)
            let buffer = Float(allBufferSeconds)/Float(self.videoDurationSeconds!)
            /// 设置缓存进度
            if playItem.isPlaybackBufferFull {
                self.playerControlPanel?.setVideoBuffer(bufferValue: 1.0)
            }else {
                self.playerControlPanel?.setVideoBuffer(bufferValue: buffer)
            }
        }
        if keyPath == "playbackLikelyToKeepUp" {
            /// 缓存充足可以继续播放
            /// 该监听的方法并不准确，缓存播完后有时会有充足的缓存，什么鬼？
            print("可以继续播放")
            if !playItem.isPlaybackLikelyToKeepUp { return }
            /// 隐藏提示
            self.playerControlPanel?.hiddenPlayStatePromptView()
            if self.isPausePlayByHand { return }
            self.player?.play()
            self.playerControlPanel?.setPlayState(isPlay: true)
        }
        if keyPath == "playbackBufferEmpty" {
            /// 缓存空
            print("缓存播完")
            self.player?.pause()
            self.playerControlPanel?.setPlayState(isPlay: false)
            /// 加载或断网提示
            if (self.netCheck?.isConnectNet())! {
                self.playerControlPanel?.setLoadingState()
            }else {
                self.playerControlPanel?.setLoseNetLinkState()
            }
        }
       
    }
    /// 移除加载观察
    fileprivate func removeAllObserver(){
        NotificationCenter.default.removeObserver(self)
        self.player?.currentItem?.removeObserver(self, forKeyPath: "status")
        self.player?.currentItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        self.player?.currentItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        self.player?.currentItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
    }
    /*************************** 加载监听 End***************************/

    /**************************播放监听 Start***************************/
    fileprivate func startPlayerPlayStateMonitor() {
        NotificationCenter.default.addObserver(self, selector: #selector(moviePlayToEndTime), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(moviePlaybackStalled), name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: self.player?.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(moviePlayTimeJumped), name: NSNotification.Name.AVPlayerItemTimeJumped, object: self.player?.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(movieNewErrorLogEntry), name: NSNotification.Name.AVPlayerItemNewErrorLogEntry, object: self.player?.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(movieNewAccessLogEntry), name: NSNotification.Name.AVPlayerItemNewAccessLogEntry, object: self.player?.currentItem)
    }
    
   /// 播放状态
    @objc fileprivate func moviePlayToEndTime(){
        print("播放结束 - item has played to its end time")
        /// 重置播放器状态
        self.player?.seek(to: kCMTimeZero, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        self.player?.pause()
        self.playerControlPanel?.setPlayState(isPlay: false)
    }
    @objc fileprivate func moviePlaybackStalled(){
        print("播放卡顿 - media did not arrive in time to continue playback")
        /// 加载提示
        self.playerControlPanel?.setLoadingState()
    }
    @objc fileprivate func moviePlayTimeJumped(){
        print("播放时间跳跃 - movie time jumped ")
        self.playerControlPanel?.hiddenPlayStatePromptView()
    }
    @objc fileprivate func movieNewAccessLogEntry(){
        print("新的日志 - a new access log entry has been added")
    }
    @objc fileprivate func movieNewErrorLogEntry(){
        print("新的错误日志- a new error log entry has been added")
    }
    /**************************播放监听 End****************************/
    
    /**************************屏幕监听 Start**************************/
    fileprivate func startScreenRotateMonitor() {
        NotificationCenter.default.addObserver(self, selector: #selector(screenRotate(notification:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    @objc fileprivate func screenRotate(notification:Notification) {
        
        let deviceScreenOrientation = UIDevice.current.orientation
       
        switch deviceScreenOrientation {
        case .unknown:
            break
        case .portrait:
            print("竖屏正")
            self.portraitOrUpsideDown()
            break
        case .portraitUpsideDown:
            print("竖屏倒置")
            self.portraitOrUpsideDown()
            break
        case .landscapeLeft:
            print("左旋转")
            self.landscapeLeft()
            break
        case .landscapeRight:
            print("右旋转")
            self.landscapeRight()
            break
        case .faceUp:
            print("屏幕正置")
            /// 回复音量
            self.player?.isMuted = false
            break
        case .faceDown:
            print("屏幕反置")
            /// 静音
            self.player?.isMuted = true
            break
        }
    }
    /**************************屏幕监听 End****************************/
    fileprivate func portraitOrUpsideDown() {
        if isLoackScreenState || !isFullScreenState { return }
        self.playerControlPanel?.setFullScreenState(isFullScreen: false)
        UIView.animate(withDuration: 0.3, animations: {
            self.layer.transform = CATransform3DIdentity
            self.reLayoutPlayerFrame(frame: self.playerInitFrame)
        }) { (flag) in
            self.isFullScreenState = false
        }
    }
    fileprivate func landscapeLeft() {
        if isLoackScreenState || isFullScreenState { return }
        self.playerControlPanel?.setFullScreenState(isFullScreen: true)
        let fullScreenFrame = self.fullScreenFrame()
        UIView.animate(withDuration: 0.3, animations: {
            self.reLayoutPlayerFrame(frame: fullScreenFrame)
            self.layer.transform = CATransform3DMakeRotation(CGFloat(Double.pi/2.0), 0, 0, 1)
        }) { (flag) in
            self.isFullScreenState = true
        }
        
    }
    fileprivate func landscapeRight() {
        if isLoackScreenState || isFullScreenState { return }
        self.playerControlPanel?.setFullScreenState(isFullScreen: true)
        let fullScreenFrame = self.fullScreenFrame()
        UIView.animate(withDuration: 0.3, animations: {
            self.reLayoutPlayerFrame(frame: fullScreenFrame)
            self.layer.transform = CATransform3DMakeRotation(-CGFloat(Double.pi/2.0), 0, 0, 1)
        }) { (flag) in
            self.isFullScreenState = true
        }
    }

    /// 重置播放器大小
    fileprivate func reLayoutPlayerFrame(frame:CGRect) {
        /// Only get frame width and height ，x and y set 0
        let newFrame = CGRect.init(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        self.playerLayer?.frame = newFrame
        self.playerControlPanel?.frame = newFrame
        self.frame = frame
    }
    /// 全屏大小
    fileprivate func fullScreenFrame() -> CGRect {
        let fullScreenWidth  = UIScreen.main.bounds.size.height
        let fullScreenHeight = UIScreen.main.bounds.size.width
        let fullScreenFrame = CGRect.init(x: (fullScreenHeight-fullScreenWidth)/2.0, y: (fullScreenWidth-fullScreenHeight)/2.0, width: fullScreenWidth, height: fullScreenHeight)
        return fullScreenFrame
    }
    /********************网络连接播放器活跃状态监听 Start******************/

    fileprivate func startNetLinkAndPlayerActivityMonitor() {
        self.netCheck?.startMonitor()
        self.playerActivityMonitor?.startMonitor()
    }
    /***********************网络连接播放器活跃状态监听 End*****************/

    /**************************监听播放时间 Action**********************/
    fileprivate func addPlayerPlayTimeObserver() {
        /// 监听播放时间
        self.player?.addPeriodicTimeObserver(forInterval: CMTimeMake(Int64(1.0), Int32(1.0)), queue: DispatchQueue.main, using: { [unowned self] (time) in
            
            if self.isSeeking { return }
            let playbackTime = CMTimeGetSeconds(time)
            let playBackTimeStr = self.playTimeFormatter(time: playbackTime)
            let durationTimeStr = self.playTimeFormatter(time: self.videoDurationSeconds!)
            let playedPrecent = Float(playbackTime)/Float(self.videoDurationSeconds!)
            self.playerControlPanel?.setVideoPlaybackTime(time: playBackTimeStr)
            self.playerControlPanel?.setVideoDurationTime(time: durationTimeStr)
            self.playerControlPanel?.setVideoPlayPercent(percentValue: playedPrecent)
        })
    }
    
    /// 时间格式变换
    fileprivate func playTimeFormatter(time:Float64) -> String? {
        let Min = lrint(time / 60)
        let Sec = lrint(time.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", Min, Sec)
    }
    
    /// 通过 value 0~1 计算视频时间
    fileprivate func seekTimeByValue(value:Float) -> CMTime {
        let duration = CMTimeGetSeconds((self.player?.currentItem?.duration)!)
        if  duration.isNaN || duration.isZero {
            return kCMTimeZero
        }
        let pullTime = Float64(value) * duration
        let totalTimeScale = Int32(duration)
        let time = CMTimeMakeWithSeconds(pullTime, totalTimeScale)
        return time
    }
    /**************************监听播放时间 end***********************/

    /// 手势调节
    /// 设置屏幕亮度 变化值 -1 ~ 1
    fileprivate func setLightValue(value:Float) {
        if self.player == nil { return }
        UIScreen.main.brightness = CGFloat(value)
    }
    
    /// 设置播放音量 变化值 -0 ~ 100
    fileprivate func setVolumChangedValue(value:Float) {
        if self.player == nil { return }
        var volum = (self.player?.volume)! + value
        if volum > 1 { volum = 1 }
        if volum < 0 { volum = 0 }
        self.player?.volume = volum
        print("音量 = \(self.player?.volume)")
    }
    
    /// 设置播放进度
    fileprivate func setPlayProgressValue(value:Float) {
        self.seekTimeToPlay(value: value)
    }
}
/** Private methods
    AVPlayer
    生成AVPlayerer AVPlayer AVPlayerItem AVAsset
    添加加载观察
    移除所有观察者
 */

extension HYMoviePlayer {
    
    /// PlayerLayer 预览层
    fileprivate func avPlayerLayer() -> AVPlayerLayer {
        let playerLayer = AVPlayerLayer.init()
        return playerLayer
    }
    /// Player
    fileprivate func avplyer(playAddress:String) -> AVPlayer {
        
        let playerItem = self.playerItem(playAddress: playAddress)
        let hyplayer = AVPlayer.init(playerItem: playerItem)
        self.listenPlayerLoading(playItem: playerItem)
        return hyplayer
        
    }
    
    /// PlayItem
    fileprivate func playerItem(playAddress:String) -> AVPlayerItem? {
        
        let playerItem = AVPlayerItem.init(asset: self.avasset(playAddress: playAddress), automaticallyLoadedAssetKeys: nil)
        return playerItem
    }
    
    /// AVAsset
    fileprivate func avasset(playAddress:String) -> AVAsset {
        
        let avasset = AVAsset.init(url: URL.init(string: playAddress)!)
        return avasset
        
    }
}

