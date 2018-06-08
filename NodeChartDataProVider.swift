//
//  NodeChartDataProVider.swift
//  Charts
//
//  Created by wuhang on 2018/5/16.
//

import Foundation

@objc
public protocol NodeChartDataProVider : ChartDataProvider
{
    var nodeData: NodeChartData? {get}
    
    func getTransformer() -> Transformer
}

