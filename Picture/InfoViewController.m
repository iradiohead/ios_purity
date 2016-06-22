//
//  InfoViewController.m
//  Picture
//
//  Created by 金柯 on 14-5-1.
//  Copyright (c) 2014年 jk. All rights reserved.
//

#import "InfoViewController.h"
//#import "GADBannerView.h"
#import "GoogleMobileAds/GADInterstitial.h"
#import "GoogleMobileAds/GADBannerView.h"
#import "EffectCell.h"

@interface InfoViewController ()

@property (nonatomic, retain) NSArray *arrayEffect;
@property(nonatomic, strong)  GADBannerView * banner;

@end

@implementation InfoViewController



- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.arrayEffect = @[@"Blur", @"Filter"];
    }
    return self;
}

- (void)viewDidLoad
{
    //a1536243d601933
    [super viewDidLoad];
    
   	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(Done:)];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor]; //background
    self.navigationController.navigationBar.tintColor = NAVIGATORBAR_CUS_TITLE_COLOR;// edit and add button color
    
    self.tableView.backgroundColor = BGVIEWCOLOR;
    
    
 
    //-------
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,80)];
    //
    //----
    
    self.banner = [[GADBannerView alloc] initWithFrame:CGRectMake(0, 0,//ScreenHeight-64-50-44,
                                                                  CGRectGetWidth(self.tableView.frame),
                                                                  GAD_SIZE_320x50.height)];
    
    
    self.banner.adUnitID = @"ca-app-pub-2492190986050641/7878704817";
    self.banner.rootViewController = self;
    [self.view addSubview:self.banner];
    [self.banner loadRequest:[GADRequest request]];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.arrayEffect count];;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //cell.backgroundColor = [UIColor grayColor];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 2)
    {
        return 66;
    }
    else
        return 44;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.section == 0 )
    {
        static NSString *CellIdentifier = @"Cell";
        EffectCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            // cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            cell = [[EffectCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.delegate = self;
            cell.parenttableView = self.tableView;
            [cell cellDidLoad];
        }
        cell.indexRow = indexPath.row;
        [cell cellWillAppear];
        cell.textLabel.text = self.arrayEffect[indexPath.row];
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    else if( indexPath.section == 1 )
    {
        static NSString *CellIdentifier = @"Cell2";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        if(indexPath.row == 0)
        {
            cell.textLabel.text = @"Rate in App Store";
        }
        else if(indexPath.row == 1)
        {
            cell.textLabel.text = @"Support";
          //  cell.detailTextLabel.text = @"Contact us";
        }
        return cell;
    }
    else if(indexPath.section == 2)
    {
    	static NSString *CellIdentifier = @"Cell3";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            [cell.detailTextLabel setNumberOfLines:2];
        }
        if(indexPath.row == 0)
        {
            UIImage *image = [UIImage imageNamed:@"NoteTodolink"];
            cell.imageView.image = image;
            cell.textLabel.text = @"Note + ToDo";
            cell.detailTextLabel.text = @"Millions use it every day to remember all the things they want to do and make sure to get it done";
        }
        else if(indexPath.row == 1)
        {
            UIImage *image = [UIImage imageNamed:@"evermemo"];
            cell.imageView.image = image;
            cell.textLabel.text = @"Evermemo";
            cell.detailTextLabel.text = @"An powerful, free app that helps you remember everything";
        }
        return cell;
    }
    return nil;
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[self dismissModalViewControllerAnimated:YES];
}

- (NSString *) yesButtonTitle
{
    return @"Yes";
}

- (NSString *) noButtonTitle
{
    return @"No";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.section == 0)
	{
		if(indexPath.row == 0)
	    {
	        g_eEffect = enumBlur;
            [self.delegate setCurrentToolByEnum:enumBlur];
            [self.delegate ShowTool:enumBlur];
            
	        NSIndexPath * indexPathTemp = [NSIndexPath indexPathForRow:1 inSection:0];
	        EffectCell *cell = (EffectCell *)[tableView cellForRowAtIndexPath:indexPathTemp];
	        cell.mylabelColor.hidden = YES;
	        
	        NSIndexPath * indexPathTemp2 =   [NSIndexPath indexPathForRow:2 inSection:0];
	        EffectCell *cell2 = (EffectCell *)[tableView cellForRowAtIndexPath:indexPathTemp2];
	        cell2.mylabelColor.hidden = YES;
	    }
	    else if(indexPath.row == 1)
	    {
	        g_eEffect = enumFilters;
            [self.delegate setCurrentToolByEnum:enumFilters];
            [self.delegate ShowTool:enumFilters];
            
	        NSIndexPath * indexPathTemp =   [NSIndexPath indexPathForRow:0 inSection:0];
	        EffectCell *cell = (EffectCell *)[tableView cellForRowAtIndexPath:indexPathTemp];
	        cell.mylabelColor.hidden = YES;
	        
	        NSIndexPath * indexPathTemp2 =   [NSIndexPath indexPathForRow:2 inSection:0];
	        EffectCell *cell2 = (EffectCell *)[tableView cellForRowAtIndexPath:indexPathTemp2];
	        cell2.mylabelColor.hidden = YES;
	    }
	    else if(indexPath.row == 2)
	    {
	        g_eEffect = enumCreatemodifydate;
	        NSIndexPath * indexPathTemp =   [NSIndexPath indexPathForRow:0 inSection:0];
	        EffectCell *cell = (EffectCell *)[tableView cellForRowAtIndexPath:indexPathTemp];
	        cell.mylabelColor.hidden = YES;
	        
	        NSIndexPath * indexPathTemp2 =   [NSIndexPath indexPathForRow:1 inSection:0];
	        EffectCell *cell2 = (EffectCell *)[tableView cellForRowAtIndexPath:indexPathTemp2];
	        cell2.mylabelColor.hidden = YES;
	    }
	   
	    EffectCell *cell2 = (EffectCell *)[tableView cellForRowAtIndexPath:indexPath];
	    cell2.mylabelColor.hidden = NO;
	    
	   // [self tableView:tableView cellForRowAtIndexPath:indexPath];
	   // [tableView deselectRowAtIndexPath:indexPath animated:NO];//选中后的反显颜色即刻消失
	    
	    //[self.navigationController popToRootViewControllerAnimated:YES];
	}
    else if(indexPath.section == 1)
    {
        if( indexPath.row == 0)
        {
            UIAlertView *someError1 = [[UIAlertView alloc] initWithTitle: @"Rate in APP Store" message: @"Do you wang to exit this application so you can rate it in the iTunes App Store?"
                                                                delegate: self cancelButtonTitle:[self noButtonTitle] otherButtonTitles:[self yesButtonTitle], nil];
            someError1.tag = 1;
            [someError1 show];
        
        }
        else if( indexPath.row == 1)
        {
            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            picker.mailComposeDelegate = self;
            [picker setSubject:@"PhotoCap 2 - Support"];
            [picker setToRecipients:@[@"kjin1983@gmail.com"]];
            [picker setMessageBody:nil isHTML:NO];
            [self presentViewController:picker animated:YES completion:nil];
            
        }
       // [tableView deselectRowAtIndexPath:indexPath animated:NO];//选中后的反显颜色即刻消失
    }
    
    else if(indexPath.section == 2 && indexPath.row == 0) 
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com//app/note-+-todo/id864587245?ls=1&mt=8"]];
    }
    else if(indexPath.section == 2 && indexPath.row == 1) 
    {
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/evermemo-to-do-list/id777619095?ls=1&mt=8"]];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];//选中后的反显颜色即刻消失
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) //rate in app (evermemo)
    {
        NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
        if ([buttonTitle isEqualToString:[self yesButtonTitle]])
        {
            BOOL bOpen = [[UIApplication sharedApplication] openURL:
                          [NSURL URLWithString:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=875253920"]];
            NSLog(@"User pressed the Yes button ==%d ",bOpen);
            
            //link to an app homepage
            //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/us/app/just-to-do/id727040242?ls=1&mt=8"]];
        }
        else if ([buttonTitle isEqualToString:[self noButtonTitle]])
        {
            NSLog(@"User pressed the No button.");
        }
    }
    else if(alertView.tag == 2)
    {
        
    }
}
//--------------------------------------------
#pragma mark - button action
-(void)Done:(id) sender
{
    [self dismissViewControllerAnimated:YES
                             completion:^(void){
                                 // Code
                             }];
}

@end
