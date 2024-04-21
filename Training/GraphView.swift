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
    
    var xAxisLabels = [CATextLayer]()
    var yAxisLabels = [CATextLayer]()
    
    let xAxisDottedLine = CAShapeLayer()
    let yAxisDottedLine = CAShapeLayer()
        

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
//      configureAxisLabelLayer(xAxisLabelLayer, text: "epoch")
//      configureAxisLabelLayer(yAxisLabelLayer, text: "loss")
      
//      layer.addSublayer(xAxisLabelLayer)
//      layer.addSublayer(yAxisLabelLayer)
      
      //绘制坐标轴
      drawAxes()
      
      configureDottedLineLayer(xAxisDottedLine, isVertical: false)
      configureDottedLineLayer(yAxisDottedLine, isVertical: true)
      
      // 把虚线层添加到视图的Layer中
      layer.addSublayer(xAxisDottedLine)
      layer.addSublayer(yAxisDottedLine)
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
      let offsetX = 30.0
      let offsetY = 30.0
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
        // 更新x轴标签
        updateXAxisLabels(for: data.count)

        // 更新y轴标签
        updateYAxisLabels(for: maxY)
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
        
            drawAxisDottedLines()
        }
    
//    func drawAxes() {
//            // 绘制坐标轴
//            let xAxisPath = UIBezierPath()
//            let yAxisPath = UIBezierPath()
//
//            let xAxisStartPoint = CGPoint(x: 30, y: bounds.height - 30)
//            let xAxisEndPoint = CGPoint(x: bounds.width, y: bounds.height - 20)
//
//            let yAxisStartPoint = CGPoint(x: 20, y: bounds.height)
//            let yAxisEndPoint = CGPoint(x: 20, y: 0)
//
//            xAxisPath.move(to: xAxisStartPoint)
//            xAxisPath.addLine(to: xAxisEndPoint)
//
//            yAxisPath.move(to: yAxisStartPoint)
//            yAxisPath.addLine(to: yAxisEndPoint)
//
//            xAxisLayer.path = xAxisPath.cgPath
//            yAxisLayer.path = yAxisPath.cgPath
//        }
    private func drawAxes() {
            // 重设坐标轴的路径以避免端点交叉，设置起始原点
            let axesOrigin = CGPoint(x: 30, y: bounds.height - 30) // 坐标轴的原点
            
            // 绘制x轴
            let xAxisPath = UIBezierPath()
            xAxisPath.move(to: axesOrigin)
            xAxisPath.addLine(to: CGPoint(x: bounds.width, y: axesOrigin.y))
            xAxisLayer.path = xAxisPath.cgPath
            
            // 绘制y轴
            let yAxisPath = UIBezierPath()
            yAxisPath.move(to: axesOrigin)
            yAxisPath.addLine(to: CGPoint(x: axesOrigin.x, y: 0))
            yAxisLayer.path = yAxisPath.cgPath
        }
    
//    private func updateXAxisLabels(for dataCount: Int) {
//            // 移除旧的x轴标签
//            xAxisLabels.forEach { $0.removeFromSuperlayer() }
//            xAxisLabels.removeAll()
//
//            let maxLabelCount = min(dataCount, 10) // 限制最多显示10个标签
//            for i in 0..<maxLabelCount {
//                let xPosition = bounds.width * CGFloat(i) / CGFloat(maxLabelCount)
//                let text = "\(i * (dataCount / maxLabelCount))"
//                let labelLayer = createLabelLayer(with: text, at: CGPoint(x: xPosition, y: bounds.height - 30))
//                xAxisLabels.append(labelLayer)
//            }
//        }
//
//        private func updateYAxisLabels(for maxValue: Double) {
//            // 移除旧的y轴标签
//            yAxisLabels.forEach { $0.removeFromSuperlayer() }
//            yAxisLabels.removeAll()
//
//            let labelCount = 10 // 按需设置y轴标签数量
//            for i in 0..<labelCount {
//                let yPosition = bounds.height - (bounds.height * CGFloat(i) / CGFloat(labelCount))
//                let text = String(format: "%.2f", (maxValue / Double(labelCount)) * Double(i))
//                let labelLayer = createLabelLayer(with: text, at: CGPoint(x: 0, y: yPosition - 10))
//                yAxisLabels.append(labelLayer)
//            }
//        }

//        // Helper methods
//        private func createLabelLayer(with text: String, at position: CGPoint) -> CATextLayer {
//            let labelLayer = CATextLayer()
//            labelLayer.string = text
//            labelLayer.foregroundColor = UIColor.black.cgColor
//            labelLayer.alignmentMode = .center
//            labelLayer.contentsScale = UIScreen.main.scale
//            labelLayer.fontSize = 12
//            labelLayer.frame = CGRect(x: position.x, y: position.y, width: 50, height: 20)
//            layer.addSublayer(labelLayer)
//            return labelLayer
//        }
    private func updateXAxisLabels(for dataCount: Int) {
            // 更新横轴标签，并将标签稍微向下移动以避免交叉坐标轴
            let maxLabelCount = min(dataCount, 10) // 限制最多显示10个标签
            // 计算第一个标签的起始位置，留出左侧空间
            let firstLabelXPosition = CGFloat(30)
            let labelInterval = (bounds.width - firstLabelXPosition) / CGFloat(maxLabelCount)
            xAxisLabels.forEach { $0.removeFromSuperlayer() }
            xAxisLabels.removeAll()
            
            for i in 0..<maxLabelCount {
                let xPosition = firstLabelXPosition + CGFloat(i) * labelInterval - labelInterval / 2
                let text = "\(i * (dataCount / maxLabelCount))"
                let labelLayer = createLabelLayer(with: text, at: CGPoint(x: xPosition+15, y: bounds.height - 15))
                xAxisLabels.append(labelLayer)
            }
        }

        private func updateYAxisLabels(for maxValue: Double) {
            // 更新纵轴标签，并将标签稍微左移以避免交叉坐标轴
            let labelCount = 10 // 按需设置y轴标签数量
            // 计算第一个标签的起始位置，留出下侧空间
            let firstLabelYPosition = bounds.height - CGFloat(30)
            let labelInterval = (firstLabelYPosition - 0) / CGFloat(labelCount - 1)
            yAxisLabels.forEach { $0.removeFromSuperlayer() }
            yAxisLabels.removeAll()
            
            for i in 0..<labelCount {
                let yPosition = firstLabelYPosition - CGFloat(i) * labelInterval + labelInterval / 2
                let text = String(format: "%.1f", maxValue * Double(i) / Double(labelCount - 1))
                let labelLayer = createLabelLayer(with: text, at: CGPoint(x: 2, y: yPosition - 15))
                yAxisLabels.append(labelLayer)
            }
        }

        // Helper methods
        private func createLabelLayer(with text: String, at position: CGPoint) -> CATextLayer {
            let labelLayer = CATextLayer()
            labelLayer.string = text
            labelLayer.foregroundColor = UIColor.black.cgColor
            labelLayer.alignmentMode = .left // 横轴标签左对齐，纵轴标签右对齐
            labelLayer.contentsScale = UIScreen.main.scale
            labelLayer.fontSize = 12
            labelLayer.font = UIFont.systemFont(ofSize: labelLayer.fontSize)
            // 给标签更多的左侧空间
            labelLayer.frame = CGRect(x: position.x, y: position.y, width: 60, height: 20)
            layer.addSublayer(labelLayer)
            return labelLayer
        }
    
    private func configureDottedLineLayer(_ dottedLineLayer: CAShapeLayer, isVertical: Bool) {
            dottedLineLayer.strokeColor = UIColor.lightGray.cgColor
            dottedLineLayer.lineWidth = 1
            dottedLineLayer.lineDashPattern = [2, 3] // 2是绘制长度，3是间隔长度
            dottedLineLayer.fillColor = nil
            if isVertical {
                dottedLineLayer.lineDashPhase = 0.0 // 控制起始偏移
            } else {
                dottedLineLayer.lineDashPhase = 1.5 // 调整x轴虚线起始偏移使其看起来比较平衡
            }
        }
    
    // 绘制横轴和纵轴的虚线
    private func drawAxisDottedLines() {
        // 首先移除之前的所有虚线
        layer.sublayers?.filter { $0.name == "dottedLine" }.forEach { $0.removeFromSuperlayer() }

        // 对于x轴，我们根据标签的中心位置添加虚线
        for labelLayer in xAxisLabels {
            let startPoint = CGPoint(x: labelLayer.frame.midX, y: bounds.height - 30)
            let endPoint = CGPoint(x: labelLayer.frame.midX, y: 0)
            drawDottedLine(from: startPoint, to: endPoint)
        }

        // 对于y轴，我们也根据标签的中心位置添加虚线
        for labelLayer in yAxisLabels {
            let startPoint = CGPoint(x: 30, y: labelLayer.frame.midY)
            let endPoint = CGPoint(x: bounds.width, y: labelLayer.frame.midY)
            drawDottedLine(from: startPoint, to: endPoint)
        }
    }

        private func drawDottedLine(from startPoint: CGPoint, to endPoint: CGPoint) {
            let dottedLinePath = UIBezierPath()
            dottedLinePath.move(to: startPoint)
            dottedLinePath.addLine(to: endPoint)
            
            let lineLayer = CAShapeLayer()
            lineLayer.path = dottedLinePath.cgPath
            lineLayer.strokeColor = UIColor.lightGray.cgColor
            lineLayer.lineWidth = 1
            lineLayer.lineDashPattern = [2, 3] // 虚线模式: 每一段虚线长度为2，间隔为3
            lineLayer.name = "dottedLine"
            
            layer.addSublayer(lineLayer)
        }
}
