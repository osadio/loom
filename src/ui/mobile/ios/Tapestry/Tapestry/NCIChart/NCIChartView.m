//
//  NCIChartView.m
//  Tapestry
//
//  Created by Ira on 11/13/13.
//  Copyright (c) 2013 Truststix. All rights reserved.
//

#import "NCIChartView.h"
#import "NCIGraphView.h"
#import "NCIBottomGraphView.h"
#import "NCIMianGraphView.h"

@interface NCIChartView(){

}

@property (nonatomic)int maxYVal;
@property (nonatomic)int minYVal;
@property (nonatomic)float maxXVal;
@property (nonatomic)float minXVal;

@end

@implementation NCIChartView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:(CGRect)frame];
    if (self) {
        _hasRangeSelector = YES;
        _topBottomReserve = 5;
        _minXVal = MAXFLOAT;
        _maxXVal = -MAXFLOAT;
        
        self.chartData = [[NSMutableArray alloc] init];
        _mainGraph = [[NCIMianGraphView alloc] initWithChart:self];
        _mainGraph.backgroundColor = [UIColor whiteColor];
        _mainGraph.gridArea.hasPointSelector = YES;
        [self addSubview:_mainGraph];
        
        _bottomGraph = [[NCIBottomGraphView alloc] initWithChart:self];
        _bottomGraph.backgroundColor = [UIColor whiteColor];
        [self addSubview:_bottomGraph];
        
        _selectedPoint = [[UILabel alloc] initWithFrame:CGRectZero];
        _selectedPoint.font = [UIFont italicSystemFontOfSize:20];
        [self addSubview:_selectedPoint];

    }
    return self;
}

- (void)layoutSubviews{
    float bottomGraphHeight = 130;
    _selectedPoint.frame = CGRectMake(self.bounds.size.width - 320, 0, 300, 30);
    //[_selectedPoint setBackgroundColor:[UIColor purpleColor]];
    if (_hasRangeSelector){
        _mainGraph.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - bottomGraphHeight);
        _bottomGraph.frame = CGRectMake(0, self.bounds.size.height - bottomGraphHeight, self.bounds.size.width, bottomGraphHeight);
    } else {
        _mainGraph.frame = self.bounds;
    }
    [_mainGraph setNeedsDisplay];
    [_bottomGraph setNeedsDisplay];
}

- (float)getMinValue{
    float diff = _maxYVal - _minYVal;
    if (diff == 0)
        return _minYVal -1;
    return _minYVal - diff*_topBottomReserve/100;
}

- (float)getMaxValue{
    float diff = _maxYVal - _minYVal;
    if (diff == 0)
        return _maxYVal -1;
    return _maxYVal + diff*_topBottomReserve/100;
}

- (float)getMinArgument{
    return _minXVal;
}

- (float)getMaxArgument{
    return _maxXVal;
}

- (void)setMinArgument:(NSDate *)date{
    _minXVal  = [date timeIntervalSince1970];
}

- (void)setMaxArgument:(NSDate *)date{
    _maxXVal = [date timeIntervalSince1970];
}

- (void)resetChart{
    [self.chartData removeAllObjects];
    _minXVal = MAXFLOAT;
    _maxXVal = -MAXFLOAT;
    _minYVal = 0;
    _maxYVal = 0;
}

- (void)addPoint:(NSDate *)date val:(NSString *)value{

    int dateSeconds = [date timeIntervalSince1970];
    if (!_minXVal || _minXVal > dateSeconds){
        _minXVal = dateSeconds;
    };
    if (!_maxXVal || _maxXVal < dateSeconds){
        _maxXVal = dateSeconds;
    };
    
    float indexValue = [value integerValue];
    if (!_minYVal || _minYVal > indexValue){
        _minYVal = indexValue;
    };
    if (!_maxYVal || _maxYVal < indexValue){
        _maxYVal = indexValue;
    };
    
    [self.chartData addObject:@[date, value]];
}


- (void)drawChart{
    [_mainGraph setNeedsLayout];
    [_mainGraph setNeedsDisplay];
    [_bottomGraph setNeedsDisplay];
    [_bottomGraph setNeedsLayout];
}

@end
