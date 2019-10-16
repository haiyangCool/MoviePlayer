//
//  VVPlayerCoverView.swift
//  VVPlayer
//
//  Created by 王海洋 on 2017/10/14.
//  Copyright © 2019 王海洋. All rights reserved.
//

import UIKit
// Panel layout params
let VV_CoverTopPanelHeight: CGFloat = 80.0
let VV_CoverBottomPanelHeight: CGFloat = 80.0
let VV_CoverPanelPadding: CGFloat = 10.0
/// 播放器覆盖图层，在该层进行扩展（对播放器UI控制）
class VVPlayerCoverView: UIView {
    
    lazy var topPanel = UIView()
    lazy var bottomPanel = UIView()
    
    private var initFrame = CGRect.zero
    override init(frame: CGRect) {
        super.init(frame: frame)
        initFrame = frame
        backgroundColor = .clear
        
        addLoadingView()
    
        addSubview(topPanel)
        topPanel.isUserInteractionEnabled = true
        topPanel.backgroundColor = .init(white: 0, alpha: 0.3)
        addSubview(bottomPanel)
        bottomPanel.isUserInteractionEnabled = true
        bottomPanel.backgroundColor = UIColor.init(white: 0, alpha: 0.3)
        layoutSubviewsByDefault()
        
        addControlView()
        addFullScreenView()
        addTimeLineView()
        addGusterRecognize()
        addLoadErrorView()
        addNetExceptionView()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

extension VVPlayerCoverView {
    
    fileprivate func layoutSubviewsByDefault() {
        
        topPanel.snp.makeConstraints { (maker) in
            maker.left.equalTo(self.snp.left)
            maker.top.equalTo(self.snp.top)
            maker.right.equalTo(self.snp.right)
            maker.height.equalTo(VV_CoverTopPanelHeight)
        }
        
        bottomPanel.snp.makeConstraints { (maker) in
            maker.left.equalTo(self.snp.left)
            maker.bottom.equalTo(self.snp.bottom)
            maker.right.equalTo(self.snp.right)
            maker.height.equalTo(VV_CoverBottomPanelHeight)
        }
       
    }
}
