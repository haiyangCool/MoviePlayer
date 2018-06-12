//
//  DispatchQueue+Extension.swift
//  HYMoviePlayer
//
//  Created by hyw on 2018/5/9.
//  Copyright © 2018年 王海洋. All rights reserved.
//
/** 处理延时任务
    取消延时任务
 */
import Foundation
import UIKit

extension DispatchQueue {
    
    typealias Task = (_ cancel: Bool) -> Void
    func delayRun(_ time: TimeInterval, task: @escaping ()->()) -> Task? {
        
        func dispatch_later(_ block: @escaping ()->()) {
            let t = DispatchTime.now() + time
            self.asyncAfter(deadline: t, execute: block)
        }
        
        var closure: (()->Void)? = task
        var result: Task?
        
        let delayedClosure: Task = { cancel in
            if let internalClosure = closure {
                if cancel == false {
                    self.async(execute: internalClosure)
                }
            }
            closure = nil
            result = nil
        }
        
        result = delayedClosure
        
        dispatch_later {
            if let delayedClosure = result {
                delayedClosure(false)
            }
        }
        
        return result
    }
    
    func cancel(_ task: Task?) {
        task?(true)
    }
}
