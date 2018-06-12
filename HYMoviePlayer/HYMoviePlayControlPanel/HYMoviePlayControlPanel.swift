//
//  HYMoviePlayControlPanel.swift
//  HYMoviePlayer
//
//  Created by hyw on 2018/5/8.
//  Copyright © 2018年 王海洋. All rights reserved.
//
/** 基本功能
    1、上导航栏
    返回
    title
    更多的扩展
 
    2、下控制栏
    播放/暂停、播放时间/视频时长、播放进度、全屏/小屏
 
    3、屏
    锁屏
    单击（显示、隐藏导航栏和控制栏）/双击（播放暂停）
    左半边屏幕 上下滑动控制屏幕亮度
    右半边屏幕 上下滑动控制播放器音量
    屏幕左右滑动 控制播放进度
 
    扩展功能-将持续添加
    截取视频图片、gif
    下载
    活动、广告
 */
protocol HYMoviePlayControlPanelDelegate {
    
    /// 按键控制
    func hyMoviePlayControlPanelButtonAction(controPanel:HYMoviePlayControlPanel,controlType:HYPlayerControlType)
    /// 进度\亮度\音量 调节
    func hyMoviePlayControlPanelGusterAction(controPanel:HYMoviePlayControlPanel,controlType:HYPlayerControlType, value:Float)
}
import UIKit
import SnapKit
enum HYPlayerControlType:Int {
    /// 返回
    case backType  = 2018508
    /// 播放
    case playType
    /// 暂停
    case pauseType
    /// 全屏
    case fullScreenType
    /// 小屏
    case shrikenScreenType
    /// 锁屏
    case lockScreenType
    /// 解锁屏
    case unLockScreenType
    /// 重新加载
    case reloadType
    /// 开通会员
    case openMemberType
    /// 购买影片
    case buyMoviesType
    /// 进度调整
    case playPercentAdjust
    /// 亮度调整
    case lightAdjust
    /// 音量调整
    case volumAdjust
}
class HYMoviePlayControlPanel: UIView {
    
    var delegate:HYMoviePlayControlPanelDelegate?
    
    /// 播放状体提示View
    fileprivate var playerStatePromptView:HYMoviePlayerStatePromptView?
    /// 手势响应层
    fileprivate var guserResponseView:HYMoviePlayerGusterResponseView?
    /// 导航
    fileprivate var navigation:UIImageView?
    /// 返回、全屏时做小屏动作
    fileprivate var backBtn:UIButton?
    /// 视频名称
    fileprivate var titleLable:UILabel?
    /// 控制栏
    fileprivate var controlPanel:UIImageView?
    /// 播放
    fileprivate var playBtn:UIButton?
    /// 暂停
    fileprivate var pauseBtn:UIButton?
    /// 已经播放的时间
    fileprivate var playBackTimeLabel:UILabel?
    /// 视频时长
    fileprivate var durationTimeLabel:UILabel?
    /// 缓存进度
    fileprivate var videoBufferProgressView:UIProgressView?
    /// 播放进度
    fileprivate var videoPlaySlider:UISlider?
    /// 全屏
    fileprivate var fullScreenBtn:UIButton?
    /// 小屏
    fileprivate var shrikenScreenBtn:UIButton?
    /// 锁屏
    fileprivate var lockBtn:UIButton?
    /// 解锁屏幕
    fileprivate var unLockBtn:UIButton?
    
    /// 上下导航是否隐藏
    fileprivate var isHiddenControlPanel:Bool = false
    /// 屏幕状态
    fileprivate var isFullScreen:Bool = false
    /// 锁屏状态
    fileprivate var isLock:Bool = false
    /// 延时事物、隐藏上下导航
    fileprivate var task:DispatchQueue.Task?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.initAllSubviews()
        self.layoutAllSubviews()
        self.autoDelayTraction()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
/// Public methods
extension HYMoviePlayControlPanel {
    
    /// 视频名称
    func setVideoTitle(title:String?) {
        self.titleLable?.text = title
    }
    /// 视频时长
    func setVideoDurationTime(time:String?) {
        self.durationTimeLabel?.text = time
    }
    /// 播放时间
    func setVideoPlaybackTime(time:String?) {
        self.playBackTimeLabel?.text = time
    }
    
    /// 缓存 0~1
    func setVideoBuffer(bufferValue:Float) {
        self.videoBufferProgressView?.setProgress(bufferValue, animated: true)
    }

    /// 播放进度 0~1
    func setVideoPlayPercent(percentValue:Float) {
        self.videoPlaySlider?.value = percentValue
    }
    
    /// 设置播放(Yes\No)状态
    func setPlayState(isPlay:Bool) {
        if isPlay {
            self.playBtn?.isHidden = true
            self.pauseBtn?.isHidden = false
        }else {
            self.playBtn?.isHidden = false
            self.pauseBtn?.isHidden = true
        }
    }
    
    /// 设置全屏(Yes\No)状态
    func setFullScreenState(isFullScreen:Bool) {
        if isFullScreen {
            self.isFullScreen = true
            self.fullScreenBtn?.isHidden = true
            self.shrikenScreenBtn?.isHidden = false
        }else {
            self.isFullScreen = false
            self.fullScreenBtn?.isHidden = false
            self.shrikenScreenBtn?.isHidden = true
        }
    }

    /// 设置锁屏(Yes\No)状态
    func setLockScreenState(isLockScreen:Bool) {
        if isLockScreen {
            self.isLock = true
            self.lockBtn?.isHidden = true
            self.unLockBtn?.isHidden = false
            self.hiddenNavifationAndControlPanel()
        }else {
            self.isLock = false
            self.lockBtn?.isHidden = false
            self.unLockBtn?.isHidden = true
            self.showNavifationAndControlPanel()
        }
    }
    
    /// 播放器播放状态 对应的UI
    /// loading UI
    func setLoadingState() {
        self.playerStatePromptView?.loading()
    }
    /// 断网、重新加载UI
    func setLoseNetLinkState() {
        self.playerStatePromptView?.loseNetLink()
    }
    /// 加载失败，重新加载UI
    func setLoadFaildState() {
        self.playerStatePromptView?.loadFaild()
    }
    /// 流量移动数据观看视频提示
    func setCellurePlayViewState() {
        self.playerStatePromptView?.cellursPlay()
    }
    /// 隐藏
    func hiddenPlayStatePromptView() {
        self.playerStatePromptView?.hidden()
    }
}
/*****************************Delegate methods*****************************/
extension HYMoviePlayControlPanel:HYMoviePlayerStatePromptViewDelegate{
    /// 状态页面产生的事件
    func hyMoviePlayerStatePromptView(statePromptView:HYMoviePlayerStatePromptView, actionType:HYMoviePlayerStatePromptType) {
        let type = actionType
        switch type {
        case .reload:
            self.delegate?.hyMoviePlayControlPanelButtonAction(controPanel: self, controlType: .reloadType)
            break
        case .cellurPlay:
            statePromptView.hidden()
            self.delegate?.hyMoviePlayControlPanelButtonAction(controPanel: self, controlType: .playType)
            break
        case .pause:
            statePromptView.hidden()
            self.delegate?.hyMoviePlayControlPanelButtonAction(controPanel: self, controlType: .pauseType)
            break
        default:
            break
        }
        
    }
}
/// 手势控制
extension HYMoviePlayControlPanel:HYMoviePlayerGusterResponseViewDelegate{
    /// 手势控制
    func hyMoviePlayerGusterResponseViewGuster(gusterView:HYMoviePlayerGusterResponseView, gusterType:HYMoviePlayerGusterType, value:Float) {
        
        let type = gusterType
        switch type {
        case .singletap:
            self.singleScreenTap()
            break
        case .doubletap:
            self.doubleScreenTap()
            break
        case .light:
            self.delegate?.hyMoviePlayControlPanelGusterAction(controPanel: self, controlType: .lightAdjust, value: self.lightValue(value: value))
            break
        case .volum:
            self.delegate?.hyMoviePlayControlPanelGusterAction(controPanel: self, controlType: .volumAdjust, value: value)
            break
        case .progress:
            self.delegate?.hyMoviePlayControlPanelGusterAction(controPanel: self, controlType: .playPercentAdjust, value: self.playProgressValue(value: value))
            break
        default:
            break
        }
        
    }
}
/*****************************Delegate End*****************************/

/// Private Methods
extension HYMoviePlayControlPanel {
    
    /************************** 播控 Start**************************/
    @objc fileprivate func controlAction(btn:UIButton) {
        print("播控")
        var type:HYPlayerControlType = HYPlayerControlType(rawValue: btn.tag)!
        /// 全屏时，返回按钮当做小屏处理
        if type == .backType && self.isFullScreen {
            type = .shrikenScreenType
        }
        self.delegate?.hyMoviePlayControlPanelButtonAction(controPanel: self, controlType: type)
    }
    
    @objc fileprivate func playSliderPan(panel:HYMoviePlayControlPanel, value:Float) {
        self.delegate?.hyMoviePlayControlPanelGusterAction(controPanel: self, controlType: .playPercentAdjust, value: (self.videoPlaySlider?.value)!)
    }
    /************************** 播控 End****************************/

    /*************************** 导航、控制栏************************/
    
    /// 隐藏上下导航、控制栏
    fileprivate func hiddenNavifationAndControlPanel() {
        self.isHiddenControlPanel = true
        if self.isLock {
            UIView.animate(withDuration: 0.3) {
                self.navigation?.alpha = 0
                self.controlPanel?.alpha = 0
            }
        }else {
            UIView.animate(withDuration: 0.3) {
                self.navigation?.alpha = 0
                self.controlPanel?.alpha = 0
                self.lockBtn?.alpha = 0
            }
        }
    }
    
    /// 显示上下导航、控制栏
    fileprivate func showNavifationAndControlPanel() {
        self.isHiddenControlPanel = false
        UIView.animate(withDuration: 0.3, animations: {
            self.navigation?.alpha = 1
            self.controlPanel?.alpha = 1
            self.lockBtn?.alpha = 1
        }) { (flag) in
            self.cancelDelayTraction()
            self.autoDelayTraction()
        }
    }
    
    /// 自动延时事物
    fileprivate func autoDelayTraction() {
        
        task = DispatchQueue.main.delayRun(6, task: {
            self.hiddenNavifationAndControlPanel()
        })
    }
    
    /// 取消自动延时事物
    fileprivate func cancelDelayTraction() {
        
        DispatchQueue.main.cancel(task)
    }
    
    /// 单击屏幕
    fileprivate func singleScreenTap() {
        if self.isLock { return }
        if isHiddenControlPanel {
            self.isHiddenControlPanel = false
            self.showNavifationAndControlPanel()
        }else {
            self.isHiddenControlPanel = true
            self.hiddenNavifationAndControlPanel()
        }
    }
    
    /// 双击屏幕
    fileprivate func doubleScreenTap() {
        if self.isLock { return }
        if (self.playBtn?.isHidden)! {
            self.delegate?.hyMoviePlayControlPanelButtonAction(controPanel: self, controlType: .pauseType)
        }else {
            self.delegate?.hyMoviePlayControlPanelButtonAction(controPanel: self, controlType: .playType)
        }
    }
    
    /// 计算亮度值
    fileprivate func lightValue(value:Float) -> Float{
        var light =  UIScreen.main.brightness + CGFloat(value)
        if light > 1 { light = 1 }
        if light < 0 { light = 0 }
        return Float(light)
    }
    /// 计算播放进度值 0~1
    fileprivate func playProgressValue(value:Float) -> Float {
        var progress = (self.videoPlaySlider?.value)! + value
        if progress > 1 { progress = 1 }
        if progress < 0 { progress = 0 }
        return progress
    }
}
/// UI and Layout
extension HYMoviePlayControlPanel {
    /// Subviews
    fileprivate func initAllSubviews() {
        
        guserResponseView = HYMoviePlayerGusterResponseView()
        guserResponseView?.delegate = self
        self.addSubview(guserResponseView!)
        
        playerStatePromptView = HYMoviePlayerStatePromptView()
        playerStatePromptView?.delegate = self
        self.addSubview(playerStatePromptView!)
        playerStatePromptView?.loading()
        
        navigation = UIImageView.init()
        navigation?.backgroundColor = UIColor.init(white: 0, alpha: 0.8)
        navigation?.isUserInteractionEnabled = true
        self.addSubview(navigation!)
        
        backBtn = UIButton.init(type: .custom)
        backBtn?.backgroundColor = UIColor.clear
        backBtn?.tag = HYPlayerControlType.backType.rawValue
        backBtn?.setImage(#imageLiteral(resourceName: "HYMoviePlayerBack"), for: .normal)
        backBtn?.addTarget(self, action: #selector(controlAction(btn:)), for: .touchUpInside)
        self.navigation?.addSubview(backBtn!)
        
        titleLable = UILabel.init()
        titleLable?.backgroundColor = UIColor.clear
        titleLable?.textColor = UIColor.white
        titleLable?.textAlignment = .left
        titleLable?.font = UIFont.systemFont(ofSize: 15)
        self.navigation?.addSubview(titleLable!)
        
        controlPanel = UIImageView.init()
        controlPanel?.backgroundColor = UIColor.init(white: 0, alpha: 0.8)
        controlPanel?.isUserInteractionEnabled = true
        self.addSubview(controlPanel!)
        
        playBtn = UIButton.init(type: .custom)
        playBtn?.backgroundColor = UIColor.clear
        playBtn?.tag = HYPlayerControlType.playType.rawValue
        playBtn?.setImage(#imageLiteral(resourceName: "HYMoviePlayerPause"), for: .normal)
        playBtn?.addTarget(self, action: #selector(controlAction(btn:)), for: .touchUpInside)
        self.controlPanel?.addSubview(playBtn!)
        
        pauseBtn = UIButton.init(type: .custom)
        pauseBtn?.backgroundColor = UIColor.clear
        pauseBtn?.tag = HYPlayerControlType.pauseType.rawValue
        pauseBtn?.setImage(#imageLiteral(resourceName: "HYMoviePlayerPlay"), for: .normal)
        pauseBtn?.addTarget(self, action: #selector(controlAction(btn:)), for: .touchUpInside)
        pauseBtn?.isHidden = true
        self.controlPanel?.addSubview(pauseBtn!)
        
        playBackTimeLabel = UILabel.init()
        playBackTimeLabel?.backgroundColor = UIColor.clear
        playBackTimeLabel?.textColor = UIColor.white
        playBackTimeLabel?.textAlignment = .center
        playBackTimeLabel?.font = UIFont.systemFont(ofSize: 13)
        playBackTimeLabel?.text = "00:00"
        self.controlPanel?.addSubview(playBackTimeLabel!)
        
        durationTimeLabel = UILabel.init()
        durationTimeLabel?.backgroundColor = UIColor.clear
        durationTimeLabel?.textColor = UIColor.white
        durationTimeLabel?.textAlignment = .center
        durationTimeLabel?.font = UIFont.systemFont(ofSize: 13)
        durationTimeLabel?.text = "00:00"
        self.controlPanel?.addSubview(durationTimeLabel!)
        
        videoBufferProgressView = UIProgressView.init(progressViewStyle: .default)
        videoBufferProgressView?.progress = 0.0
        videoBufferProgressView?.tintColor = UIColor.white
        videoBufferProgressView?.trackTintColor = UIColor.lightGray
        self.controlPanel?.addSubview(videoBufferProgressView!)
        
        videoPlaySlider = UISlider.init()
        videoPlaySlider?.maximumValue = 1.0
        videoPlaySlider?.minimumValue = 0.0
        videoPlaySlider?.maximumTrackTintColor = UIColor.clear
        videoPlaySlider?.minimumTrackTintColor = UIColor.green
        videoPlaySlider?.value = 0.0
        videoPlaySlider?.setThumbImage(#imageLiteral(resourceName: "HYMoviePlayerSliderDot"), for: .normal)
        videoPlaySlider?.addTarget(self, action: #selector(playSliderPan(panel:value:)), for: .valueChanged)
        self.controlPanel?.addSubview(videoPlaySlider!)
        
        fullScreenBtn = UIButton.init(type: .custom)
        fullScreenBtn?.backgroundColor = UIColor.clear
        fullScreenBtn?.tag = HYPlayerControlType.fullScreenType.rawValue
        fullScreenBtn?.setImage(#imageLiteral(resourceName: "HYMoviePlayerFullScreen"), for: .normal)
        fullScreenBtn?.addTarget(self, action: #selector(controlAction(btn:)), for: .touchUpInside)
        self.controlPanel?.addSubview(fullScreenBtn!)
        
        shrikenScreenBtn = UIButton.init(type: .custom)
        shrikenScreenBtn?.backgroundColor = UIColor.clear
        shrikenScreenBtn?.tag = HYPlayerControlType.shrikenScreenType.rawValue
        shrikenScreenBtn?.setImage(#imageLiteral(resourceName: "HYMoviePlayerShrikenScreen"), for: .normal)
        shrikenScreenBtn?.addTarget(self, action: #selector(controlAction(btn:)), for: .touchUpInside)
        shrikenScreenBtn?.isHidden = true
        self.controlPanel?.addSubview(shrikenScreenBtn!)
        
        lockBtn = UIButton.init(type: .custom)
        lockBtn?.backgroundColor = UIColor.clear
        lockBtn?.tag = HYPlayerControlType.lockScreenType.rawValue
        lockBtn?.setImage(#imageLiteral(resourceName: "HYMoviePlayerUnLockScreen"), for: .normal)
        lockBtn?.addTarget(self, action: #selector(controlAction(btn:)), for: .touchUpInside)
        self.addSubview(lockBtn!)
        
        unLockBtn = UIButton.init(type: .custom)
        unLockBtn?.backgroundColor = UIColor.clear
        unLockBtn?.tag = HYPlayerControlType.unLockScreenType.rawValue
        unLockBtn?.setImage(#imageLiteral(resourceName: "HYMoviePlayerLockScreen"), for: .normal)
        unLockBtn?.addTarget(self, action: #selector(controlAction(btn:)), for: .touchUpInside)
        unLockBtn?.isHidden = true
        self.addSubview(unLockBtn!)
    }
    
    fileprivate func layoutAllSubviews() {
        
        guserResponseView?.snp.makeConstraints({ (make) in
            make.top.left.right.bottom.equalTo(self)
        })
        
        playerStatePromptView?.snp.makeConstraints({ (make) in
            make.top.left.right.bottom.equalTo(self)
        })
        
        self.navigation?.snp.makeConstraints({ (make) in
            make.top.left.right.equalTo(self)
            make.height.equalTo(60)
        })
        
        self.backBtn?.snp.makeConstraints({ (make) in
            make.left.equalTo((self.navigation?.snp.left)!).offset(5)
            make.top.equalTo((self.navigation?.snp.top)!).offset(20)
            make.width.height.equalTo(40)
        })
        
        self.titleLable?.snp.makeConstraints({ (make) in
            make.left.equalTo((self.backBtn?.snp.right)!).offset(10)
            make.right.equalTo((self.navigation?.snp.right)!).offset(-10)
            make.top.equalTo((self.backBtn?.snp.top)!)
            make.height.equalTo((self.backBtn?.snp.height)!)
        })
        
        self.lockBtn?.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self.snp.centerY)
            make.left.equalTo(self.snp.left).offset(14)
            make.width.height.equalTo(40)
        })
        
        self.unLockBtn?.snp.makeConstraints({ (make) in
            make.top.left.width.height.equalTo(self.lockBtn!)
        })
        
        self.controlPanel?.snp.makeConstraints({ (make) in
            make.left.right.bottom.equalTo(self)
            make.height.equalTo(40)
        })
        
        self.playBtn?.snp.makeConstraints({ (make) in
            make.left.equalTo((self.controlPanel?.snp.left)!).offset(5)
            make.centerY.equalTo((self.controlPanel?.snp.centerY)!)
            make.width.height.equalTo(40)
        })
        
        self.pauseBtn?.snp.makeConstraints({ (make) in
            make.left.top.width.height.equalTo(self.playBtn!)
        })
        
        self.fullScreenBtn?.snp.makeConstraints({ (make) in
            make.right.equalTo((self.controlPanel?.snp.right)!).offset(-5)
            make.centerY.equalTo((self.controlPanel?.snp.centerY)!)
            make.width.height.equalTo(40)
        })
        
        self.shrikenScreenBtn?.snp.makeConstraints({ (make) in
            make.left.top.width.height.equalTo(self.fullScreenBtn!)

        })
        
        self.playBackTimeLabel?.snp.makeConstraints({ (make) in
            make.left.equalTo((self.playBtn?.snp.right)!).offset(5)
            make.centerY.equalTo((self.controlPanel?.snp.centerY)!)
            make.width.equalTo(50)
            make.height.equalTo(20)
        })
        
        self.durationTimeLabel?.snp.makeConstraints({ (make) in
            make.right.equalTo((self.fullScreenBtn?.snp.left)!).offset(-5)
            make.centerY.equalTo((self.controlPanel?.snp.centerY)!)
            make.width.equalTo(50)
            make.height.equalTo(20)
        })
        
        self.videoBufferProgressView?.snp.makeConstraints({ (make) in
            make.left.equalTo((self.playBackTimeLabel?.snp.right)!).offset(5)
            make.right.equalTo((self.durationTimeLabel?.snp.left)!).offset(-5)
            make.centerY.equalTo((self.controlPanel?.snp.centerY)!)
            make.height.equalTo(1)
        })
        
        self.videoPlaySlider?.snp.makeConstraints({ (make) in
            make.left.equalTo((self.playBackTimeLabel?.snp.right)!).offset(5)
            make.right.equalTo((self.durationTimeLabel?.snp.left)!).offset(-5)
            make.centerY.equalTo((self.controlPanel?.snp.centerY)!)
            make.height.equalTo(30)
        })
    }
}
