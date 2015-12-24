//
//  FoldingCell.swift
//  FoldingCell
//
//  Created by Alex K. on 21/12/15.
//  Copyright © 2015 Alex K. All rights reserved.
//

import UIKit

class FoldingCell: UITableViewCell {
    
    @IBOutlet weak var foregroundTop: NSLayoutConstraint!
    @IBOutlet weak var contanerTop: NSLayoutConstraint!
    
    @IBOutlet weak var contanerView: UIView!
    @IBOutlet weak var firstContanerView: UIView!
    @IBOutlet weak var foregroundView: RotatedView!
    // PRAGMA:  life cicle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureDefaultState()
    }

    // PRAGMA: configure
    
    func configureDefaultState() {
        contanerTop.constant = foregroundTop.constant
        contanerView.alpha = 0;
        
        firstContanerView.layer.cornerRadius = 10
      
        foregroundView.layer.anchorPoint = CGPoint.init(x: 0.5, y: 1)
        foregroundTop.constant += foregroundView.bounds.height / 2

        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        
        foregroundView.layer.transform = foregroundView.transform3d()
        
        // elements view
        
        for constraint in contanerView.constraints {
            if constraint.identifier == "custom" {
                constraint.constant -= constraint.firstItem.bounds.height / 2
                constraint.firstItem.layer.anchorPoint = CGPoint.init(x: 0.5, y: 0)
                constraint.firstItem.layer.transform = constraint.firstItem.transform3d()
            }
        }
        
        
        // added back view
        var previusView: RotatedView?
        for contener in contanerView.subviews.sort({ $0.tag < $1.tag }) {
            if contener is RotatedView && contener.tag > 0 && contener.tag < contanerView.subviews.count {
                let rotatedView = contener as! RotatedView
                previusView?.addBackView(rotatedView.bounds.size.height)
                previusView = rotatedView
            }
        }
    }
    
    // PRAGMA: public
    
    func selectedAnimation(isSelected: Bool, animated: Bool) {
        if isSelected {
            contanerView.alpha = 1;
            for subview in contanerView.subviews {
                subview.alpha = 1
            }

            if animated {
                openAnimation()
            } else {
                foregroundView.alpha = 0
                for subview in contanerView.subviews {
                    if subview is RotatedView {
                        let rotateView = subview as! RotatedView
                        rotateView.backView?.alpha = 0
                    }
                }
            }
        } else {
            if animated {
                closeAnimation()
            } else {
                foregroundView.alpha = 1;
                contanerView.alpha = 0;
            }
        }
    }
    
    // PRAGMA: animations
    
    func openAnimation() {
        
        let animationInfo:[(type: String, duration: NSTimeInterval, delay: NSTimeInterval)] = [
                                                                 (kCAMediaTimingFunctionEaseIn, 0.165, 0), // folding open
                                                                 (kCAMediaTimingFunctionEaseOut, 0.165, 0.165),
            
                                                                 (kCAMediaTimingFunctionEaseIn, 0.13, 0.33),
                                                                 (kCAMediaTimingFunctionEaseOut, 0.13, 0.46),
            
                                                                 (kCAMediaTimingFunctionEaseIn, 0.13, 0.59),
                                                                 (kCAMediaTimingFunctionEaseOut, 0.13, 0.72),
                                                                ]
        
        
        foregroundView.foldingAnimation(animationInfo[0].type, from: 0, to: CGFloat(-M_PI / 2), duration: animationInfo[0].duration, delay:animationInfo[0].delay, hidden: true)
        
        firstContanerView.layer.masksToBounds = true
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(animationInfo[0].duration * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            self.firstContanerView.layer.masksToBounds = false
        }
        
        var index = 1
        for itemView in contanerView.subviews.sort({ $0.tag < $1.tag }) {

            if itemView is RotatedView {
                let rotatedView: RotatedView = itemView as! RotatedView
                rotatedView.alpha = 0;
                if index < animationInfo.count {
                    rotatedView.foldingAnimation(animationInfo[index].type,
                                                from: CGFloat(M_PI / 2),
                                                to: 0,
                                                duration:
                                                animationInfo[index].duration,
                                                delay:animationInfo[index].delay,
                                                hidden:false)
                }
                if index+1 < animationInfo.count {
                    rotatedView.backView?.foldingAnimation(animationInfo[index + 1].type,
                                                from: 0,
                                                to: CGFloat(-M_PI / 2),
                                                duration: animationInfo[index+1].duration,
                                                delay: animationInfo[index+1].delay,
                                                hidden:true)
                }
                index += 2
            }
        }
    }
    
    func closeAnimation() {
        
        let animationInfo:[(type: String, duration: NSTimeInterval, delay: NSTimeInterval)] = [
            (kCAMediaTimingFunctionEaseIn, 0.13, 0),
            (kCAMediaTimingFunctionEaseOut, 0.13, 0.13),
            
            (kCAMediaTimingFunctionEaseIn, 0.13, 0.26),
            (kCAMediaTimingFunctionEaseOut, 0.13, 0.39),

            (kCAMediaTimingFunctionEaseIn, 0.165, 0.52), // folding open
            (kCAMediaTimingFunctionEaseOut, 0.165, 0.685),
            ]
    
        var index = 0
        for itemView in contanerView.subviews.sort({ $0.tag > $1.tag }) {
            if itemView is RotatedView {
                let rotatedView: RotatedView = itemView as! RotatedView
                if index < animationInfo.count {
                    rotatedView.foldingAnimation(animationInfo[index].type,
                                                        from:0,
                                                        to: CGFloat(M_PI / 2),
                                                        duration: animationInfo[index].duration,
                                                        delay:animationInfo[index].delay,
                                                        hidden:true)
                }
                
                if index - 1 > 0 {
                    rotatedView.backView?.foldingAnimation(animationInfo[index-1].type,
                                                            from: CGFloat(-M_PI / 2),
                                                            to: 0,
                                                            duration: animationInfo[index-1].duration,
                                                            delay: animationInfo[index-1].delay,
                                                            hidden: false)
                }
                
                index += 2
            }
        }
        
        foregroundView.alpha = 0
        foregroundView.foldingAnimation(animationInfo.last!.type,
                                        from: CGFloat(-M_PI / 2),
                                        to: 0,
                                        duration: animationInfo.last!.duration,
                                        delay:animationInfo.last!.delay,
                                        hidden:false)
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(animationInfo.last!.delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            self.contanerView.alpha = 0
        }
        firstContanerView.layer.masksToBounds = false
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(animationInfo[animationInfo.count - 2].delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            self.firstContanerView.layer.masksToBounds = true
        }
    }
}

class RotatedView: UIView {
    var hiddenAfterAnimation = false
    var backView: RotatedView?
    
    func addBackView(height: CGFloat) {
        let view = RotatedView(frame: CGRect.zero)
        view.backgroundColor = UIColor(red:0.97, green:0.94, blue:0.98, alpha:1)
        view.layer.anchorPoint = CGPoint.init(x: 0.5, y: 1)
        view.layer.transform = view.transform3d()
        view.translatesAutoresizingMaskIntoConstraints = false;
        self.addSubview(view)
        backView = view
        
        view.addConstraint(NSLayoutConstraint(item: view,
                                         attribute: .Height,
                                         relatedBy: .Equal,
                                            toItem: nil,
                                         attribute: .Height,
                                        multiplier: 1,
                                          constant: height))
        
        self.addConstraints([
             NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: self.bounds.size.height - height + height / 2),
             NSLayoutConstraint(item: view, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0),
             NSLayoutConstraint(item: view, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0)
        ])
    }
}


extension RotatedView {
    
    func rotatedX(angle : CGFloat) {
        var allTransofrom = CATransform3DIdentity;
        let rotateTransform = CATransform3DMakeRotation(angle, 1, 0, 0)
        allTransofrom = CATransform3DConcat(allTransofrom, rotateTransform)
        allTransofrom = CATransform3DConcat(allTransofrom, transform3d())
        self.layer.transform = allTransofrom
    }
    
    func transform3d()-> CATransform3D {
        var transform = CATransform3DIdentity
        transform.m34 = 2.5 / -2000;
        return transform
    }
    
    // PRAGMA: animations
    
    func foldingAnimation(timing: String, from: CGFloat, to: CGFloat, duration: NSTimeInterval, delay:NSTimeInterval, hidden:Bool) {
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation.x")
        rotateAnimation.timingFunction = CAMediaTimingFunction(name: timing)
        rotateAnimation.fromValue = (from)
        rotateAnimation.toValue = (to)
        rotateAnimation.duration = duration
        rotateAnimation.delegate = self;
        rotateAnimation.fillMode = kCAFillModeForwards;
        rotateAnimation.removedOnCompletion = false;
        rotateAnimation.beginTime = CACurrentMediaTime() + delay
        
        self.hiddenAfterAnimation = hidden
        
        self.layer.addAnimation(rotateAnimation, forKey: nil)
    }
    
    override func animationDidStart(anim: CAAnimation) {
        self.alpha = 1
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if hiddenAfterAnimation {
            self.alpha = 0
        }
        self.layer.removeAllAnimations()
        self.rotatedX(CGFloat(0))
    }
}
