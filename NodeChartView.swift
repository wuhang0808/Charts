//
//  NodeChartView.swift
//  Charts
//
//  Created by wuhang on 2018/5/16.
//

import UIKit

class NodeChartView: ChartViewBase, NodeChartDataProVider {
    
    
    
    var lowestVisibleX: Double = 0.0
    var highestVisibleX: Double = 0.0
    private var _circleBox = CGRect()
    @objc open var minOffset = CGFloat(10.0)
    
    internal var _axisTransformer: Transformer!
    
    private var _tapGestureRecognizer : NSUITapGestureRecognizer!
    private var _doubleTapGestureRecognizer : NSUITapGestureRecognizer!
    private var _pinchGestureRecognizer : NSUIPinchGestureRecognizer!
    private var _panGestureRecognizer: NSUIPanGestureRecognizer!
    
    override func initialize() {
        super .initialize()
        
        _axisTransformer = Transformer(viewPortHandler: _viewPortHandler)
        
        renderer = NodeChartRenderer (chart: self, animator: _animator, viewPorHandler: _viewPortHandler)
        
        _tapGestureRecognizer = NSUITapGestureRecognizer(target: self, action: #selector(tapGestureRecognized(_:)))
        self.addGestureRecognizer(_tapGestureRecognizer)
        
        _doubleTapGestureRecognizer = NSUITapGestureRecognizer(target: self, action: #selector(doubleTapGestureRecognized(_:)))
        _doubleTapGestureRecognizer.nsuiNumberOfTapsRequired = 2;
        self.addGestureRecognizer(_doubleTapGestureRecognizer)
        
        _pinchGestureRecognizer = NSUIPinchGestureRecognizer (target: self, action: #selector(pinchGestureRecognized(_:)))
        self.addGestureRecognizer(_pinchGestureRecognizer)
        
        _panGestureRecognizer = NSUIPanGestureRecognizer(target: self, action: #selector(panGestureRecognized(_:)))
        self.addGestureRecognizer(_panGestureRecognizer)
    }
    
    override func draw(_ rect: CGRect) {
        
        //super.draw(rect)
        
        if data == nil {
            return
        }
        
        let optionalContext = NSUIGraphicsGetCurrentContext()
        guard let context = optionalContext, let renderer = renderer else
        {
            return
        }
        
        renderer.drawData(context: context)
        
        legendRenderer.renderLegend(context: context);
        
    }
    
    internal func calculateLegendOffsets()
    {
        // setup offsets for legend
        var legendLeft = CGFloat(0.0)
        var legendRight = CGFloat(0.0)
        var legendBottom = CGFloat(0.0)
        var legendTop = CGFloat(0.0)

        if _legend != nil && _legend.enabled && !_legend.drawInside
        {
            let fullLegendWidth = min(_legend.neededWidth, _viewPortHandler.chartWidth * _legend.maxSizePercent)
            
            switch _legend.orientation
            {
            case .vertical:
                
                var xLegendOffset: CGFloat = 0.0
                
                if _legend.horizontalAlignment == .left
                    || _legend.horizontalAlignment == .right
                {
                    if _legend.verticalAlignment == .center
                    {
                        // this is the space between the legend and the chart
                        let spacing = CGFloat(13.0)
                        
                        xLegendOffset = fullLegendWidth + spacing
                    }
                    else
                    {
                        // this is the space between the legend and the chart
                        let spacing = CGFloat(8.0)
                        
                        let legendWidth = fullLegendWidth + spacing
                        let legendHeight = _legend.neededHeight + _legend.textHeightMax
                        
                        let c = self.midPoint
                        
                        let bottomX = _legend.horizontalAlignment == .right
                            ? self.bounds.width - legendWidth + 15.0
                            : legendWidth - 15.0
                        let bottomY = legendHeight + 15
                        let distLegend = distanceToCenter(x: bottomX, y: bottomY)
                        
                        let reference = getPosition(center: c, dist: self.radius,
                                                    angle: angleForPoint(x: bottomX, y: bottomY))
                        
                        let distReference = distanceToCenter(x: reference.x, y: reference.y)
                        let minOffset = CGFloat(5.0)
                        
                        if bottomY >= c.y
                            && self.bounds.height - legendWidth > self.bounds.width
                        {
                            xLegendOffset = legendWidth
                        }
                        else if distLegend < distReference
                        {
                            let diff = distReference - distLegend
                            xLegendOffset = minOffset + diff
                        }
                    }
                }
                
                switch _legend.horizontalAlignment
                {
                case .left:
                    legendLeft = xLegendOffset
                    
                case .right:
                    legendRight = xLegendOffset
                    
                case .center:
                    
                    switch _legend.verticalAlignment
                    {
                    case .top:
                        legendTop = min(_legend.neededHeight, _viewPortHandler.chartHeight * _legend.maxSizePercent)
                        
                    case .bottom:
                        legendBottom = min(_legend.neededHeight, _viewPortHandler.chartHeight * _legend.maxSizePercent)
                        
                    default:
                        break
                    }
                }
                
            case .horizontal:
                
                var yLegendOffset: CGFloat = 0.0
                
                if _legend.verticalAlignment == .top
                    || _legend.verticalAlignment == .bottom
                {
                    // It's possible that we do not need this offset anymore as it
                    //   is available through the extraOffsets, but changing it can mean
                    //   changing default visibility for existing apps.
                    let yOffset = CGFloat(0.0)
                    
                    yLegendOffset = min(
                        _legend.neededHeight + yOffset,
                        _viewPortHandler.chartHeight * _legend.maxSizePercent)
                }
                
                switch _legend.verticalAlignment
                {
                case .top:
                    
                    legendTop = yLegendOffset
                    
                case .bottom:
                    
                    legendBottom = yLegendOffset
                    
                default:
                    break
                }
            }
        }

        
        legendTop += self.extraTopOffset
        legendRight += self.extraRightOffset
        legendBottom += self.extraBottomOffset
        legendLeft += self.extraLeftOffset
        
        let offsetLeft = max(minOffset, legendLeft)
        let offsetTop = max(minOffset, legendTop)
        let offsetRight = max(minOffset, legendRight)
        let offsetBottom = max(minOffset, legendBottom)
        
        _viewPortHandler.restrainViewPort(offsetLeft: offsetLeft, offsetTop: offsetTop, offsetRight: offsetRight, offsetBottom: offsetBottom)
        
    }
    
    internal override func calculateOffsets() {
    
        if _data === nil
        {
            return
        }
        
        calculateLegendOffsets()

        let radius =  diameter / 2

        let c = self.centerOffsets

//        let shift = (data as? NodeChartData)?.dataSet?.selectio
//        nShift ?? 0.0

        let shift: CGFloat = 0.0
        
        // create the circle box that will contain the pie-chart (the bounds of the pie-chart)
        _circleBox.origin.x = (c.x - radius) + shift
        _circleBox.origin.y = (c.y - radius) + shift
        _circleBox.size.width = diameter - shift * 2.0
        _circleBox.size.height = diameter - shift * 2.0
        
        prepareValuePxMatrix()
        prepareOffsetMatrix()

    }
    
    override func notifyDataSetChanged() {

        if let data = _data, _legend != nil
        {
            legendRenderer.computeLegend(data: data)
        }
        
        self.calculateOffsets()
        setNeedsDisplay()
    }
    
    //计算最小直径
    @objc open var diameter: CGFloat
    {
        var content = _viewPortHandler.contentRect
        content.origin.x += extraLeftOffset
        content.origin.y += extraTopOffset
        content.size.width -= extraLeftOffset + extraRightOffset
        content.size.height -= extraTopOffset + extraBottomOffset
        return min(content.width, content.height)
    }
    
    @objc open func distanceToCenter(x: CGFloat, y: CGFloat) -> CGFloat
    {
        let c = self.centerOffsets
        
        var dist = CGFloat(0.0)
        
        var xDist = CGFloat(0.0)
        var yDist = CGFloat(0.0)
        
        if x > c.x
        {
            xDist = x - c.x
        }
        else
        {
            xDist = c.x - x
        }
        
        if y > c.y
        {
            yDist = y - c.y
        }
        else
        {
            yDist = c.y - y
        }
        
        // pythagoras
        dist = sqrt(pow(xDist, 2.0) + pow(yDist, 2.0))
        
        return dist
    }
    
    @objc open func getPosition(center: CGPoint, dist: CGFloat, angle: CGFloat) -> CGPoint
    {
        return CGPoint(x: center.x + dist * cos(angle.DEG2RAD),
                       y: center.y + dist * sin(angle.DEG2RAD))
    }
    
    open var radius: CGFloat
    {
        return _circleBox.width / 2
    }
    
    open var centerCircleBox: CGPoint
    {
        return CGPoint(x: _circleBox.midX, y: _circleBox.midY)
    }

    open var nodeData: NodeChartData?
    {
        return _data as? NodeChartData
    }
    
    @objc open func angleForPoint(x: CGFloat, y: CGFloat) -> CGFloat
    {
        let c = centerOffsets
        
        let tx = Double(x - c.x)
        let ty = Double(y - c.y)
        let length = sqrt(tx * tx + ty * ty)
        let r = acos(ty / length)
        
        var angle = r.RAD2DEG
        
        if x > c.x
        {
            angle = 360.0 - angle
        }
        
        // add 90° because chart starts EAST
        angle = angle + 90.0
        
        // neutralize overflow
        if angle > 360.0
        {
            angle = angle - 360.0
        }
        
        return CGFloat(angle)
    }

    private enum GestureScaleAxis
    {
        case both
        case x
        case y
    }
    
    private var _decelerationDisplayLink: NSUIDisplayLink!
    private var _pinchZoomEnabled = false
    private var _doubleTapToZoomEnabled = true
    private var _dragXEnabled = true
    private var _dragYEnabled = true
    private var _scaleXEnabled = true
    private var _scaleYEnabled = true
    private var _isScaling = false
    private var _gestureScaleAxis = GestureScaleAxis.both
    
    private var _isDragging = false
    private var _closestDataSetToTouch: IChartDataSet!
    private var _panGestureReachedEdge: Bool = false
    private var _lastPanPoint = CGPoint()
    private var _decelerationLastTime: TimeInterval = 0.0
    private var _decelerationVelocity = CGPoint()
    
    @objc private func tapGestureRecognized(_ recognizer: NSUITapGestureRecognizer)
    {
        if _data === nil { return }
        
        if recognizer.state == NSUIGestureRecognizerState.ended
        {
            if !isHighLightPerTapEnabled { return }
            
            let h = getHighlightByTouchPoint(recognizer.location(in: self))
            
            if h === nil || h == self.lastHighlighted {
                highlightValue(nil, callDelegate: true)
                lastHighlighted = nil
            }
            else
            {
                highlightValue(h, callDelegate: true)
                lastHighlighted = h
            }
        }
    }
    
    @objc private func doubleTapGestureRecognized(_ recognizer : NSUITapGestureRecognizer)
    {
        
    }
    
    @objc private func pinchGestureRecognized(_ recognizer : NSUIPinchGestureRecognizer)
    {
        if recognizer.state == NSUIGestureRecognizerState.began {
            
            stopDeceleration()
            
            if _data !== nil &&
                (_pinchZoomEnabled || _scaleXEnabled || _scaleYEnabled) {
             
                _isScaling = true
                
                if _pinchZoomEnabled
                {
                    _gestureScaleAxis = .both
                }
                else
                {
                    let x = abs(recognizer.location(in: self).x - recognizer.nsuiLocationOfTouch(1, inView: self).x)
                    let y = abs(recognizer.location(in: self).y - recognizer.nsuiLocationOfTouch(1, inView: self).y)
                    
                    if _scaleXEnabled != _scaleYEnabled
                    {
                        _gestureScaleAxis = _scaleXEnabled ? .x : .y
                    }
                    else{
                        _gestureScaleAxis = x > y ? .x : .y
                    }
                }
            }
        }
        else if recognizer.state == NSUIGestureRecognizerState.ended ||
            recognizer.state == NSUIGestureRecognizerState.cancelled
        {
            if _isScaling
            {
                _isScaling = false
                
                calculateOffsets()
                
                setNeedsDisplay()
            }
        }
        else if recognizer.state == NSUIGestureRecognizerState.changed
        {
            let isZoomingOut = (recognizer.nsuiScale < 1)
            var canZoomMoreX = isZoomingOut ? _viewPortHandler.canZoomOutMoreX :
                _viewPortHandler.canZoomInMoreX
            var canZoomMoreY = isZoomingOut ? _viewPortHandler.canZoomOutMoreY :
                _viewPortHandler.canZoomInMoreY
            
            if _isScaling
            {
                canZoomMoreX = canZoomMoreX && _scaleXEnabled && (_gestureScaleAxis == .both || _gestureScaleAxis == .x)
                canZoomMoreY = canZoomMoreY && _scaleYEnabled && (_gestureScaleAxis == .both || _gestureScaleAxis == .y)
                
                if canZoomMoreX || canZoomMoreY
                {
                    var location = recognizer.location(in: self)
                    location.x = location.x - _viewPortHandler.offsetLeft
                    
//                    let scaleX = canZoomMoreX ? recognizer.nsuiScale : 1.0
//                    let scaleY = canZoomMoreY ? recognizer.nsuiScale : 1.0
                    let scaleX = recognizer.nsuiScale 
                    let scaleY = recognizer.nsuiScale
                    
                    var matrix = CGAffineTransform(translationX: location.x, y: location.y)
                    matrix = matrix.scaledBy(x: scaleX, y: scaleY)
                    matrix = matrix.translatedBy(x: -location.x, y: -location.y)
                    matrix = _viewPortHandler.touchMatrix.concatenating(matrix)
                    
                    _viewPortHandler.refresh(newMatrix: matrix, chart: self, invalidate: true)
                    if delegate !== nil
                    {
                        delegate?.chartScaled!(self, scaleX: scaleX, scaleY: scaleY)
                    }
                }
                recognizer.nsuiScale = 1.0
            }
        }
    }
    
    @objc private func panGestureRecognized(_ recognizer: NSUIPanGestureRecognizer)
    {
        if recognizer.state == NSUIGestureRecognizerState.began &&
            recognizer.nsuiNumberOfTouches() > 0
        {
            stopDeceleration()
            
            if _data == nil || !self.isDragEnabled
            {
                return;
            }
            
            if !self.hasNoDragOffset || !self.isFullyZoomedOut
            {
                _isDragging = true
                
                //_closestDataSetToTouch = getda
                let translation = recognizer.translation(in: self)
               
                let didUserDrag = translation.x != 0.0 || translation.y != 0.0
                
                if didUserDrag && !performPanChange(translation: translation)
                {
                    
                    
                }else{
                    
                }
                
                _lastPanPoint = recognizer.translation(in: self)
            }
        }
        else if recognizer.state == NSUIGestureRecognizerState.changed
        {
            if _isDragging
            {
                let originalTranslation = recognizer.translation(in: self)
                let translation = CGPoint(x: originalTranslation.x - _lastPanPoint.x, y: originalTranslation.y - _lastPanPoint.y)
                
               let _ = performPanChange(translation: translation)
                
                _lastPanPoint = originalTranslation
            }
        }
        else if recognizer.state == NSUIGestureRecognizerState.ended || recognizer.state == NSUIGestureRecognizerState.cancelled
        {
            if _isDragging
            {
                if recognizer.state == NSUIGestureRecognizerState.ended  && isDragDecelerationEnabled
                {
                    stopDeceleration()
                    
                    _decelerationLastTime = CACurrentMediaTime()
                    _decelerationVelocity = recognizer.velocity(in: self)
                    
                    _decelerationDisplayLink = NSUIDisplayLink(target: self, selector: #selector(NodeChartView.decelerationLoop))
                    _decelerationDisplayLink.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
                }
                _isDragging = false
            }
        }
        
    }
    
    private func performPanChange(translation: CGPoint) -> Bool
    {
//        var translation = translation

//        if isTouchInverted()
//        {
//            if self is HorizontalBarChartView
//            {
//                translation.x = -translation.x
//            }
//            else
//            {
//                translation.y = -translation.y
//            }
//        }

        let originalMatrix = _viewPortHandler.touchMatrix

        var matrix = CGAffineTransform(translationX: translation.x, y: translation.y)
        matrix = originalMatrix.concatenating(matrix)

        matrix = _viewPortHandler.refresh(newMatrix: matrix, chart: self, invalidate: true)

        if delegate !== nil
        {
            delegate?.chartTranslated?(self, dX: translation.x, dY: translation.y)
        }

        // Did we managed to actually drag or did we reach the edge?
        return matrix.tx != originalMatrix.tx || matrix.ty != originalMatrix.ty
    }
    
//    private func isTouchInverted() -> Bool
//    {
//        return isAnyAxisInverted &&
//            _closestDataSetToTouch !== nil &&
//            getAxis(_closestDataSetToTouch.axisDependency).isInverted
//    }
    
    @objc open func stopDeceleration()
    {
        if _decelerationDisplayLink !== nil {
            _decelerationDisplayLink.remove(from: RunLoop.main, forMode: RunLoopMode.commonModes)
            _decelerationDisplayLink = nil
        }
    }
    
    @objc open var dragEnabled: Bool
    {
        get
        {
            return _dragXEnabled || _dragYEnabled
        }
        set
        {
            _dragXEnabled = newValue
            _dragYEnabled = newValue;
        }
    }
    
    @objc open var isDragEnabled: Bool{
        
        return dragEnabled
    }
    
    @objc open var hasNoDragOffset: Bool {
        return _viewPortHandler.hasNoDragOffset
    }
    
    @objc open var isFullyZoomedOut: Bool {
        return _viewPortHandler.isFullyZoomedOut
    }
    
    @objc private func decelerationLoop()
    {
        let currentTime = CACurrentMediaTime()
        
        _decelerationVelocity.x *= self.dragDecelerationFrictionCoef
        _decelerationVelocity.y *= self.dragDecelerationFrictionCoef
        
        let timeInterval = CGFloat(currentTime - _decelerationLastTime)
        
        let distance = CGPoint(
            x: _decelerationVelocity.x * timeInterval,
            y: _decelerationVelocity.y * timeInterval
        )
        
        if !performPanChange(translation: distance)
        {
            // We reached the edge, stop
            _decelerationVelocity.x = 0.0
            _decelerationVelocity.y = 0.0
        }
        
        _decelerationLastTime = currentTime
        
        if abs(_decelerationVelocity.x) < 0.001 && abs(_decelerationVelocity.y) < 0.001
        {
            stopDeceleration()
            
            // Range might have changed, which means that Y-axis labels could have changed in size, affecting Y-axis size. So we need to recalculate offsets.
            calculateOffsets()
            setNeedsDisplay()
        }
    }
    
    
    
    internal func prepareValuePxMatrix()
    {
        _axisTransformer.prepareMatrixValuePx(chartXMin: Double(_viewPortHandler.contentLeft), deltaX: _viewPortHandler.contentWidth, deltaY: _viewPortHandler.contentHeight, chartYMin: Double(_viewPortHandler.contentTop))
    }
    
    internal func prepareOffsetMatrix()
    {
        _axisTransformer.prepareMatrixOffset(inverted: false)
    }
    
    func getTransformer() -> Transformer {
        return _axisTransformer
    }
}
