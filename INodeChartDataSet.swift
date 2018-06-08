//
//  INodeChartDataSet.swift
//  Charts
//
//  Created by wuhang on 2018/5/16.
//

import UIKit

@objc
protocol INodeChartDataSet: IChartDataSet {
    
    func entryFromNodeValueForIndex(_ i: Int) -> ChartDataEntry?
    
    func entryFromLinkValueForIndex(_ i: Int) -> ChartDataEntry?
    
    var entryNodeCount: Int {get}
    
    var entryLinkCount: Int {get}
    
    var nodeTotalSize : Double {get}
    
    var minRadius: CGFloat {get}
    
}


