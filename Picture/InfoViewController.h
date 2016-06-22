//
//  InfoViewController.h
//  Picture
//
//  Created by 金柯 on 14-5-1.
//  Copyright (c) 2014年 jk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import <MessageUI/MFMailComposeViewController.h>

@class ViewController;
@interface InfoViewController : UITableViewController<UIAlertViewDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic) ViewController * delegate;

@end
