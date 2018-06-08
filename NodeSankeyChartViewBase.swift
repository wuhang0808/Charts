//
//  NodeSankeyChartViewBase.swift
//  Charts
//
//  Created by wuhang on 2018/5/15.
//

import UIKit

class NodeSankeyChartViewBase: ChartViewBase {

    private var _tapGestureRecognizer : NSUITapGestureRecognizer!
    
    private var _doubleTapGestureRecognizer : NSUITapGestureRecognizer!
    
    #if !os(tvOS)

    private var _pinchGestureRecognizer : NSUIPinchGestureRecognizer!
    #endif
    
    public override init(frame: CGRect) {
        
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super .init(coder: aDecoder)
    }
    
    deinit {
    
    }
    
    internal override func initialize() {
        
        super.initialize()
        
        _tapGestureRecognizer = NSUITapGestureRecognizer(target: self, action: #selector(tapGestureRecognized(_:)))
        self.addGestureRecognizer(_tapGestureRecognizer)
        
        _doubleTapGestureRecognizer = NSUITapGestureRecognizer(target: self, action: #selector(doubleTapGestureRecognized(_:)))
        _doubleTapGestureRecognizer.nsuiNumberOfTapsRequired = 2;
        
        #if !os(tvOS)
            
            _pinchGestureRecognizer = NSUIPinchGestureRecognizer (target: self, action: #selector(pinchGestureRecognized(_:)))
            self.addGestureRecognizer(_pinchGestureRecognizer)
        #endif
        self.addGestureRecognizer(_doubleTapGestureRecognizer)
    }
    
    @objc private func tapGestureRecognized(_ recognizer: NSUITapGestureRecognizer)
    {
        
    }
    
    @objc private func doubleTapGestureRecognized(_ recognizer : NSUITapGestureRecognizer)
    {
        
    }
    
    @objc private func pinchGestureRecognized(_ recognizer : NSUIPinchGestureRecognizer)
    {
        
    }
    
    
//    internal override func calculateOffsets() {
//
//        var legendLeft = CGFloat(0.0)
//        var legendRight = CGFloat(0.0)
//        var legendTop = CGFloat(0.0)
//        var legendBottom = CGFloat(0.0)
//
//        if _legend != nil && _legend.enabled && _legend.drawInside
//        {
//            let fullLegendWidth = min(_legend.neededWidth, _viewPortHandler.chartWidth * _legend.maxSizePercent)
//
//            switch _legend.orientation
//            {
//            case .vertical:
//
//                var xLegendOffset: CGFloat = 0.0
//
//                if _legend.horizontalAlignment == .left ||
//                    _legend.horizontalAlignment == .right
//                {
//                    if _legend.verticalAlignment == .center
//                    {
//                        let spacing = CGFloat(13.0)
//
//                        xLegendOffset = fullLegendWidth + spacing
//
//                    }else{
//
//                        let spacing = CGFloat(8.0)
//
//                        let legendWidth = fullLegendWidth + spacing
//                        let legendHeight = _legend.neededHeight + _legend.textHeightMax
//
//                        let c = self.midPoint
//
//                        let bottomX = _legend.horizontalAlignment == .right ? self.bounds.size.width - legendWidth + 15 : legendWidth - 15
//                        let bottomY = legendHeight + 15.0
//
//                        let distLegend =
//
//
//
//
//
//
//
//                    }
//                }
//
//
//
//            default:
//                break
//            }
//
//
//        }
//    }
}
