//
//  AdBannerCell.h
//  iNotePlus
//
//  Created by 金 柯 on 13-11-10.
//
//

#import <UIKit/UIKit.h>


@class InfoViewController;
@interface EffectCell : UITableViewCell 
{
	
}

@property (nonatomic, assign) InfoViewController * delegate;
@property (nonatomic,retain)  UITableView *parenttableView;
@property (nonatomic, retain) UILabel * mylabelColor;
@property (nonatomic, retain) UITextField * myTextField;
@property (nonatomic, assign) int indexRow;

- (void)cellDidLoad;
- (void)cellWillAppear;
@end
