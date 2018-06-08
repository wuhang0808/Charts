//
//  NodeChartDataSet.swift
//  Charts
//
//  Created by wuhang on 2018/5/16.
//

import UIKit

class NodeChartDataSet: ChartDataSet, INodeChartDataSet {
    
    

    @objc open var nodeValue: [NodeChartDataEntry]
    
    @objc open var linkValue: [LinkDataEntry]
    
    @objc open var legendValue: [String]
    
    var _nodeTotalSize = Double(0.0)
    
    
    //The minimum radius
    
    
    public required init() {
        
        nodeValue = []
        
        linkValue = []
        
        legendValue = []
        
        super .init()
    }
    open var minRadius: CGFloat {return 2.0}
    
    open var entryNodeCount: Int {return nodeValue.count}
    
    open var entryLinkCount: Int {return linkValue.count}
    
    open var nodeTotalSize: Double {return _nodeTotalSize}
    
    @objc public init(nodeValue: [NodeChartDataEntry]?, linkValue: [LinkDataEntry]?)
    {
        self.nodeValue = nodeValue ?? []
        self.linkValue = linkValue ?? []
        self.legendValue = []
        super.init()
        self.initialize()
        
    }
    
    private func initialize()
    {
        self.calcNodeTotalSize()
    }
    
    func entryFromNodeValueForIndex(_ i: Int) -> ChartDataEntry? {
        
        guard i >= nodeValue.startIndex, i < nodeValue.endIndex else {
            return nil
        }
        
        return nodeValue[i]
    }
    
    func entryFromLinkValueForIndex(_ i: Int) -> ChartDataEntry? {
        
        guard i >= linkValue.startIndex, i < linkValue.endIndex else {
            return nil
        }
        
        return linkValue[i]
    }
    
    func calcNodeTotalSize() {
        
        for nodeEntry in nodeValue {
            
            _nodeTotalSize += nodeEntry.y
        }
    }
    
    open override var entryCount: Int
    {
        return legendValue.count;
    }
}
