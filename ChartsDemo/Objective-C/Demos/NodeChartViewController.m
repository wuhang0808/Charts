//
//  NodeChartViewController.m
//  ChartsDemo
//
//  Created by wuhang on 2018/5/15.
//  Copyright © 2018年 dcg. All rights reserved.
//

#import "NodeChartViewController.h"
#import "ChartsDemo-Swift.h"

@interface NodeChartViewController ()

@property (strong, nonatomic) IBOutlet NodeChartView *chartView;

@property (nonatomic, strong) NSArray *nodeArray;
@property (nonatomic, strong) NSArray *linkArray;
@end

@implementation NodeChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Box Chart";
    
    self.options = @[
                     @{@"key": @"toggleValues", @"label": @"Toggle Values"},
                     @{@"key": @"toggleIcons", @"label": @"Toggle Icons"},
                     @{@"key": @"toggleHighlight", @"label": @"Toggle Highlight"},
                     @{@"key": @"animateX", @"label": @"Animate X"},
                     @{@"key": @"animateY", @"label": @"Animate Y"},
                     @{@"key": @"animateXY", @"label": @"Animate XY"},
                     @{@"key": @"saveToGallery", @"label": @"Save to Camera Roll"},
                     @{@"key": @"togglePinchZoom", @"label": @"Toggle PinchZoom"},
                     @{@"key": @"toggleAutoScaleMinMax", @"label": @"Toggle auto scale min/max"},
                     @{@"key": @"toggleShadowColorSameAsCandle", @"label": @"Toggle shadow same color"},
                     @{@"key": @"toggleData", @"label": @"Toggle Data"},
                     ];
    [_chartView setExtraOffsetsWithLeft:20.f top:0.f right:20.f bottom:0.f];
    
    NSString *string = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TangramMock" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    self.nodeArray = dict[@"nodes"];
    self.linkArray = dict[@"labels"];
    
    _chartView.chartDescription.enabled = NO;
    
    ChartLegend *legend = _chartView.legend;
    legend.horizontalAlignment = ChartLegendHorizontalAlignmentCenter;
    
    
    NSMutableArray *nodesArray = [NSMutableArray array];
    NSMutableArray *linksArray = [NSMutableArray array];
    
    for (NSInteger i = 0; i < _nodeArray.count; i++) {
        
        NSDictionary *node = _nodeArray[i];
        NSString *category = [node[@"category"] substringToIndex:1];
        NodeChartDataEntry *nodeEntry = [[NodeChartDataEntry alloc] initWithX:i y:[node[@"symbolSize"] doubleValue] num:[category integerValue] nodeId:node[@"id"] nodeName:node[@"name"]];
        [nodesArray addObject:nodeEntry];
    }
    
    for (NSInteger i = 0; i < _linkArray.count; i++) {
        
        NSDictionary *link =_linkArray[i];
        LinkDataEntry *linkEntry = [[LinkDataEntry alloc] initWithX:i y:0 sourceId:link[@"sourceShopId"] targetId:link[@"targetShopId"] sourceNum:[link[@"sourceShopFloorNum"] integerValue] targetNum:[link[@"targetShopFloorNum"] integerValue]];
        [linksArray addObject:linkEntry];
    }
    
    NSMutableArray *legendArr = [NSMutableArray array];
    for (NSDictionary *temp in dict[@"floors"]) {
        [legendArr addObject:temp[@"name"]];
    }
    
    NodeChartDataSet *set = [[NodeChartDataSet alloc] initWithNodeValue:nodesArray linkValue:linksArray];
    set.colors = @[[UIColor redColor], [UIColor purpleColor], [UIColor lightGrayColor], [UIColor orangeColor]];
    set.legendValue = legendArr;
    NodeChartData *d = [[NodeChartData alloc] initWithDataSet:set];
    
    self.chartView.data = d;
    

}




@end
