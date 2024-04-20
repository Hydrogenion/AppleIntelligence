//
//  GraphView.swift
//  AppleTrainer
//
//  Created by 张轩诚 on 2024/4/18.
//

import Foundation

import UIKit

/**
  A simple animated line graph. Shows the training loss.
 */
class GraphView: UIView, CAAnimationDelegate {
    let shapeLayer = CAShapeLayer()
    let xAxisLayer = CAShapeLayer()
    let yAxisLayer = CAShapeLayer()
    let xAxisLabelLayer = CATextLayer()
    let yAxisLabelLayer = CATextLayer()
        

  override func awakeFromNib() {
      super.awakeFromNib()
  
      clipsToBounds = true
  
      shapeLayer.fillColor = nil
      shapeLayer.strokeColor = UIColor.cyan.cgColor
      shapeLayer.lineWidth = 2
      shapeLayer.lineCap = .round
      shapeLayer.lineJoin = .round
      layer.addSublayer(shapeLayer)
      
      // 配置横纵坐标轴Layer
      xAxisLayer.strokeColor = UIColor.black.cgColor
      yAxisLayer.strokeColor = UIColor.black.cgColor
      
      xAxisLayer.lineWidth = 1
      yAxisLayer.lineWidth = 1
      
      layer.addSublayer(xAxisLayer)
      layer.addSublayer(yAxisLayer)
      
      // 配置坐标轴标签Layer
      configureAxisLabelLayer(xAxisLabelLayer, text: "epoch")
      configureAxisLabelLayer(yAxisLabelLayer, text: "loss")
      
      layer.addSublayer(xAxisLabelLayer)
      layer.addSublayer(yAxisLabelLayer)
      
      drawAxes()
  }

    func update() {
      let trainLoss = history.events.map { $0.trainLoss }
      draw(data: trainLoss, in: shapeLayer)
    }
  
    private func draw(data: [Double], in layer: CAShapeLayer) {
      guard data.count > 1 else {
        shapeLayer.path = nil
        return
      }
  
      let maxY = data.max()!
      let offsetX = 10.0
      let offsetY = 10.0
      let width = Double(bounds.width)
      let height = Double(bounds.height)
      let scaleX = (width  - offsetX*2) / Double(data.count - 1)
      let scaleY = (height - offsetY*2) / (maxY + 1e-5)
  
      let path = UIBezierPath()
      let point = CGPoint(x: offsetX, y: height - (offsetY + data[0] * scaleY))
      path.move(to: point)
  
      for i in 1..<data.count {
        let point = CGPoint(x: offsetX + Double(i)*scaleX, y: height - (offsetY + data[i] * scaleY))
        path.addLine(to: point)
      }
  
      if layer.path == nil {
        layer.path = path.cgPath
      } else {
        let anim = CABasicAnimation(keyPath: "path")
        anim.toValue = path.cgPath
        anim.duration = 0.3
        anim.timingFunction = CAMediaTimingFunction(name: .default)
        anim.delegate = self
        anim.isRemovedOnCompletion = false
        anim.fillMode = .forwards
        layer.add(anim, forKey: "pathAnimation")
      }
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
      shapeLayer.path = ((anim as? CABasicAnimation)?.toValue as! CGPath)
    }
    
      private func configureAxisLabelLayer(_ labelLayer: CATextLayer, text: String) {
              labelLayer.string = text
              labelLayer.foregroundColor = UIColor.black.cgColor
              labelLayer.alignmentMode = .left
              labelLayer.contentsScale = UIScreen.main.scale // Make the text sharp
              labelLayer.font = CTFontCreateWithName("HelveticaNeue" as CFString, 12, nil)
              labelLayer.fontSize = 12
          }
    
    override func layoutSubviews() {
            super.layoutSubviews()
            drawAxes()
            // 当视图大小改变时，更新坐标轴标签的位置
            let xAxisLabelPosition = CGPoint(x: bounds.width - 60, y: bounds.height - 30)
            xAxisLabelLayer.frame = CGRect(origin: xAxisLabelPosition, size: CGSize(width: 50, height: 20))
            
            let yAxisLabelPosition = CGPoint(x: 0, y: 20)
            yAxisLabelLayer.frame = CGRect(origin: yAxisLabelPosition, size: CGSize(width: 50, height: 20))
        }
    
    func drawAxes() {
            // 绘制坐标轴
            let xAxisPath = UIBezierPath()
            let yAxisPath = UIBezierPath()
            
            let xAxisStartPoint = CGPoint(x: 0, y: bounds.height - 20)
            let xAxisEndPoint = CGPoint(x: bounds.width, y: bounds.height - 20)
            
            let yAxisStartPoint = CGPoint(x: 20, y: bounds.height)
            let yAxisEndPoint = CGPoint(x: 20, y: 0)
            
            xAxisPath.move(to: xAxisStartPoint)
            xAxisPath.addLine(to: xAxisEndPoint)
            
            yAxisPath.move(to: yAxisStartPoint)
            yAxisPath.addLine(to: yAxisEndPoint)
            
            xAxisLayer.path = xAxisPath.cgPath
            yAxisLayer.path = yAxisPath.cgPath
        }
}
