//
//  AircraftController
//

import SpriteKit

//MARK: - JoystickComponent
open class JoystickComponent: SKSpriteNode {
    private var kvoContext = UInt8(1)
    
    var offsetPosition = CGPoint(x: 100, y: 0)
    
    var borderWidth = CGFloat(0) {
        didSet {
            redrawTexture()
        }
    }

    var borderColor = UIColor.black {
        didSet {
            redrawTexture()
        }
    }

    var image: UIImage? {
        didSet {
            redrawTexture()
        }
    }

    var diameter: CGFloat {
        get {
            return max(size.width, size.height)
        }

        set(newSize) {
            size = CGSize(width: newSize, height: newSize)
        }
    }

    var radius: CGFloat {
        get {
            return diameter * 0.5
        }

        set(newRadius) {
            diameter = newRadius * 2
        }
    }

    //MARK: - DESIGNATED
    init(diameter: CGFloat, color: UIColor? = nil, image: UIImage? = nil, position: CGPoint? = CGPoint(x: 100, y: 0)) {
        super.init(texture: nil, color: color ?? UIColor.black, size: CGSize(width: diameter, height: diameter))
        addObserver(self, forKeyPath: "color", options: NSKeyValueObservingOptions.old, context: &kvoContext)
        if let pos = position {
            offsetPosition = pos
            self.position = pos
        }
        self.diameter = diameter
        self.image = image
        redrawTexture()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        removeObserver(self, forKeyPath: "color")
    }

    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        redrawTexture()
    }

    private func redrawTexture() {

        guard diameter > 0 else {
            print("Diameter should be more than zero")
            texture = nil
            return
        }

        let scale = UIScreen.main.scale
        let needSize = CGSize(width: self.diameter, height: self.diameter)
        UIGraphicsBeginImageContextWithOptions(needSize, false, scale)
        let rectPath = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero, size: needSize))
        rectPath.addClip()

        if let img = image {
            img.draw(in: CGRect(origin: CGPoint.zero, size: needSize), blendMode: .normal, alpha: 1)
        } else {
            color.set()
            rectPath.fill()
        }

        let needImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        texture = SKTexture(image: needImage)
    }
}

//MARK: - JoystickBase
open class JoystickBase: JoystickComponent {
}

//MARK: - JoystickStick
open class JoystickStick: JoystickComponent {
}

//MARK: - YawTrack
open class YawTrack: SKSpriteNode {
    
    var offsetPosition = CGPoint(x: -75, y: 25)
    
    init(position: CGPoint? = CGPoint(x: -75, y: 25), color: UIColor?) {
        super.init(texture: nil, color: color ?? UIColor.lightGray, size: CGSize(width: 100, height: 10))
        if let pos = position {
            offsetPosition = pos
            self.position = pos
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Yaw Slider
open class YawSlider: SKSpriteNode {
    
    var offsetPosition = CGPoint(x: -75, y: 25)
    
    var image: UIImage? {
        didSet {
            redrawTexture()
        }
    }
    
    init(image: UIImage?, width: CGFloat, height: CGFloat, position: CGPoint? = CGPoint(x: -75, y: 25)) {
        super.init(texture: nil, color: UIColor.black, size: CGSize(width: width, height: height))
        if let pos = position {
            offsetPosition = pos
            self.position = pos
        }
        self.image = image
        redrawTexture()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func redrawTexture() {
        let scale = UIScreen.main.scale
        let needSize = CGSize(width: self.size.width, height: self.size.height)
        UIGraphicsBeginImageContextWithOptions(needSize, false, scale)
        let rectPath = UIBezierPath(rect: CGRect(origin: CGPoint.zero, size: needSize))
        rectPath.addClip()

        if let img = image {
            img.draw(in: CGRect(origin: CGPoint.zero, size: needSize), blendMode: .normal, alpha: 1)
        } else {
            color.set()
            rectPath.fill()
        }
        
        let needImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        texture = SKTexture(image: needImage)
    }
    
}

//MARK: - AircraftController
open class AircraftController: SKNode {
    var trackingHandler: ((ControlModel) -> ())?
    var beginHandler: (() -> Void)?
    var stopRoratingHandler: (() -> Void)?
    var stickBase: JoystickBase!
    var stick: JoystickStick!
    var yawSlider: YawSlider!
    var yawTrack: YawTrack!
    
    private var stickTracking = false
    private var yawTracking = false
    private(set) var controlData = ControlModel()
    
    var disabled: Bool {
        get {
            return !isUserInteractionEnabled
        }
        
        set(isDisabled) {
            isUserInteractionEnabled = !isDisabled
            
            if isDisabled {
                resetStick()
            }
        }
    }
    
    var diameter: CGFloat {
        get {
            return stickBase.diameter
        }
        
        set(newDiameter) {
            stick.diameter += newDiameter - diameter
            stickBase.diameter = newDiameter
        }
    }
    
    var radius: CGFloat {
        get {
            return diameter * 0.5
        }
        
        set(newRadius) {
            diameter = newRadius * 2
        }
    }
    
    init(stickBase: JoystickBase, stick: JoystickStick, yawSlider: YawSlider, yawTrack: YawTrack) {
        super.init()
        self.stickBase = stickBase
        stickBase.zPosition = 0
        addChild(stickBase)
        self.stick = stick
        stick.zPosition = stickBase.zPosition + 1
        addChild(stick)
        disabled = false
        
        self.yawTrack = yawTrack
        addChild(yawTrack)
        self.yawSlider = yawSlider
        yawSlider.zPosition = stick.zPosition + 1
        //CGPoint(x:-75, y: stickBase.radius/2)
        addChild(yawSlider)
        let velocityLoop = CADisplayLink(target: self, selector: #selector(listen))
        velocityLoop.add(to: RunLoop.current, forMode: RunLoop.Mode(rawValue: RunLoop.Mode.common.rawValue))
    }
    
    convenience init(widths: (stickBase: CGFloat, stick: CGFloat?, yawSlider: CGFloat?, yawTrack: CGFloat?),
                     colors: (stickBase: UIColor?, stick: UIColor?, yawSlider: UIColor?, yawTrack: UIColor?)? = nil,
                     images: (stickBase: UIImage?, stick: UIImage?, yawSlider: UIImage?)? = nil,
                     positions: (stickBase: CGPoint?, stick: CGPoint?, yawSlider: CGPoint?, yawTrack: CGPoint?)? = nil) {
        let stickDiameter = widths.stick ?? widths.stickBase * 0.6
        let yawTrackWidth = widths.yawTrack ?? widths.stickBase
        let yawWidth = widths.yawSlider ?? yawTrackWidth * 0.2
        let yawHeight = yawWidth * 2.0
        
        let jColors = colors ?? (stickBase: nil, stick: nil, yawSlider: nil, yawTrack: nil)
        let jImages = images ?? (stickBase: nil, stick: nil, yawSlider: nil)
        let jPositions = positions ?? (stickBase: nil, stick: nil, yawSlider: nil, yawTrack: nil)
        
        let stickBase = JoystickBase(diameter: widths.stickBase,
                                            color: jColors.stickBase,
                                            image: jImages.stickBase,
                                            position: jPositions.stickBase)
        let stick = JoystickStick(diameter: stickDiameter,
                                    color: jColors.stick,
                                    image: jImages.stick,
                                    position: jPositions.stick)
        let yawSlider = YawSlider(image: jImages.yawSlider,
                                    width: yawWidth,
                                    height: yawHeight,
                                    position: jPositions.yawSlider)
        let yawTrack = YawTrack(position: jPositions.yawTrack, color: jColors.yawTrack)
        self.init(stickBase: stickBase, stick: stick, yawSlider: yawSlider, yawTrack: yawTrack)
    }
    
    convenience init(width: CGFloat,
                     colors: (stickBase: UIColor?, stick: UIColor?, yawSlider: UIColor?, yawTrack: UIColor?)? = nil,
                     images: (stickBase: UIImage?, stick: UIImage?, yawSlider: UIImage?)? = nil,
                     positions: (stickBase: CGPoint?, stick: CGPoint?, yawSlider: CGPoint?, yawTrack: CGPoint?)? = nil) {
        let jWidths:(stickBase: CGFloat, stick: CGFloat?, yawSlider: CGFloat?, yawTrack: CGFloat?) =
            (stickBase: width/3, stick: width/3 * 0.6, yawSlider: width/3 * 0.3, yawTrack: width/3)
        let jPositions = positions ?? (stickBase: CGPoint(x: width/3, y: 0),
                                       stick: CGPoint(x: width/3, y: 0),
                                       yawSlider: CGPoint(x: -width/3, y: 0),
                                       yawTrack: CGPoint(x: -width/3, y: 0))

        self.init(widths: jWidths,
                  colors: colors,
                  images: images,
                  positions: jPositions)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func listen() {
        if stickTracking || yawTracking {
            trackingHandler?(controlData)
        }
    }
    
    //MARK: - Overrides
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            switch atPoint(touch.location(in: self)) {
            case stick:
                stickTracking = true
            case yawSlider:
                yawTracking = true
            default:
                return
            }
        }
       
        beginHandler?()
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            
            switch atPoint(location) {
            case stick:
                guard stickTracking else {
                    return
                }
                let maxDistance = stickBase.radius
                let realDistance = sqrt(pow(location.x - stick.offsetPosition.x, 2) + pow(location.y - stick.offsetPosition.y, 2))
                debugPrint("Max: \(maxDistance), Real: \(realDistance)")
                if realDistance <= maxDistance {
                    stick.position = CGPoint(x: location.x, y: location.y)
                } else {
                    // If distance is more than max reduce it to the max x by finding the cos/radius where cos = x/realDistance
                    let deltaX = (location.x - stick.offsetPosition.x)  / realDistance * maxDistance
                    let deltaY = (location.y - stick.offsetPosition.y)  / realDistance * maxDistance
                    let newPosition = CGPoint(x: stick.offsetPosition.x + deltaX, y: stick.offsetPosition.y + deltaY)
                    stick.position = newPosition
                }
                controlData = ControlModel(roll: stick.position.x - stick.offsetPosition.x, pitch: stick.position.y - stick.offsetPosition.y, yaw: controlData.yaw)
                debugPrint("Stick new position: \(controlData.description)")
            case yawSlider:
                guard yawTracking else {
                    return
                }
                //let maxDistance = yawTrack.size.width/2
                let x = max(yawTrack.position.x - yawTrack.size.width/2, min(location.x, yawTrack.position.x + yawTrack.size.width/2))
                yawSlider.position = CGPoint(x: x, y: yawSlider.position.y)
                controlData = ControlModel(roll: controlData.roll, pitch: controlData.pitch, yaw: x - yawTrack.position.x)
                debugPrint("Yaw new position: \(controlData.description)")
            default:
                return
            }
        }
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            
            switch atPoint(location) {
            case stick:
                debugPrint("Touch end stick")
                resetStick()
            case yawSlider:
                debugPrint("Touch end slider")
                resetSlider()
            default:
                debugPrint("Touch end somewhere else")
                return
            }
        }
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            
            switch atPoint(location) {
            case stick:
                debugPrint("Touch cancelled stick")
                resetStick()
            case yawSlider:
                debugPrint("Touch cancelled slider")
                resetSlider()
            default:
                debugPrint("Touch cancelled something else")
                return
            }
        }
    }
    
    public func reset() {
        resetStick()
        resetSlider()
    }
    
    // private methods
    private func resetStick() {
        stickTracking = false
        let moveToBack = SKAction.move(to: stick.offsetPosition, duration: TimeInterval(0.1))
        moveToBack.timingMode = .easeOut
        stick.run(moveToBack)
        controlData.resetStick()
        stopRoratingHandler?();//stop rotation but keep moving forward
        debugPrint("Reset Stick position: \(controlData.description)")

    }
    
    private func resetSlider() {
        yawTracking = false
        let moveToBack = SKAction.move(to: yawSlider.offsetPosition, duration: TimeInterval(0.1))
        moveToBack.timingMode = .easeOut
        yawSlider.run(moveToBack)
        controlData.resetYaw()
        stopRoratingHandler?();//stop rotation but keep moving forward
        debugPrint("Reset Yaw position: \(controlData.description)")
    }
}
