//
//  VVPlayerCoverView+TimeLine.swift
//  VVPlayer
//
//  Created by 王海洋 on 2018/10/15.
//  Copyright © 2019 王海洋. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
/** 时间线 UI

    播放时间   -------进度条（缓存if have）------  时长
 */
// UI 属性
private var PlaybackTimeLabelKey: Void?
private var ProgressViewKey: Void?
private var BufferViewKey: Void?
private var DurationLabelKey: Void?
private var TimelineActionKey: Void?
// Layout 参数
private let PlayBackTimePadding: CGFloat = 10
private let PlaybackTimeX: CGFloat = 60
private let PlaybackTimeWidth: CGFloat = 80
private let PlaybackTimeHeight: CGFloat = 44


@objc protocol VVPlayerTimeLineAction: NSObjectProtocol {
    /// 进度实时更新
    @objc optional func progressAtRealtime(_ coverView: VVPlayerCoverView, progress: Float)
    /// 进度不再变化后，取最近一次的值
    @objc optional func progressLastChanged(_ coverView: VVPlayerCoverView, progress: Float)
}

// MARK: 播放器时间线UI更新
extension VVPlayerCoverView {
    
    func setPlaybackTime(_ time: String) {
        playbackTimeLabel.text = time
    }
    
    func setDurationTime(_ time: String) {
        durationLabel.text = time
    }
    
    func setBuffer(_ progress: Float) {
        bufferView.progress = progress
    }
    
    func setProgress(_ value: Float) {
        progressBar.value = value
    }
}

/// TimeLine Private Action
extension VVPlayerCoverView {
    
    @objc fileprivate func valueChanged(_ sender: UISlider) {
        
        guard let delegate = timelineAction, delegate.responds(to: #selector(delegate.progressAtRealtime(_:progress:))) else { return }
        delegate.progressAtRealtime?(self, progress: sender.value)
    }
    
    @objc fileprivate func valueStopChange(_ sender: UISlider) {
        
        guard let delegate = timelineAction, delegate.responds(to: #selector(delegate.progressLastChanged(_:progress:))) else { return }
        delegate.progressLastChanged?(self, progress: sender.value)
    }
}

// add
extension VVPlayerCoverView {
    
    func addTimeLineView() {
        playbackTimeLabel = UILabel()
        playbackTimeLabel.textColor = .white
        playbackTimeLabel.textAlignment = .center
        playbackTimeLabel.font = UIFont.systemFont(ofSize: 13)
        playbackTimeLabel.text = "--:--"
        
        
        bufferView = UIProgressView()
        bufferView.progress = 0.0
        bufferView.progressTintColor = .lightGray
        bufferView.trackTintColor = UIColor.init(white: 1, alpha: 0.3)
        
        progressBar = UISlider()
        progressBar.minimumValue = 0.0
        progressBar.maximumValue = 1.0
        progressBar.minimumTrackTintColor = .green
        progressBar.maximumTrackTintColor = .lightGray
        progressBar.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
        progressBar.addTarget(self, action: #selector(valueStopChange(_:)), for: .touchUpInside)
        
        durationLabel = UILabel()
        durationLabel.textColor = .white
        durationLabel.textAlignment = .center
        durationLabel.font = UIFont.systemFont(ofSize: 13)
        durationLabel.text = "--:--"
        
        bottomPanel.addSubview(playbackTimeLabel)
        bottomPanel.addSubview(bufferView)
        bottomPanel.addSubview(progressBar)
        bottomPanel.addSubview(durationLabel)
        
        layoutTimeline()
    }
}

/// Layout
extension VVPlayerCoverView {
    
    fileprivate func layoutTimeline() {
        
        playbackTimeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left).offset(PlaybackTimeX)
            make.bottom.equalTo(self.snp.bottom).offset(-PlayBackTimePadding)
            make.width.equalTo(PlaybackTimeWidth)
            make.height.equalTo(PlaybackTimeHeight)
        }
        
        durationLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self.snp.right).offset(-PlaybackTimeX)
            make.bottom.equalTo(self.snp.bottom).offset(-PlayBackTimePadding)
            make.width.equalTo(PlaybackTimeWidth)
            make.height.equalTo(PlaybackTimeHeight)
        }
        
        bufferView.snp.makeConstraints { (make) in
            make.left.equalTo(playbackTimeLabel.snp.right)
            make.centerY.equalTo(playbackTimeLabel.snp.centerY)
            make.right.equalTo(durationLabel.snp.left)
            make.height.equalTo(PlayBackTimePadding)
        }
        
        progressBar.snp.makeConstraints { (make) in
            make.left.equalTo(playbackTimeLabel.snp.right)
            make.centerY.equalTo(playbackTimeLabel.snp.centerY)
            make.right.equalTo(durationLabel.snp.left)
            make.height.equalTo(PlayBackTimePadding)
        }
        
    }
}

/// Dynamic Property
extension VVPlayerCoverView {
    
    fileprivate var playbackTimeLabel: UILabel {
        
        get {
            let label = objc_getAssociatedObject(self, &PlaybackTimeLabelKey) as? UILabel
            if let label = label {
                return label
            }
            return UILabel()
        }
        set {
            objc_setAssociatedObject(self, &PlaybackTimeLabelKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate var bufferView: UIProgressView {
        get {
            let bufferV = objc_getAssociatedObject(self, &BufferViewKey) as? UIProgressView
            if let bufferV = bufferV {
                return bufferV
            }
            return UIProgressView()
        }
        
        set {
            objc_setAssociatedObject(self, &BufferViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate var progressBar: UISlider {
        
        get {
            let slider = objc_getAssociatedObject(self, &ProgressViewKey) as? UISlider
            if let pSlider = slider {
                return pSlider
            }
            return UISlider()
        }
        set {
            objc_setAssociatedObject(self, &ProgressViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate var durationLabel: UILabel {
        
        get {
            let label = objc_getAssociatedObject(self, &DurationLabelKey) as? UILabel
            if let label = label {
                return label
            }
            return UILabel()
        }
        set {
            objc_setAssociatedObject(self, &DurationLabelKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var timelineAction: VVPlayerTimeLineAction? {
        
        get {
            return objc_getAssociatedObject(self, &TimelineActionKey) as? VVPlayerTimeLineAction
        }
        
        set {
            objc_setAssociatedObject(self, &TimelineActionKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
}
