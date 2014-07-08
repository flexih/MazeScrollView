//
//  ViewController.m
//  Demo
//
//  Created by flexih on 7/8/14.
//  Copyright (c) 2014 flexih. All rights reserved.
//

#import "ViewController.h"
#import "MazeScrollView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    MazeScrollView *mazeScrollView = [[MazeScrollView alloc] initWithFrame:self.view.bounds];
    
    mazeScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) * 3);
    mazeScrollView.showsVerticalScrollIndicatorAlways = YES;
    
    [self.view addSubview:mazeScrollView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
