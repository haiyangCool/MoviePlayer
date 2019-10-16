//
//  VVPlayerCoverView+Loading.swift
//  VVPlayer
//
//  Created by 王海洋 on 2018/10/14.
//  Copyright © 2019 王海洋. All rights reserved.
//

import Foundation
import UIKit
/** CoverView loading
 */

private var LoadingKey: Void?
private var LoadErrorKey: Void?
private var NetErrorKey: Void?


private var LoadUIActionKey: Void?

@objc protocol VVPlayerLoadAction: NSObjectProtocol {
    
    /// 加载错误、重新加载
    @objc optional func reload(_ errorView: VVLoadErrorView)
    
    /// 使用流量播放
    /// - Parameter netView:
    @objc optional func celluarPlay(_ netView: VVNetErrorView)
    
    /// 停止流量播放
    /// - Parameter netView:
    @objc optional func celluarStop(_ netView: VVNetErrorView)
}

extension VVPlayerCoverView {
        
    /** Loading*******************************/
    func addLoadingView() {
        
        loadingView = VVLoadingView(frame: bounds)
        addSubview(loadingView)
        loadingView.isHidden = true

    }
    
    func loadViewTransform(_ frame: CGRect) {
        loadingView.frame = frame
    }
    
    func showLoading() {
        
        loadingView.startAnimating()
        loadingView.isHidden = false
        
        hiddenLoadError()
        hiddenNetException()

    }
    
    func hiddenLoading() {
        
        if !loadingView.isHidden {
            loadingView.stopAnimating()
            loadingView.isHidden = true
        }
    }
    
    /** Load Error*******************************/
    
    func addLoadErrorView() {
        
        loadErrorView = VVLoadErrorView(frame: bounds)
        loadErrorView.delegate = self
        addSubview(loadErrorView)
        
    }
    
    func loadErrorViewTransform(_ frame: CGRect) {
        loadErrorView.frame = frame
    }
    
    func showLoadError() {
        loadErrorView.isHidden = false
        
        loadingView.stopAnimating()
        hiddenLoading()
        
        hiddenNetException()
    }
    
    func hiddenLoadError() {
        
        if !loadErrorView.isHidden {
            loadErrorView.isHidden = true
        }
    }
    
    /** Net exception 断网、流量播放提醒 UI***********/
    func addNetExceptionView() {
        
        netErrorView = VVNetErrorView(frame: bounds)
        addSubview(netErrorView)
    }
    
    func netErrorViewTransform(_ frame: CGRect) {
        netErrorView.frame = frame
    }
    
    func showNetException(_ type: NetErrorType) {
        netErrorView.isHidden = false
        netErrorView.setType(type)
        
        loadingView.stopAnimating()
        hiddenLoading()

        hiddenLoadError()
    }
    
    func hiddenNetException() {
        
        if !netErrorView.isHidden {
            netErrorView.isHidden = true
        }
    }
}
// MARK: UI 操作事件
extension VVPlayerCoverView: VVLoadError {
    
    @objc func reload() {
        if let delegate = loadAction, delegate.responds(to: #selector(delegate.reload(_:))) {
            delegate.reload?(loadErrorView)
        }
    }
}

extension VVPlayerCoverView {
    
    private var loadingView: VVLoadingView {
        
        get {
            let v = objc_getAssociatedObject(self, &LoadingKey) as? VVLoadingView
            if let v = v {
                return v
            }
            
            return VVLoadingView.init(frame: self.bounds)
        }
        
        set {
            objc_setAssociatedObject(self, &LoadingKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var loadErrorView: VVLoadErrorView {
        
        get {
            let v = objc_getAssociatedObject(self, &LoadErrorKey) as? VVLoadErrorView
            if let v = v {
                return v
            }
            return VVLoadErrorView.init(frame: self.bounds)
        }
        
        set {
            objc_setAssociatedObject(self, &LoadErrorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var netErrorView: VVNetErrorView {
        
        get {
            let v = objc_getAssociatedObject(self, &NetErrorKey) as? VVNetErrorView
            if let v = v {
                return v
            }
            return VVNetErrorView.init(frame: self.bounds)
        }
        
        set {
            objc_setAssociatedObject(self, &NetErrorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var loadAction: VVPlayerLoadAction? {
        
        get {
            return objc_getAssociatedObject(self, &LoadUIActionKey) as? VVPlayerLoadAction
        }
        set {
            
            objc_setAssociatedObject(self, &LoadUIActionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}

// MARK: Loading UI
class VVLoadingView: UIView {
        
    lazy var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .white)
        indicator.color = .white
        indicator.startAnimating()
        return indicator
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.init(white: 0, alpha: 0.3)
        addSubview(indicator)
        layout()
        
    }
    
    func startAnimating() {
        indicator.startAnimating()
    }
    
    func stopAnimating() {
        indicator.stopAnimating()
    }
    
    fileprivate func layout() {
        
        indicator.snp.makeConstraints { (maker) in
            maker.centerX.equalTo(self.snp.centerX)
            maker.centerY.equalTo(self.snp.centerY)
        }
       
    }
    
    required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
    }
}

// MARK: 加载失败UI
protocol VVLoadError: NSObjectProtocol {
    func reload()
}
private let LoadErrorMsg = "视频加载失败,请重试"
private let LoadErrorMsgFont = UIFont.systemFont(ofSize: 15)
private let loadBtnTitle = "点击重试"
private let ErrorLabelHeight: CGFloat = 30
private let ErrorLoadBtnWidth: CGFloat = 100
private let ErrorLoadBtnHeight: CGFloat = 30

class VVLoadErrorView: UIView {
    
    weak var delegate: VVLoadError?
   
    
    lazy var errorLabel: UILabel = {
        let errorLabel = UILabel()
        errorLabel.textColor = .white
        errorLabel.textAlignment = .center
        errorLabel.font =  LoadErrorMsgFont
        errorLabel.text = LoadErrorMsg
        return errorLabel
    }()
    
    lazy var loadBtn: UIButton = {
        let loadBtn = UIButton()
        loadBtn.backgroundColor = .blue
        loadBtn.layer.cornerRadius = 5
        loadBtn.titleLabel?.font = LoadErrorMsgFont
        loadBtn.setTitle(loadBtnTitle, for: .normal)
        loadBtn.addTarget(self, action: #selector(reload(sender:)), for: .touchUpInside)
        return loadBtn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        addSubview(errorLabel)
        addSubview(loadBtn)
        
        layout()
        
        isHidden = true
        
    }
    
    @objc fileprivate func reload(sender: UIButton) {
        
        guard let deg = delegate, deg.responds(to: #selector(deg.responds(to:))) else { return }
        
        deg.reload()
    }
    
    
    fileprivate func layout() {
        
        errorLabel.snp.makeConstraints { (maker) in
            maker.left.equalTo(self.snp.left)
            maker.centerY.equalTo(self.snp.centerY).offset(-ErrorLoadBtnHeight)
            maker.right.equalTo(self.snp.right)
            maker.height.equalTo(ErrorLabelHeight)
        }
        
        loadBtn.snp.makeConstraints { (maker) in
            maker.centerX.equalTo(self.snp.centerX)
            maker.top.equalTo(errorLabel.snp.bottom)
            maker.width.equalTo(ErrorLoadBtnWidth)
            maker.height.equalTo(ErrorLoadBtnHeight)

        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK 网络UI

private let NetErrorMsgFont = UIFont.systemFont(ofSize: 13)
private let NetErrorCelluarMsg = "您当前正在使用流量,是否继续?"
private let NetErrorLostNetMsg = "您似乎已经断开了网络连接"
private let NetErrorKeepCelluarTitle = "继续播放"
private let NetErrorStopCelluarTitle = "停止播放"
private let NetErrorRefreshTitle = "刷新"


private let NetErrorLabelHeight: CGFloat = 30
private let NetErrorBtnWidth: CGFloat = 100
private let NetErrorBtnHeight: CGFloat = 30
private let NetErrorPadding: CGFloat = 10

enum NetErrorType {
    // 网络断开
    case loseNet
    // 流量播放
    case celluar
}

class VVNetErrorView: UIView {
    
    // 流量
    lazy var celluarContentView = UIView()
    lazy var errorLabel: UILabel = {
           let errorLabel = UILabel()
           errorLabel.textColor = .white
           errorLabel.textAlignment = .center
           errorLabel.font =  NetErrorMsgFont
           errorLabel.text = NetErrorCelluarMsg
           return errorLabel
    }()
    
    lazy var stopBtn: UIButton = {
          let stopBtn = UIButton()
          stopBtn.backgroundColor = .blue
          stopBtn.layer.cornerRadius = 5
          stopBtn.titleLabel?.font = NetErrorMsgFont
          stopBtn.setTitle(NetErrorStopCelluarTitle, for: .normal)
          return stopBtn
    }()
    
    lazy var keepBtn: UIButton = {
         let keepBtn = UIButton()
         keepBtn.backgroundColor = .blue
         keepBtn.layer.cornerRadius = 5
         keepBtn.titleLabel?.font = NetErrorMsgFont
         keepBtn.setTitle(NetErrorKeepCelluarTitle, for: .normal)
         return keepBtn
    }()
    
    // 无网络
    lazy var noNetContentView = UIView()
    
    lazy var noNetLabel: UILabel = {
        let noNetLabel = UILabel()
        noNetLabel.textColor = .white
        noNetLabel.textAlignment = .center
        noNetLabel.font =  NetErrorMsgFont
        noNetLabel.text = NetErrorLostNetMsg
        return noNetLabel
      }()
      
    lazy var refreshBtn: UIButton = {
        let refreshBtn = UIButton()
        refreshBtn.backgroundColor = .blue
        refreshBtn.layer.cornerRadius = 5
        refreshBtn.titleLabel?.font = NetErrorMsgFont
        refreshBtn.setTitle(NetErrorRefreshTitle, for: .normal)
        return refreshBtn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.init(white: 0, alpha: 0.8)
        isHidden = true
        
        addSubview(celluarContentView)
        celluarContentView.isUserInteractionEnabled = true
        celluarContentView.addSubview(errorLabel)
        celluarContentView.addSubview(keepBtn)
        celluarContentView.addSubview(stopBtn)
        celluarContentView.isHidden = true
        
        addSubview(noNetContentView)
        noNetContentView.isUserInteractionEnabled = true
        noNetContentView.addSubview(noNetLabel)
        noNetContentView.addSubview(refreshBtn)
        
        noNetContentView.isHidden = true
        
        layout()
    }
    
    func setType(_ type: NetErrorType) {
        if type == .loseNet {
            noNetContentView.isHidden = false
            celluarContentView.isHidden = true
        }
        
        if type == .celluar {
            noNetContentView.isHidden = true
            celluarContentView.isHidden = false
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension VVNetErrorView {
    
    private func layout() {
        
        celluarContentView.snp.makeConstraints { (maker) in
            maker.left.top.right.bottom.equalToSuperview()
        }
        
        errorLabel.snp.makeConstraints { (maker) in
            maker.left.right.equalToSuperview()
            maker.centerY.equalTo(self.snp.centerY).offset(-NetErrorBtnHeight/2)
            maker.height.equalTo(NetErrorLabelHeight)
        }
        
        stopBtn.snp.makeConstraints { (maker) in
            maker.right.equalTo(self.snp.centerX).offset(-NetErrorPadding)
            maker.top.equalTo(errorLabel.snp.bottom)
            maker.width.equalTo(NetErrorBtnWidth)
            maker.height.equalTo(NetErrorBtnHeight)
        }
        
        keepBtn.snp.makeConstraints { (maker) in
            maker.left.equalTo(self.snp.centerX).offset(NetErrorPadding)
            maker.top.equalTo(errorLabel.snp.bottom)
            maker.width.equalTo(NetErrorBtnWidth)
            maker.height.equalTo(NetErrorBtnHeight)
        }
        
        noNetContentView.snp.makeConstraints { (maker) in
            maker.left.top.right.bottom.equalToSuperview()
        }
        
        noNetLabel.snp.makeConstraints { (maker) in
            maker.left.right.equalToSuperview()
            maker.centerY.equalTo(self.snp.centerY).offset(-NetErrorBtnHeight/2)
            maker.height.equalTo(NetErrorLabelHeight)
        }
        
        refreshBtn.snp.makeConstraints { (maker) in
            maker.top.equalTo(noNetLabel.snp.bottom)
            maker.centerX.equalTo(self.snp.centerX)
            maker.width.equalTo(NetErrorBtnWidth)
            maker.height.equalTo(NetErrorBtnHeight)
        }
    }
}
