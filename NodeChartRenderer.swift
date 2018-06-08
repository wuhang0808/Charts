//
//  NodeChartRenderer.swift
//  Charts
//
//  Created by wuhang on 2018/5/16.
//

import UIKit

class NodeChartRenderer: DataRenderer {

    @objc open weak var chart: NodeChartView?
    
    var cacheEdgePointDict = Dictionary<String, String>()
    
    @objc public init(chart: NodeChartView, animator: Animator, viewPorHandler: ViewPortHandler)
    {
        super .init(animator: animator, viewPortHandler: viewPorHandler)
        
        self.chart = chart
    }
    
    open override func drawData(context: CGContext) {
        
        guard let chart = chart else {
            return
        }
        
        let nodeData = chart.data
        
        if nodeData != nil
        {
            for set in nodeData!.dataSets as! [INodeChartDataSet]
            {
                if set.isVisible && set.entryNodeCount > 0
                {
                    drawDataSet(context: context, dataSet: set)
                    
                    drawRelatedLine(context: context, dataSet: set)
                }
            }
        }
        
    }
    
    @objc open func drawDataSet(context: CGContext, dataSet: INodeChartDataSet)
    {
        guard let chart = chart else {return }
        
        var currentRadians: Double = 0.0
        let entryCount = dataSet.entryNodeCount
        let radius = chart.radius
        let circleRadius = dataSet.minRadius
        let nodeTotalSize = dataSet.nodeTotalSize
        
        let trans = chart.getTransformer()
        let valueToPixelMatrix = trans.valueToPixelMatrix
        let center = chart.centerCircleBox
        //trans.pixelToValues(&center)
        
        var visibleAngleCount = 0
        
        for j in 0 ..< entryCount {
            
            guard let e = dataSet.entryFromNodeValueForIndex(j) else {continue}
            
            if ((abs(e.y) > Double.ulpOfOne))
            {
                visibleAngleCount += 1
            }
        }
        
        for j in 0 ..< entryCount {
            
            guard let e = dataSet.entryFromNodeValueForIndex(j) as? NodeChartDataEntry else {continue}
            
            let radians = 2 * Double.pi * (e.y / nodeTotalSize)
            
            currentRadians += radians / 2
            
            let x =  Double(center.x) + Double(radius) * cos(currentRadians)
            let y =  Double(center.x) - Double(radius) * sin(currentRadians)
        
            let colorIndex = max(e.num!-1, 0)
            let color = dataSet.colors[colorIndex % dataSet.colors.count]
            let roundRadius = circleRadius * CGFloat(e.y)
    
            self.drawCircle(context: context, point: CGPoint (x: x, y: y).applying(valueToPixelMatrix), radius: roundRadius, color: color)
            
            let labelRadius = radius + 20
            let x1 = Double(center.x) + Double(labelRadius) * cos(currentRadians)
            let y1 = Double(center.x) - Double(labelRadius) * sin(currentRadians)
            
            self.drawValue(context: context, point: CGPoint (x: x1, y: y1).applying(valueToPixelMatrix), label: e.nodeName!, radians: CGFloat(2 * Double.pi - currentRadians), transform: valueToPixelMatrix)
            

            let x2 = Double(center.x) + Double(radius - roundRadius) * cos(currentRadians)
            let y2 = Double(center.x) - Double(radius - roundRadius) * sin(currentRadians)
            
            cacheEdgePointDict[e.nodeId!] = NSStringFromCGPoint(CGPoint(x: x2, y: y2).applying(valueToPixelMatrix))
            
            currentRadians += radians / 2
        }
    }
    
    func drawCircle(context: CGContext, point: CGPoint, radius: CGFloat, color: NSUIColor) {
        
        context.saveGState()
        context.setStrokeColor(color.cgColor)
        context.setFillColor(color.cgColor)
        context.setLineWidth(1)
        let path = CGMutablePath()
        path.addArc(center: point, radius: radius, startAngle: 0, endAngle: CGFloat(2 * Float.pi), clockwise: false)
        context.addPath(path)
        context.fillPath()
        context.restoreGState()
    
    }
    
    func drawValue(context: CGContext, point: CGPoint, label: String, radians: CGFloat, transform: CGAffineTransform) {
        
        context.saveGState()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        
        var attributes = [NSAttributedStringKey : Any]()
        attributes[NSAttributedStringKey.paragraphStyle] = paragraphStyle
        attributes[NSAttributedStringKey.foregroundColor] = UIColor.lightGray
        attributes[NSAttributedStringKey.font] = UIFont.systemFont(ofSize: 12)
        
        let labelSize = label.size(withAttributes: attributes)
        let frame = CGRect(x: 0, y: 0, width: labelSize.width, height: labelSize.height)
        let angle = radians.RAD2DEG
        
        if angle > 90 && angle < 270 {
            
            let transPoint = CGPoint(x: point.x - labelSize.width, y: point.y - labelSize.height / 2)
            context.translateBy(x: transPoint.x, y: transPoint.y)
            context.rotate(by: CGFloat(Float.pi - Float(radians)))
        }else{

            let transPoint = CGPoint(x: point.x, y: point.y - labelSize.height / 2)
            context.translateBy(x: transPoint.x, y: transPoint.y)
            context.rotate(by: -radians)
        }
        
        label.draw(in: frame, withAttributes: attributes)
        context.restoreGState()

    }
    
    open func drawRelatedLine(context: CGContext, dataSet: INodeChartDataSet) {
        
        guard let chart = chart else { return }
        let entryCount = dataSet.entryLinkCount
        
        let trans = chart.getTransformer()
        let valueToPixelMatrix = trans.valueToPixelMatrix
        
        context.saveGState()
        for j in 0 ..< entryCount {
            
            guard let e = dataSet.entryFromLinkValueForIndex(j) as? LinkDataEntry else {continue}
            
            let startPoint = CGPointFromString(cacheEdgePointDict[e.sourceId!]!)
            let endPoint = CGPointFromString(cacheEdgePointDict[e.targetId!]!)
            
            context.saveGState()
            let colorIndex = max(e.sourceNum - 1, 0)
            let color = dataSet.colors[colorIndex % dataSet.colors.count]
            
            context.setStrokeColor(color.cgColor)
            context.setLineWidth(2)
            let path = CGMutablePath()
            path.move(to: startPoint)
            path.addQuadCurve(to: endPoint, control: chart.centerCircleBox.applying(valueToPixelMatrix))
            context.addPath(path)
            context.drawPath(using: CGPathDrawingMode.stroke)

        }
        context.restoreGState()
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
}
