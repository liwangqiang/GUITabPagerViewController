//
//  ViewController.m
//  GUITabPagerViewController
//
//  Created by Guilherme Araújo on 27/02/15.
//  Copyright (c) 2015 Guilherme Araújo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <GUITabPagerDataSource, GUITabPagerDelegate>

@end

@implementation ViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setDataSource:self];
  [self setDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self reloadData];
}

#pragma mark - Tab Pager Data Source

- (NSInteger)numberOfViewControllers {
  return 5;
}

- (UIViewController *)viewControllerForIndex:(NSInteger)index {
  UIViewController *vc = [UIViewController new];
  [[vc view] setBackgroundColor:[UIColor colorWithRed:arc4random_uniform(255) / 255.0f
                                                green:arc4random_uniform(255) / 255.0f
                                                 blue:arc4random_uniform(255) / 255.0f alpha:1]];
  return vc;
}

// Implement either viewForTabAtIndex: or titleForTabAtIndex:
//- (UIView *)viewForTabAtIndex:(NSInteger)index {
//    
//    UIView *subview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 60, 10)];
//    subview.layer.cornerRadius = 8 ;
//    subview.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0f green:arc4random_uniform(255)/255.0f blue:arc4random_uniform(255)/255 alpha:1];
//    
//  return subview;
//}

- (NSString *)titleForTabAtIndex:(NSInteger)index {
  return [NSString stringWithFormat:@"Tab #%ld", (long) index + 1];
}

- (CGFloat)tabHeight {
  // Default: 44.0f
  return 40.0f;
}

- (UIColor *)tabColor {
//   Default: [UIColor orangeColor];
  return [UIColor colorWithRed:arc4random_uniform(255)/255.0f green:arc4random_uniform(255)/255.0f blue:arc4random_uniform(255)/255.0f alpha:0.5];
}

//- (UIColor *)tabBackgroundColor {
//  // Default: [UIColor colorWithWhite:0.95f alpha:1.0f];
//}

- (UIFont *)titleFont {
  // Default: [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.0f];
    return [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
}

#pragma mark - Tab Pager Delegate

- (void)tabPager:(GUITabPagerViewController *)tabPager willTransitionToTabAtIndex:(NSInteger)index {
  NSLog(@"Will transition from tab %ld to %ld", [self selectedIndex], (long)index);
}

- (void)tabPager:(GUITabPagerViewController *)tabPager didTransitionToTabAtIndex:(NSInteger)index {
  NSLog(@"Did transition to tab %ld", (long)index);
}

@end
