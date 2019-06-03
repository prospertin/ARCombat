//
//  YawSlider.swift
//  ARCombat
//
//  Created by Thinh Nguyen on 5/27/19.
//  Copyright © 2019 Prospertin. All rights reserved.
//

import UIKit

class YawSliderOld: UIControl {
    var minimumValue:CGFloat = 0
    var maximumValue:CGFloat = 1
    
    var currentValue:CGFloat = 0.5
    var yawValue:CGFloat {
        return currentValue - 0.5 // 0.5 <=> 0 
    }
    var thumbImage = #imageLiteral(resourceName: "pedal")
    
    private let trackLayer = CALayer()
    private let thumbImageView = UIImageView()
    private var previousLocation = CGPoint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        trackLayer.backgroundColor = UIColor.white.cgColor
        layer.addSublayer(trackLayer)
        
        thumbImageView.image = thumbImage
        addSubview(thumbImageView)
        updateLayerFrames()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayerFrames()
    }
    
    private func updateLayerFrames() {
        trackLayer.frame = bounds.insetBy(dx: 0.0, dy: bounds.height / 3)
        trackLayer.setNeedsDisplay()
        thumbImageView.frame = CGRect(origin: thumbOriginForValue(currentValue), size: thumbImage.size)
    }

    func positionForValue(_ value: CGFloat) -> CGFloat {
        return bounds.width * value
    }

    private func thumbOriginForValue(_ value: CGFloat) -> CGPoint {
        let x = positionForValue(value) - thumbImage.size.width / 2.0
        return CGPoint(x: x, y: (bounds.height - thumbImage.size.height) / 2.0)
    }
}

extension YawSliderOld {
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previousLocation = touch.location(in: self)
        
        if thumbImageView.frame.contains(previousLocation) {
            thumbImageView.isHighlighted = true
        }
        
        return thumbImageView.isHighlighted
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        let deltaX = location.x - previousLocation.x
        let deltaValue = deltaX/bounds.width
        previousLocation = location
        currentValue = boundedValue(value: currentValue, delta: deltaValue)
        // 3
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        updateLayerFrames()
        
        CATransaction.commit()
        // Notifiy target of changes. We use the target-action pattern because we UIControl which already supports it.
        // No reason to use Notification or React pattern here
        sendActions(for: .valueChanged)
        
        return true
    }

    private func boundedValue(value: CGFloat, delta: CGFloat) -> CGFloat {
        return max(min(maximumValue, value + delta), minimumValue)
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        thumbImageView.isHighlighted = false
        currentValue = 0.5
        sendActions(for: .valueChanged)
        updateLayerFrames()
    }
    
}
