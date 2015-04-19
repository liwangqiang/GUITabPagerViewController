//
//  TabPagerViewController.m
//  GUITabPagerViewController
//
//  Created by 李王强 on 15/4/18.
//  Copyright (c) 2015年 Guilherme Araújo. All rights reserved.
//

#import "TabPagerViewController.h"
#import "GUITabScrollView.h"

@implementation TabPagerViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    GUITabScrollView *tab = [[GUITabScrollView alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 20) tabViews:@[[[UILabel alloc]init]] tabBarHeight:40 tabColor:[UIColor orangeColor] backgroundColor:[UIColor grayColor]];
    
    [self.view addSubview:tab];
}

@end
