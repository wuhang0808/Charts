//
//  NodeChartDataEntry.swift
//  Charts
//
//  Created by wuhang on 2018/5/15.
//

import UIKit

class NodeChartDataEntry: ChartDataEntry {

    public required init() {
        super.init()
    }
    
    open var num: NSInteger?
    @objc open var nodeId: String?
    @objc open var nodeName: String?
    
    @objc public init(x: Double, y: Double, num: Int, nodeId: String, nodeName: String)
    {
        super .init(x: x, y: y)
        
        self.num = num
        self.nodeId = nodeId
        self.nodeName = nodeName
    }
    
    @objc override func copyWithZone(_ zone: NSZone?) -> AnyObject {
        
        let copy = type(of: self).init()
        
        copy.x = x
        copy.y = y
        copy.num = num
        copy.nodeId = nodeId
        copy.nodeName = nodeName
        copy.data = data
        
        return copy
    }
    
    
}
