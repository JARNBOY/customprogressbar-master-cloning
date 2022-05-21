//Created by Real Life Swift on 16/02/2019

import UIKit

class ProgressBar: UIView {
  
  @IBInspectable public lazy var backgroundCircleColor: UIColor = UIColor.lightGray
  @IBInspectable public lazy var foregroundCircleColor: UIColor = UIColor.red
  @IBInspectable public lazy var startGradientColor: UIColor = UIColor.red
  @IBInspectable public lazy var endGradientColor: UIColor = UIColor.orange
  @IBInspectable public lazy var textColor: UIColor = UIColor.white
    @IBInspectable public lazy var openAngleFilterHalfProgress: Bool = false
  private lazy var fillColor: UIColor = UIColor.clear
  
  private var backgroundLayer: CAShapeLayer!
  private var progressLayer: CAShapeLayer!
  private var textLayer: CATextLayer!
  
  public var progress: CGFloat = 0 {
    didSet {
      didProgressUpdated()
    }
  }
  
  public var animationDidStarted: (()->())?
  public var animationDidCanceled: (()->())?
  public var animationDidStopped: (()->())?
  
  private var timer: AppTimer?
  private var isAnimating = false
  private let tickInterval = 0.1
  
  public var maxDuration: Int = 3
  
  
  override func draw(_ rect: CGRect) {
    
    guard layer.sublayers == nil else {
      return
    }
    
    let lineWidth = min(frame.size.width, frame.size.height) * 0.1
    
      if openAngleFilterHalfProgress{
          backgroundLayer = createHalfAngleCircularLayer(strokeColor: backgroundCircleColor.cgColor, fillColor: fillColor.cgColor, lineWidth: lineWidth)
          progressLayer = createHalfAngleCircularLayer(strokeColor: foregroundCircleColor.cgColor, fillColor: fillColor.cgColor, lineWidth: lineWidth)
      }else{
          backgroundLayer = createCircularLayer(strokeColor: backgroundCircleColor.cgColor, fillColor: fillColor.cgColor, lineWidth: lineWidth)
          progressLayer = createCircularLayer(strokeColor: foregroundCircleColor.cgColor, fillColor: fillColor.cgColor, lineWidth: lineWidth)
          
      }
    
    progressLayer.strokeEnd = progress
    
    let gradientLayer = CAGradientLayer()
    gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.5)
    gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.5)
    
    gradientLayer.colors = [startGradientColor.cgColor, endGradientColor.cgColor]
    gradientLayer.frame = self.bounds
    gradientLayer.mask = progressLayer
 
    textLayer = createTextLayer(textColor: textColor)
    
    layer.addSublayer(backgroundLayer)
    layer.addSublayer(gradientLayer)
    layer.addSublayer(textLayer)
  }
  
  private func createCircularLayer(strokeColor: CGColor, fillColor: CGColor, lineWidth: CGFloat) -> CAShapeLayer {
    
    let startAngle = -CGFloat.pi / 2
    let endAngle = 2 * CGFloat.pi + startAngle
    
    let width = frame.size.width
    let height = frame.size.height
    
    let center = CGPoint(x: width / 2, y: height / 2)
    let radius = (min(width, height) - lineWidth) / 2
    
    let circularPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
    
    let shapeLayer = CAShapeLayer()
    
    shapeLayer.path = circularPath.cgPath
    
    shapeLayer.strokeColor = strokeColor
    shapeLayer.lineWidth = lineWidth
    shapeLayer.fillColor = fillColor
    shapeLayer.lineCap = .round
    
    return shapeLayer
  }
    
    private func createHalfAngleCircularLayer(strokeColor: CGColor, fillColor: CGColor, lineWidth: CGFloat) -> CAShapeLayer {
        
        let progressAngle = 1.3
        let startAngle:CGFloat = (-CGFloat.pi / 2 ) - (progressAngle * 1.6)
        let endAngle:CGFloat = progressAngle * CGFloat.pi + startAngle
        
        let width = frame.size.width
        let height = frame.size.height
        
        let center = CGPoint(x: width / 2, y: height / 2)
        let radius = (min(width, height) - lineWidth) / 2
        
        print("startAngle : \(startAngle) , \(endAngle) , \(radius)")
        let circularPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        
        shapeLayer.path = circularPath.cgPath
        
        shapeLayer.strokeColor = strokeColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.fillColor = fillColor
        shapeLayer.lineCap = .round
        
        return shapeLayer
    }
  
  private func createTextLayer(textColor: UIColor) -> CATextLayer {
    
    let width = frame.size.width
    let height = frame.size.height
    
    let fontSize = min(width, height) / 4 - 5
    let offset = min(width, height) * 0.1
    
    let layer = CATextLayer()
    layer.string = "\(Int(progress * 100))"
    layer.backgroundColor = UIColor.clear.cgColor
    layer.foregroundColor = textColor.cgColor
    layer.fontSize = fontSize
    layer.frame = CGRect(x: 0, y: (height - fontSize - offset) / 2, width: width, height: height)
    layer.alignmentMode = .center
    
    return layer
  }
  
  private func didProgressUpdated() {
    
    textLayer?.string = "\(Int(progress * 100))"
    progressLayer?.strokeEnd = progress
  }
}

// Animation

extension ProgressBar {
  
  func startAnimation(duration: TimeInterval) {
    
    print("Start animation")
    isAnimating = true
    
    progressLayer.removeAllAnimations()
    
    let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
    basicAnimation.duration = duration
    basicAnimation.toValue = progress
    
    basicAnimation.delegate = self
    
    timer = AppTimer(duration: maxDuration, tickInterval: tickInterval)
    
    timer?.timerFired = { [weak self] value in
      self?.textLayer.string = "\(value)"
    }
    
    timer?.timerStopped = { [weak self] in
      self?.textLayer.string = ""
    }
    
    timer?.timerCompleted = {}
    
    progressLayer.add(basicAnimation, forKey: "recording")
    timer?.start()
  }
  
  func stopAnimation() {
    timer?.stop()
    progressLayer.removeAllAnimations()
  }
  
}

extension ProgressBar: CAAnimationDelegate {
  
  func animationDidStart(_ anim: CAAnimation) {
    animationDidStarted?()
  }
  
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    isAnimating = false
    flag ? animationDidStopped?() : animationDidCanceled?()
  }
  
}
