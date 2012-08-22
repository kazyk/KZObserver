//
//  KZAppDelegate.h
//  KZObserver
//
//  Created by kazuyuki takahashi on 04/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KZViewController;

@interface KZAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) KZViewController *viewController;

@end