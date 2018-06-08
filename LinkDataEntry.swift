//
//  LinkDataEntry.swift
//  Charts
//
//  Created by wuhang on 2018/5/15.
//

import UIKit

class LinkDataEntry: ChartDataEntry {

    public required init() {
        super.init()
    }
    
    @objc open var sourceId: String?
    
    @objc open var targetId: String?
    
    @objc open var sourceNum: NSInteger = 0
    
    @objc open var targetNum: NSInteger = 0
    
    @objc public init(x: Double, y: Double, sourceId: String, targetId: String, sourceNum: NSInteger, targetNum: NSInteger)
    {
        super.init(x: x, y: y)
        
        self.sourceId = sourceId
        self.targetId = targetId
        self.sourceNum = sourceNum
        self.targetNum = targetNum
    }
    
    override func copyWithZone(_ zone: NSZone?) -> AnyObject {
        let copy = type(of: self).init()
        
        copy.x = x
        copy.y = y
        copy.sourceId = sourceId
        copy.targetId = targetId
        copy.sourceNum = sourceNum
        copy.targetNum = targetNum
        
        return copy
        
    }
    
}
