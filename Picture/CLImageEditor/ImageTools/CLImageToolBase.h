//
//  CLImageToolBase.h
//
//  Created by sho yakushiji on 2013/10/17.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ViewController.h"


static const CGFloat kCLImageToolAnimationDuration = 0.3;
static const CGFloat kCLImageToolFadeoutDuration   = 0.2;



@interface CLImageToolBase : NSObject
{
    
}
@property (nonatomic, weak) ViewController *editor;

+ (UIImage*)iconImage;
+ (CGFloat)dockedNumber;
+ (NSString*)title;
+ (BOOL)isAvailable;


- (id)initWithImageEditor:( ViewController* )editor;

- (void)setup;
- (void)cleanup;
- (void)executeWithCompletionBlock:(void(^)(UIImage *image, NSError *error, NSDictionary *userInfo))completionBlock;

@end
