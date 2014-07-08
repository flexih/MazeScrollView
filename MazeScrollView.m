//
//  MazeScrollView.m
//  MazeScrollView
//
//  Created by flexih on 7/3/14.
//  Copyright (c) 2014 flexih. All rights reserved.
//

#import "MazeScrollView.h"

@interface MazeScrollView ()

@property (nonatomic, strong) UIImageView *vertical_indicator_view;
@property (nonatomic, strong) UIImageView *horizontal_indicator_view;

@end

enum {
    k_scroll_indicator_vertical,
    k_scroll_indicator_horizontal
};

static const CGFloat scroll_indicator_margin         = 2.5;
static const CGFloat scroll_indicator_margin_exclude = 6.5;
static const CGFloat scroll_indicator_min            = 7;
static const CGFloat scroll_indicator_factor         = 0.25;

static
CGFloat scroll_indicator_round(CGFloat valf)
{
    static NSDecimalNumberHandler *handler;
    
    if (handler == nil) {
        handler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                                         scale:1
                                                              raiseOnExactness:NO
                                                               raiseOnOverflow:NO
                                                              raiseOnUnderflow:NO
                                                           raiseOnDivideByZero:NO];
    }
    
    NSDecimalNumber *decimal = [[NSDecimalNumber alloc] initWithDouble:(double)valf];
    
    decimal = [decimal decimalNumberByRoundingAccordingToBehavior:handler];
    
    valf = [decimal doubleValue];
    
    CGFloat diff = valf - ((long)valf + 0.5);
    
    if (diff > scroll_indicator_factor) {
        valf = (long)valf + 1;
    } else if (diff < -scroll_indicator_factor) {
        valf = (long)valf;
    } else {
        valf = (long)valf + 0.5;
    }
    
    return valf;
}

static
void scroll_indicator_position(MazeScrollView *scrollView, int indicatorType)
{
    CGFloat contentsz = indicatorType == k_scroll_indicator_vertical ? scrollView.contentSize.height : scrollView.contentSize.width;
    CGFloat boundsz = indicatorType == k_scroll_indicator_vertical ? scrollView.bounds.size.height : scrollView.bounds.size.width;
    CGFloat offset = indicatorType == k_scroll_indicator_vertical ? scrollView.contentOffset.y : scrollView.contentOffset.x;
    CGFloat maxOffset = contentsz - boundsz;
    CGFloat indicatorsz = scroll_indicator_round((boundsz - scroll_indicator_margin) / contentsz * (boundsz - scroll_indicator_margin));
    CGFloat indicatorScrollsz = boundsz - indicatorsz - scroll_indicator_margin * 2;
    CGFloat indicator;
    
    if (offset < 0) {
        indicator = offset + scroll_indicator_margin;
        indicatorsz += offset;
        
        if (indicatorsz < scroll_indicator_min) {
            indicatorsz = scroll_indicator_min;
        }
        
    } else if (offset > maxOffset) {
        CGFloat indicator_sz = indicatorsz;
        
        indicatorsz -= offset - maxOffset;
        
        if (indicatorsz < scroll_indicator_min) {
            indicatorsz = scroll_indicator_min;
        }
        
        indicator = indicator_sz - indicatorsz + offset + indicatorScrollsz + scroll_indicator_margin;
        
    } else {
        indicator = offset / maxOffset * indicatorScrollsz + offset + scroll_indicator_margin;
        indicator = scroll_indicator_round(indicator);
    }
    
    BOOL moreExclude = NO;
    
    if (indicatorType == k_scroll_indicator_vertical) {
        moreExclude = scrollView.showsHorizontalScrollIndicator || scrollView.showsHorizontalScrollIndicatorAlways;
    } else {
        moreExclude = scrollView.showsVerticalScrollIndicator || scrollView.showsVerticalScrollIndicatorAlways;
    }
    
    if (moreExclude) {
        if (offset + boundsz - indicator - indicatorsz - scroll_indicator_margin_exclude < 0) {
            indicator = offset + boundsz - indicatorsz - scroll_indicator_margin_exclude;
        }
    }
    
    CGFloat sizemetric = indicatorType == k_scroll_indicator_vertical ? CGRectGetMaxX(scrollView.bounds) : CGRectGetMaxY(scrollView.bounds);
    
    if (indicatorType == k_scroll_indicator_vertical) {
        scrollView.vertical_indicator_view.frame = CGRectMake(sizemetric - 2 * scroll_indicator_margin, indicator, scroll_indicator_margin, indicatorsz);
    } else {
        scrollView.horizontal_indicator_view.frame = CGRectMake(indicator, sizemetric - 2 * scroll_indicator_margin, indicatorsz, scroll_indicator_margin);
    }
}

static
UIImage *scroll_indicator_default_image(UIScrollView *scrollView, int indicatorType)
{
    NSUInteger index =
    [scrollView.subviews indexOfObjectPassingTest:^BOOL(UIView *view, NSUInteger idx, BOOL *stop) {
        return [view isMemberOfClass:[UIImageView class]] &&
               (CGRectGetWidth(view.bounds) < CGRectGetHeight(view.bounds) || indicatorType);
    }];
    
    if (index != NSNotFound) {
        return [(UIImageView *)scrollView.subviews[index] image];
    }
    
    return nil;
}

@implementation MazeScrollView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.showsVerticalScrollIndicatorAlways) {
        scroll_indicator_position(self, k_scroll_indicator_vertical);
    }
    
    if (self.showsHorizontalScrollIndicatorAlways) {
        scroll_indicator_position(self, k_scroll_indicator_horizontal);
    }
}

- (void)setShowsVerticalScrollIndicatorAlways:(BOOL)showsVerticalScrollIndicatorAlways
{
    if (_showsVerticalScrollIndicatorAlways != showsVerticalScrollIndicatorAlways) {
        _showsVerticalScrollIndicatorAlways = showsVerticalScrollIndicatorAlways;
        
        if (showsVerticalScrollIndicatorAlways) {
            UIImage *image = scroll_indicator_default_image(self, k_scroll_indicator_vertical);
            
            NSAssert(image, @"defalut indicator image not found");
            
            if (image != nil) {
                self.vertical_indicator_view = [[UIImageView alloc] initWithImage:image];
                [self addSubview:self.vertical_indicator_view];
                self.showsVerticalScrollIndicator = NO;
            }
            
        } else {
            [self.vertical_indicator_view removeFromSuperview];
            self.vertical_indicator_view = nil;
        }
    }
}

- (void)setShowsHorizontalScrollIndicatorAlways:(BOOL)showsHorizontalScrollIndicatorAlways
{
    if (_showsHorizontalScrollIndicatorAlways != showsHorizontalScrollIndicatorAlways) {
        _showsHorizontalScrollIndicatorAlways = showsHorizontalScrollIndicatorAlways;
        
        if (showsHorizontalScrollIndicatorAlways) {
            UIImage *image = scroll_indicator_default_image(self, k_scroll_indicator_horizontal);
            
            NSAssert(image, @"defalut indicator image not found");
            
            if (image != nil) {
                self.horizontal_indicator_view = [[UIImageView alloc] initWithImage:image];
                [self addSubview:self.horizontal_indicator_view];
                self.showsHorizontalScrollIndicator = NO;
            }
            
        } else {
            [self.horizontal_indicator_view removeFromSuperview];
            self.horizontal_indicator_view = nil;
        }
    }
}

- (void)didAddSubview:(UIView *)subview
{
    [super didAddSubview:subview];
    
    if (self.showsVerticalScrollIndicatorAlways) {
        [self bringSubviewToFront:self.vertical_indicator_view];
    }
    
    if (self.showsHorizontalScrollIndicatorAlways) {
        [self bringSubviewToFront:self.horizontal_indicator_view];
    }
}

- (void)setScrollIndicatorInsets:(UIEdgeInsets)scrollIndicatorInsets
{
    NSAssert(0, @"not support now");
}

@end
