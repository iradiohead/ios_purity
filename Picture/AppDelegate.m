//
//  AppDelegate.m
//  Picture
//
//  Created by 金柯 on 14-4-23.
//  Copyright (c) 2014年 jk. All rights reserved.
//

#import "AppDelegate.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //youmeng //use purity youmeng id
    [UMSocialData setAppKey:@"54d57f0afd98c50e66001647"];
    //weixin  // use own weixin id already
    [UMSocialWechatHandler setWXAppId:@"wx14e17d8f87f12495" appSecret:@"1deaaf32f796bc9a9d4596ce4cf72ad3" url:@"https://itunes.apple.com/us/app/purity-over/id965173625?l=zh&ls=1&mt=8"];
    
    //instergram
    [UMSocialInstagramHandler openInstagramWithScale:NO paddingColor:[UIColor blackColor]];
    
    //what's app
    [UMSocialWhatsappHandler openWhatsapp:UMSocialWhatsappMessageTypeImage];
    
    //line
    [UMSocialLineHandler openLineShare:UMSocialLineMessageTypeImage];
    
    //tumblr
    [UMSocialTumblrHandler openTumblr];
    
    //sina weibo  // still use photocap2
    [UMSocialSinaHandler openSSOWithRedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    
    
    //--------------
    NSFileManager *fileManager2 = [NSFileManager defaultManager];
	NSString *filePath = [self myFilePath:EFFECT_ARCHIVE];
	if([fileManager2 fileExistsAtPath:filePath])
    {
		NSNumber *aNumber = [NSKeyedUnarchiver unarchiveObjectWithFile:[self myFilePath:EFFECT_ARCHIVE]];
        g_eEffect = (EnumEffect)[aNumber unsignedIntegerValue];
    }
	else
	{
		g_eEffect = enumBlur;
	}
    //---------------
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // save sortby to disk
    NSNumber *countNumber = [NSNumber numberWithUnsignedInt:g_eEffect];
	[NSKeyedArchiver archiveRootObject:countNumber toFile:[self myFilePath:EFFECT_ARCHIVE]];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (NSString *)myFilePath:(NSString *)fileName
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:fileName];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  

    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [UMSocialSnsService  applicationDidBecomeActive];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if (RK_IS_IPAD)
    {
        return UIInterfaceOrientationMaskPortrait;
    }
    else
    {
        // return UIInterfaceOrientationMaskAll;
        return UIInterfaceOrientationMaskPortrait;
    }
}

//---
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [UMSocialSnsService handleOpenURL:url wxApiDelegate:nil];
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return  [UMSocialSnsService handleOpenURL:url wxApiDelegate:nil];
}

@end
