//
//  ExpandAnimateButton.swift
//  SlideAuthorizon
//
//  Created by lotawei on 2018/1/31.
//  Copyright © 2018年 lotawei. All rights reserved.
//

import Foundation
import UIKit
import  QuartzCore
let ButtonPadding:CGFloat = 100

class AnimationDelegate: NSObject, CAAnimationDelegate {
    
    fileprivate let completion: () -> Void
    
    init(completion: @escaping () -> Void) {
        self.completion = completion
    }
    
    func animationDidStop(_: CAAnimation, finished: Bool) {
        completion()
    }
}

extension UIView {
    
    func animateCircular(withDuration duration: TimeInterval, center: CGPoint, revert: Bool = false, animations: () -> Void, completion: ((Bool) -> Void)? = nil) {
        let snapshot = snapshotView(afterScreenUpdates: false)!
        snapshot.frame = bounds
        self.addSubview(snapshot)
        
        let center = convert(center, to: snapshot)
        let radius: CGFloat = {
            let x = max(center.x, frame.width - center.x)
            let y = max(center.y, frame.height - center.y)
            return sqrt(x * x + y * y)
        }()
        var animation : CircularRevealAnimator
        if !revert {
            animation = CircularRevealAnimator(layer: snapshot.layer, center: center, startRadius: 0, endRadius: radius, invert: true)
        } else {
            animation = CircularRevealAnimator(layer: snapshot.layer, center: center, startRadius: radius, endRadius: 0, invert: false)
        }
        animation.duration = duration
        animation.completion = {
            snapshot.removeFromSuperview()
            completion?(true)
        }
        animation.start()
        animations()
    }
}
private func SquareAroundCircle(_ center: CGPoint, radius: CGFloat) -> CGRect {
    assert(0 <= radius, "请修改你的半径，它不能为0")
    return CGRect(origin: center, size: CGSize.zero).insetBy(dx: -radius, dy: -radius)
}
class CircularRevealAnimator {
    
    var completion: (() -> Void)?
    
    fileprivate let layer: CALayer
    fileprivate let mask: CAShapeLayer
    fileprivate let animation: CABasicAnimation
    
    var duration: CFTimeInterval {
        get { return animation.duration }
        set(value) { animation.duration = value }
    }
    
    var timingFunction: CAMediaTimingFunction! {
        get { return animation.timingFunction }
        set(value) { animation.timingFunction = value }
    }
    
    init(layer: CALayer, center: CGPoint, startRadius: CGFloat, endRadius: CGFloat, invert: Bool = false) {
        let startCirclePath = CGPath(ellipseIn: SquareAroundCircle(center, radius: startRadius), transform: nil)
        let endCirclePath = CGPath(ellipseIn: SquareAroundCircle(center, radius: endRadius), transform: nil)
        
        var startPath = startCirclePath, endPath = endCirclePath
        if invert {
            var path = CGMutablePath()
            path.addRect(layer.bounds)
            path.addPath(startCirclePath)
            startPath = path
            path = CGMutablePath()
            path.addRect(layer.bounds)
            path.addPath(endCirclePath)
            endPath = path
        }
        
        self.layer = layer
        
        mask = CAShapeLayer()
        mask.path = endPath
        mask.fillRule = kCAFillRuleEvenOdd
        
        animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = startPath
        animation.toValue = endPath
        animation.delegate = AnimationDelegate {
            layer.mask = nil
            self.completion?()
            self.animation.delegate = nil
        }
    }
    
    func start() {
        layer.mask = mask
        mask.frame = layer.bounds
        mask.add(animation, forKey: "reveal")
    }
}

@IBDesignable class ExpandAnimateButton: UIButton {
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + ButtonPadding, height: size.height)
    }
    
    func animateTouchUpInside(completion: @escaping () -> Void) {
        isUserInteractionEnabled = false
        layer.masksToBounds = true
        
        let fillLayer = CALayer()
        fillLayer.backgroundColor = layer.borderColor
        fillLayer.frame = layer.bounds
        layer.insertSublayer(fillLayer, at: 0)
        
        let center = CGPoint(x: fillLayer.bounds.midX, y: fillLayer.bounds.midY)
        let radius: CGFloat = max(frame.width / 2 , frame.height / 2)
        
        let circularAnimation = CircularRevealAnimator(layer: fillLayer, center: center, startRadius: 0, endRadius: radius)
        circularAnimation.duration = 0.2
        circularAnimation.completion = {
            fillLayer.opacity = 0
            let opacityAnimation = CABasicAnimation(keyPath: "opacity")
            opacityAnimation.fromValue = 1
            opacityAnimation.toValue = 0
            opacityAnimation.duration = 0.2
            opacityAnimation.delegate = AnimationDelegate {
                fillLayer.removeFromSuperlayer()
                self.isUserInteractionEnabled = true
                completion()
            }
            fillLayer.add(opacityAnimation, forKey: "opacity")
        }
        circularAnimation.start()
    }
}
