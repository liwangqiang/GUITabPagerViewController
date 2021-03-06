//
//  GUITabPagerViewController.m
//  GUITabPagerViewController
//
//  Created by Guilherme Araújo on 26/02/15.
//  Copyright (c) 2015 Guilherme Araújo. All rights reserved.
//

#import "GUITabPagerViewController.h"
#import "GUITabScrollView.h"

#define MaxLabelWidth 70

@interface GUITabPagerViewController () <GUITabScrollDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) GUITabScrollView *header;
@property (assign, nonatomic) NSInteger selectedIndex;

@property (strong, nonatomic) NSMutableArray *viewControllers;
@property (strong, nonatomic) NSMutableArray *tabTitles;
@property (strong, nonatomic) UIColor *headerColor;
@property (strong, nonatomic) UIColor *tabBackgroundColor;
@property (assign, nonatomic) CGFloat headerHeight;

@end

@implementation GUITabPagerViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setEdgesForExtendedLayout:UIRectEdgeNone];
  
  [self setPageViewController:[[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:nil]];
  
  for (UIView *view in [[[self pageViewController] view] subviews]) {
    if ([view isKindOfClass:[UIScrollView class]]) {
      [(UIScrollView *)view setCanCancelContentTouches:YES];
      [(UIScrollView *)view setDelaysContentTouches:NO];
    }
  }
  
  [[self pageViewController] setDataSource:self];
  [[self pageViewController] setDelegate:self];
  
  [self addChildViewController:self.pageViewController];
  [self.view addSubview:self.pageViewController.view];
  [self.pageViewController didMoveToParentViewController:self];
}

- (void)viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];
  
  CGRect headerFrame = self.header.frame;
  headerFrame.origin.x = 0;
  headerFrame.origin.y = self.topLayoutGuide.length;
  headerFrame.size.height = self.headerHeight;
  headerFrame.size.width = self.view.bounds.size.width;
  self.header.frame = headerFrame;
  
  CGRect pageViewFrame = self.pageViewController.view.frame;
  pageViewFrame.origin.y = headerFrame.origin.y + headerFrame.size.height;
  pageViewFrame.origin.x = 0;
  pageViewFrame.size.width = self.view.bounds.size.width;
  pageViewFrame.size.height = self.view.bounds.size.height - self.topLayoutGuide.length - self.bottomLayoutGuide.length - headerFrame.size.height;
  self.pageViewController.view.frame = pageViewFrame;
  
  [self.view layoutIfNeeded];
  [self.view setNeedsLayout];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Page View Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
  NSUInteger pageIndex = [[self viewControllers] indexOfObject:viewController];
  return pageIndex > 0 ? [self viewControllers][pageIndex - 1]: nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
  NSUInteger pageIndex = [[self viewControllers] indexOfObject:viewController];
  return pageIndex < [[self viewControllers] count] - 1 ? [self viewControllers][pageIndex + 1]: nil;
}

#pragma mark - Page View Delegate

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
  NSInteger index = [[self viewControllers] indexOfObject:pendingViewControllers[0]];
  [[self header] animateToTabAtIndex:index];
  
  if ([[self delegate] respondsToSelector:@selector(tabPager:willTransitionToTabAtIndex:)]) {
    [[self delegate] tabPager:self willTransitionToTabAtIndex:index];
  }
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
  [self setSelectedIndex:[[self viewControllers] indexOfObject:[[self pageViewController] viewControllers][0]]];
  [[self header] animateToTabAtIndex:[self selectedIndex]];
  
  if ([[self delegate] respondsToSelector:@selector(tabPager:didTransitionToTabAtIndex:)]) {
    [[self delegate] tabPager:self didTransitionToTabAtIndex:[self selectedIndex]];
  }
}

#pragma mark - Tab Scroll View Delegate

- (void)tabScrollView:(GUITabScrollView *)tabScrollView didSelectTabAtIndex:(NSInteger)index {
  if (index != [self selectedIndex]) {
    if ([[self delegate] respondsToSelector:@selector(tabPager:willTransitionToTabAtIndex:)]) {
      [[self delegate] tabPager:self willTransitionToTabAtIndex:index];
    }
    
    [[self pageViewController]  setViewControllers:@[[self viewControllers][index]]
                                         direction:(index > [self selectedIndex]) ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse
                                          animated:YES
                                        completion:^(BOOL finished) {
                                          [self setSelectedIndex:index];
                                          
                                          if ([[self delegate] respondsToSelector:@selector(tabPager:didTransitionToTabAtIndex:)]) {
                                            [[self delegate] tabPager:self didTransitionToTabAtIndex:[self selectedIndex]];
                                          }
                                        }];
  }
}

- (void)reloadData {
  [self setViewControllers:[NSMutableArray array]];
  [self setTabTitles:[NSMutableArray array]];
  
  for (int i = 0; i < [[self dataSource] numberOfViewControllers]; i++) {
    UIViewController *viewController;
    
    if ((viewController = [[self dataSource] viewControllerForIndex:i]) != nil) {
      [[self viewControllers] addObject:viewController];
    }
    
    if ([[self dataSource] respondsToSelector:@selector(titleForTabAtIndex:)]) {
      NSString *title;
      if ((title = [[self dataSource] titleForTabAtIndex:i]) != nil) {
        [[self tabTitles] addObject:title];
      }
    }
  }
  
  [self reloadTabs];
  
  
  [self.pageViewController setViewControllers:@[[self viewControllers][0]]
                                    direction:UIPageViewControllerNavigationDirectionReverse
                                     animated:NO
                                   completion:nil];
  [self setSelectedIndex:0];
}

- (void)reloadTabs {
  if ([[self dataSource] numberOfViewControllers] == 0)
    return;
  
  if ([[self dataSource] respondsToSelector:@selector(tabHeight)]) {
    [self setHeaderHeight:[[self dataSource] tabHeight]];
  } else {
    [self setHeaderHeight:44.0f];
  }
  
  if ([[self dataSource] respondsToSelector:@selector(tabColor)]) {
    [self setHeaderColor:[[self dataSource] tabColor]];
  } else {
    [self setHeaderColor:[[UIColor orangeColor]colorWithAlphaComponent:0.3]];
  }
  
  if ([[self dataSource] respondsToSelector:@selector(tabBackgroundColor)]) {
    [self setTabBackgroundColor:[[self dataSource] tabBackgroundColor]];
  } else {
    [self setTabBackgroundColor:[UIColor colorWithWhite:0.95f alpha:1.0f]];
  }
  
  NSMutableArray *tabViews = [NSMutableArray array];
  
  if ([[self dataSource] respondsToSelector:@selector(viewForTabAtIndex:)]) {
    for (int i = 0; i < [[self viewControllers] count]; i++) {
      UIView *view;
      if ((view = [[self dataSource] viewForTabAtIndex:i]) != nil) {
        [tabViews addObject:view];
      }
    }
  } else {
    UIFont *font;
    if ([[self dataSource] respondsToSelector:@selector(titleFont)]) {
      font = [[self dataSource] titleFont];
    } else {
      font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    }
    for (NSString *title in [self tabTitles]) {
      UILabel *label = [UILabel new];
      [label setText:title];
      [label setTextAlignment:NSTextAlignmentCenter];
      [label setFont:font];
      [label sizeToFit];
      
      CGRect frame = [label frame];
      frame.size.width = MAX(frame.size.width + 20, MaxLabelWidth);
      [label setFrame:frame];
      [tabViews addObject:label];
    }
  }
  
  if ([self header]) {
    [[self header] removeFromSuperview];
  }
  
  [self setHeader:[[GUITabScrollView alloc] initWithFrame:CGRectZero tabViews:tabViews tabBarHeight:[self headerHeight] tabColor:[self headerColor] backgroundColor:[self tabBackgroundColor]]];
  [[self header] setTabScrollDelegate:self];
  
  [[self view] addSubview:[self header]];
}

@end

