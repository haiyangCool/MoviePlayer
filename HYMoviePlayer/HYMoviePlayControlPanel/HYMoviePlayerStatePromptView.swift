//
//  HYMoviePlayerStatePromptView.swift
//  HYMoviePlayer
//
//  Created by hyw on 2018/5/9.
//  Copyright © 2018年 王海洋. All rights reserved.
//
/**
    播放器状态提示图层
    根据播放器不同的状态显示
    图层样式:
 1、: 加载中…… UI
 2、: 提示断网，刷新 UI
 3、: 提示是否使用移动数据播放？ UI
 4、: 会员 UI
 5、：付费影片购买 UI
 
    加载播放器之前的判断：
    1)、无网络                   - 2
    2)、使用移动数据              - 3
    播放中：
    1)、加载                     - 1
    2)、断网并且缓存已经播完缓存     - 2
    3)、网络由WiFi -> 移动数据     - 3
    影片类型：
    1)、VIP                     - 4
    2)、付费                     - 5
 
 */
import UIKit
protocol HYMoviePlayerStatePromptViewDelegate {
    /// 状态页面产生的事件
    func hyMoviePlayerStatePromptView(statePromptView:HYMoviePlayerStatePromptView, actionType:HYMoviePlayerStatePromptType)
}
enum HYMoviePlayerStatePromptType:Int {
    /// 重新加载
    case reload
    /// 移动数据播放
    case cellurPlay
    /// 暂停播放
    case pause
}
class HYMoviePlayerStatePromptView: UIView {

    var delegate:HYMoviePlayerStatePromptViewDelegate?
    
    ///1 UI 加载中……
    fileprivate var loadingBackImageView:UIImageView?
    fileprivate var loadIndicator:UIActivityIndicatorView?
    fileprivate var loadingLabel:UILabel?
    
    ///2 UI 断网
    fileprivate var LoseNetBackImageView:UIImageView?
    fileprivate var loseNetlinkLabel:UILabel?
    fileprivate var reloadBtn:UIButton?
    
    ///3 UI 移动数据播放？
    fileprivate var cellursPlayBackImageView:UIImageView?
    fileprivate var cellursPlayLabel:UILabel?
    fileprivate var cellersGapLine:UIImageView?
    fileprivate var playBtn:UIButton?
    fileprivate var pauseBtn:UIButton?
    
    /// 根据产品需求自行实现更多的UI类型
    ///4 UI VIP 影片
    
    ///5 UI 付费UI
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

/** Public methods*/
extension HYMoviePlayerStatePromptView {
    
    /// 加载中……
    func loading() {
        self.isHidden = false
        if self.loadingBackImageView == nil {
            self.initLoadingViews()
        }
        self.loadIndicator?.startAnimating()
        self.loadingBackImageView?.isHidden = false
        self.LoseNetBackImageView?.isHidden = true
        self.cellursPlayBackImageView?.isHidden = true
    }
    /// 断网 , 重新加载
    func loseNetLink() {
        loseNetlinkLabel?.text = "世界上最遥远的距离就是断网"
        reloadBtn?.setTitle("刷新", for: .normal)
        self.loseNetOrLoadFaildState()
    }
    /// 移动数据播放
    func cellursPlay() {
        self.isHidden = false
        if self.cellursPlayBackImageView == nil {
            self.initCellursPromptView()
        }
        self.cellursPlayBackImageView?.isHidden = false
        self.LoseNetBackImageView?.isHidden = true
        self.loadingBackImageView?.isHidden = true
        self.loadIndicator?.stopAnimating()
    }
    /// 加载失败，重新加载
    func loadFaild() {
        loseNetlinkLabel?.text = "视频加载失败,请检查网络连接"
        reloadBtn?.setTitle("点击重试", for: .normal)
        self.loseNetOrLoadFaildState()
    }
    /// hidden
    func hidden() {
        self.cellursPlayBackImageView?.isHidden = true
        self.LoseNetBackImageView?.isHidden = true
        self.loadingBackImageView?.isHidden = true
        self.loadIndicator?.stopAnimating()
        self.isHidden = true
    }
}
/// Private methods
extension HYMoviePlayerStatePromptView {
    
    fileprivate func loseNetOrLoadFaildState() {
        self.isHidden = false
        if self.LoseNetBackImageView == nil {
            self.initLoseNetLinkView()
        }
        self.LoseNetBackImageView?.isHidden = false
        self.loadingBackImageView?.isHidden = true
        self.cellursPlayBackImageView?.isHidden = true
        self.loadIndicator?.stopAnimating()
    }
    /// 刷新、移动数据播放、停止播放
    @objc fileprivate func touchAction(btn:UIButton) {
        
        let type:HYMoviePlayerStatePromptType = HYMoviePlayerStatePromptType(rawValue: btn.tag)!
        self.delegate?.hyMoviePlayerStatePromptView(statePromptView: self, actionType: type)
    }
}
///UI and Layout
extension HYMoviePlayerStatePromptView {
    
    /// loadingUI
    fileprivate func initLoadingViews() {
        
        loadingBackImageView = UIImageView.init()
        loadingBackImageView?.backgroundColor = UIColor.init(white: 0, alpha: 0.2)
        loadingBackImageView?.isUserInteractionEnabled = true
        self.addSubview(loadingBackImageView!)
        
        loadIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .white)
        self.loadingBackImageView?.addSubview(loadIndicator!)
        
        loadingLabel = UILabel.init()
        loadingLabel?.backgroundColor = UIColor.clear
        loadingLabel?.textColor = UIColor.white
        loadingLabel?.textAlignment = .center
        loadingLabel?.font = UIFont.systemFont(ofSize: 15)
        loadingLabel?.text = "客官请稍等…"
        self.loadingBackImageView?.addSubview(loadingLabel!)
        
        
        loadingBackImageView?.snp.makeConstraints({ (make) in
            make.top.left.right.bottom.equalTo(self)
        })
        loadingLabel?.snp.makeConstraints({ (make) in
            make.centerX.equalTo((self.loadingBackImageView?.snp.centerX)!).offset(15)
            make.centerY.equalTo((self.loadingBackImageView?.snp.centerY)!)
            make.width.equalTo(90)
            make.height.equalTo(30)
        })
        loadIndicator?.snp.makeConstraints({ (make) in
            make.centerY.equalTo((self.loadingBackImageView?.snp.centerY)!)
            make.right.equalTo((self.loadingLabel?.snp.left)!).offset(-2)
            make.width.height.equalTo(30)
        })
        self.loadIndicator?.startAnimating()
        
    }
    /// loseNetUI
    fileprivate func initLoseNetLinkView() {
        
        LoseNetBackImageView =  UIImageView.init()
        LoseNetBackImageView?.backgroundColor = UIColor.init(white: 0, alpha: 0.2)
        LoseNetBackImageView?.isUserInteractionEnabled = true
        self.addSubview(LoseNetBackImageView!)
        
        loseNetlinkLabel =  UILabel.init()
        loseNetlinkLabel?.backgroundColor = UIColor.clear
        loseNetlinkLabel?.textColor = UIColor.white
        loseNetlinkLabel?.textAlignment = .center
        loseNetlinkLabel?.font = UIFont.systemFont(ofSize: 14)
        loseNetlinkLabel?.text = "世界上最遥远的距离就是断网"
        self.LoseNetBackImageView?.addSubview(loseNetlinkLabel!)
        
        reloadBtn = UIButton.init(type: .custom)
        reloadBtn?.backgroundColor = UIColor.orange
        reloadBtn?.layer.cornerRadius = 15
        reloadBtn?.setTitleColor(UIColor.white, for: .normal)
        reloadBtn?.setTitle("刷新", for: .normal)
        reloadBtn?.tag = HYMoviePlayerStatePromptType.reload.rawValue
        reloadBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        reloadBtn?.addTarget(self, action: #selector(touchAction(btn:)), for: .touchUpInside)
        self.LoseNetBackImageView?.addSubview(reloadBtn!)
        
        LoseNetBackImageView?.snp.makeConstraints({ (make) in
            make.top.left.right.bottom.equalTo(self)
        })
        loseNetlinkLabel?.snp.makeConstraints({ (make) in
            make.center.equalTo(self.LoseNetBackImageView!)
            make.width.equalTo(200)
            make.height.equalTo(16)
        })
        reloadBtn?.snp.makeConstraints({ (make) in
            make.top.equalTo((self.loseNetlinkLabel?.snp.bottom)!).offset(10)
            make.centerX.equalTo((self.LoseNetBackImageView?.snp.centerX)!)
            make.width.equalTo(80)
            make.height.equalTo(30)
        })

    }
    /// cellursUI
    fileprivate func initCellursPromptView() {
        
        cellursPlayBackImageView =  UIImageView.init()
        cellursPlayBackImageView?.backgroundColor = UIColor.init(white: 1, alpha: 1)
        cellursPlayBackImageView?.layer.cornerRadius = 15
        cellursPlayBackImageView?.isUserInteractionEnabled = true
        self.addSubview(cellursPlayBackImageView!)
        
        cellursPlayLabel = UILabel.init()
        cellursPlayLabel?.backgroundColor = UIColor.clear
        cellursPlayLabel?.textColor = UIColor.black
        cellursPlayLabel?.textAlignment = .center
        cellursPlayLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        cellursPlayLabel?.text = "您当前正在使用移动数据,是否继续观看?"
        cellursPlayLabel?.numberOfLines = 0
        self.cellursPlayBackImageView?.addSubview(cellursPlayLabel!)
        
        cellersGapLine = UIImageView.init()
        cellersGapLine?.backgroundColor = UIColor.init(white: 0, alpha: 0.1)
        self.cellursPlayBackImageView?.addSubview(cellersGapLine!)
        
        playBtn = UIButton.init(type: .custom)
        playBtn?.backgroundColor = UIColor.clear
        playBtn?.layer.backgroundColor = UIColor.white.cgColor
        playBtn?.layer.cornerRadius = 15
        playBtn?.layer.borderWidth = 0.6
        playBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        playBtn?.setTitle("继续播放", for: .normal)
        playBtn?.setTitleColor(UIColor.black, for: .normal)
        playBtn?.setTitleColor(UIColor.lightGray, for: .highlighted)
        playBtn?.tag = HYMoviePlayerStatePromptType.cellurPlay.rawValue
        playBtn?.addTarget(self, action: #selector(touchAction(btn:)), for: .touchUpInside)
        self.cellursPlayBackImageView?.addSubview(playBtn!)
        
        pauseBtn = UIButton.init(type: .custom)
        pauseBtn?.backgroundColor = UIColor.clear
        pauseBtn?.layer.cornerRadius = 15
        pauseBtn?.layer.backgroundColor = UIColor.white.cgColor
        pauseBtn?.layer.borderWidth = 0.6
        pauseBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        pauseBtn?.setTitle("不再观看", for: .normal)
        pauseBtn?.setTitleColor(UIColor.black, for: .normal)
        pauseBtn?.setTitleColor(UIColor.lightGray, for: .highlighted)
        pauseBtn?.tag = HYMoviePlayerStatePromptType.pause.rawValue
        pauseBtn?.addTarget(self, action: #selector(touchAction(btn:)), for: .touchUpInside)
        self.cellursPlayBackImageView?.addSubview(pauseBtn!)
        
        cellursPlayBackImageView?.snp.makeConstraints({ (make) in
            make.center.equalTo(self)
            make.width.equalTo(230)
            make.height.equalTo(110)
        })
        cellersGapLine?.snp.makeConstraints({ (make) in
            make.centerY.equalTo((self.cellursPlayBackImageView?.snp.centerY)!)
            make.left.equalTo((self.cellursPlayBackImageView?.snp.left)!).offset(5)
            make.right.equalTo((self.cellursPlayBackImageView?.snp.right)!).offset(-5)
            make.height.equalTo(0.6)
        })
        cellursPlayLabel?.snp.makeConstraints({ (make) in
            make.top.equalTo((self.cellursPlayBackImageView?.snp.top)!).offset(10)
            make.centerX.equalTo((self.cellursPlayBackImageView?.snp.centerX)!)
            make.width.equalTo(200)
            make.height.equalTo(40)
        })
        pauseBtn?.snp.makeConstraints({ (make) in
            make.top.equalTo((self.cellursPlayBackImageView?.snp.centerY)!).offset(10)
            make.centerX.equalTo((self.cellursPlayBackImageView?.snp.centerX)!).offset(-50)
                make.width.equalTo(80)
            make.height.equalTo(30)
        })
        
        playBtn?.snp.makeConstraints({ (make) in
            make.top.equalTo((self.cellursPlayBackImageView?.snp.centerY)!).offset(10)
            make.centerX.equalTo((self.cellursPlayBackImageView?.snp.centerX)!).offset(50)
            make.width.equalTo(80)
            make.height.equalTo(30)
        })
    }
}
