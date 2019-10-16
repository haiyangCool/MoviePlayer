//
//  VVPlayerView+TimeLine.swift
//  VVPlayer
//
//  Created by 王海洋 on 2018/10/16.
//  Copyright © 2019 王海洋. All rights reserved.
//

import Foundation
import UIKit
// 值 可提供外部访问
private var PlaybackTimeKey: Void?
private var ProgressKey: Void?
private var BufferKey: Void?
private var DurationKey: Void?

extension VVPlayerView {
    
    func timeLineExtension() {
        player.timeLine = self
        coverView.timelineAction = self
    }
}

// MARK: 播放器时间线UI Action
extension VVPlayerView: VVPlayerTimeLineAction {
    
    func progressAtRealtime(_ coverView: VVPlayerCoverView, progress: Float) {
        player.seekToProgress(progress)
        coverView.showLoading()
    }
    
    func progressLastChanged(_ coverView: VVPlayerCoverView, progress: Float) {
        player.seekToProgress(progress)
        
    }
}
// MARK: 播放器时间线状态
extension VVPlayerView: VVPlayerTimeLine {
    
    func vvPlayer(_ player: VVPlayerProtocol, duration: Double) {
        self.duration = duration
        coverView.setDurationTime(timeFormatter(time: duration))
    
    }
    
    func vvPlayer(_ player: VVPlayerProtocol, playbackTime time: Double) {
        self.playbackTime = time
        coverView.setPlaybackTime(timeFormatter(time: time))
    }
    
    func vvplayer(_ player: VVPlayerProtocol, playProgress progress: Double) {
        self.progress = Float(progress)
        coverView.setProgress(Float(progress))
    }
    
    func vvPlayer(_ player: VVPlayerProtocol, bufferProgress progress: Double) {
        self.buffer = Float(progress)
        coverView.setBuffer(Float(progress))
    }
}

extension VVPlayerView {
    
    /// 时间格式
    private func timeFormatter(time:Float64) -> String {
           let Min = lrint(time / 60)
           let Sec = lrint(time.truncatingRemainder(dividingBy: 60))
           return String(format: "%02d:%02d", Min, Sec)
    }
}
// Add Store Property
extension VVPlayerView {
    
 
    private(set) var duration: Double {
        
        get {
            let value = objc_getAssociatedObject(self, &DurationKey) as? Double
            if let value = value {
                return value
            }
    
            return 0

        }
        
        set {
            objc_setAssociatedObject(self, &DurationKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
   private(set) var playbackTime: Double {
        
        get {
            
            let value = objc_getAssociatedObject(self, &PlaybackTimeKey) as? Double
            if let value = value {
                return value
            }
            return 0
       }
       
        set {
            objc_setAssociatedObject(self, &PlaybackTimeKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    private(set) var progress: Float {
        
         get {
             
             let value = objc_getAssociatedObject(self, &ProgressKey) as? Float
             if let value = value {
                 return value
             }
             return 0
        }
        
         set {
             objc_setAssociatedObject(self, &ProgressKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
         }
    }
    
    private(set) var buffer: Float {
         get {
             
             let value = objc_getAssociatedObject(self, &BufferKey) as? Float
             if let value = value {
                 return value
             }
             return 0
        }
        
         set {
             objc_setAssociatedObject(self, &BufferKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
         }
    }
    
    
    
    
}
