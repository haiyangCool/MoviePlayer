//
//  HYMoviePlayerGusterResponseView.swift
//  HYMoviePlayer
//
//  Created by hyw on 2018/5/10.
//  Copyright © 2018年 王海洋. All rights reserved.
//
/**
    播放器的手势响应图层
    单击
    双击
    屏幕左边（上下滑动）控制亮度
    屏幕右边（上下滑动）控制音量
    屏幕（左右滑动）控制进度
 
 */
protocol HYMoviePlayerGusterResponseViewDelegate {
    /// 手势控制
    func hyMoviePlayerGusterResponseViewGuster(gusterView:HYMoviePlayerGusterResponseView, gusterType:HYMoviePlayerGusterType, value:Float)
}
enum HYMoviePlayerGusterType:Int {
    /// tap tyepe
    case doubletap
    case singletap
    /// move type
    case light
    case volum
    case progress
    case none
}
import UIKit

class HYMoviePlayerGusterResponseView: UIView {

    var delegate:HYMoviePlayerGusterResponseViewDelegate?
    fileprivate var moveType:HYMoviePlayerGusterType = .none
    fileprivate var startPoint:CGPoint?
    fileprivate var endPoint:CGPoint?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addGuster()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
/// System could override methods
extension HYMoviePlayerGusterResponseView {
    /// 滑动系列方法
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /// 获取滑动开始位置
        for touch in touches {
            let t:UITouch = touch
            let currentPoint = t.location(in: self)
            self.startPoint = currentPoint
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if self.startPoint == nil { return }
        var movedX:CGFloat = 0
        var movedY:CGFloat = 0
        for touch in touches {
            let t:UITouch = touch
            let currentPoint = t.location(in: self)
            
            /// 滑动距离 横向、纵向
            movedX = currentPoint.x - (self.startPoint?.x)!
            movedY = currentPoint.y - (self.startPoint?.y)!
            
            ///执行对应类型的方法
            /// 进度
            if self.moveType == .progress {
                let progress = (movedX-10)/self.bounds.size.width/2
                print("调节进度 = \(progress)")
                self.delegate?.hyMoviePlayerGusterResponseViewGuster(gusterView: self, gusterType: .progress, value: Float(progress))
            }
            /// 亮度
            if self.moveType == .light {
                let brightValue = (movedY-10)/self.bounds.size.height/2
                print("调节亮度 = \(brightValue)")
                self.delegate?.hyMoviePlayerGusterResponseViewGuster(gusterView: self, gusterType: .light, value: Float(-brightValue))
            }
            /// 音量
            if self.moveType == .volum {
                let volumValue = (movedY-10)/self.bounds.size.height*100
                 print("调节音量 = \(volumValue)")
                self.delegate?.hyMoviePlayerGusterResponseViewGuster(gusterView: self, gusterType: .volum, value: Float(-volumValue))
            }
            
            /// 判断执行哪一类型的方法
            /// 首先判断 X、Y 哪一个值首先达到峰值（用来确定接下来需要响应的是哪个方向的方法）
            /// X 首先达到峰值：则执行 进度调节
            /// Y 首先达到峰值: 再去判断 触摸在屏幕的那个区域 （左边控制亮度，右边控制音量）
            /// X、Y同时到达峰值 则 执行调节进度方法
            /// 峰值都设置为10
            if abs(movedX) >= 10 {
                self.moveType = .progress
                /// 计算 进度值
                return
            }
            
            if abs(movedY) >= 10 {
                
                if (self.startPoint?.x)! <= self.bounds.size.width/2 {
                    /// 左半边屏幕 亮度
                    self.moveType = .light
                    return
                }else {
                    /// 右半边屏幕
                    self.moveType = .volum
                    return
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.moveType = .none
        self.endPoint = CGPoint.zero
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.moveType = .none
        self.endPoint = CGPoint.zero
    }
}
/// Private methods
extension HYMoviePlayerGusterResponseView {
    /************************** 手势动作 Start***********************/
    fileprivate func addGuster() {
        
        let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(singleTapAction(tap:)))
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        self.addGestureRecognizer(singleTap)
        
        let doubleTap = UITapGestureRecognizer.init(target: self, action: #selector(doubleTapAction(tap:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.numberOfTouchesRequired = 1
        self.addGestureRecognizer(doubleTap)
        
        singleTap.require(toFail: doubleTap)
    }
    
    @objc fileprivate func singleTapAction(tap:UITapGestureRecognizer) {
        
        self.delegate?.hyMoviePlayerGusterResponseViewGuster(gusterView: self, gusterType: .singletap, value: 0)

    }
    @objc fileprivate func doubleTapAction(tap:UITapGestureRecognizer) {

        self.delegate?.hyMoviePlayerGusterResponseViewGuster(gusterView: self, gusterType: .doubletap, value: 0)
        
    }
    /*************************** 手势动作 End***********************/
}
