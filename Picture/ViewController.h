//
//  ViewController.h
//  Picture
//
//  Created by 金柯 on 14-4-23.
//  Copyright (c) 2014年 jk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCNavigationController.h"

@interface ViewController : UIViewController<UIActionSheetDelegate,UIImagePickerControllerDelegate,UITextViewDelegate , UMSocialUIDelegate>


@property (nonatomic,strong) IBOutlet UIImageView *myImageView;
@property (nonatomic,strong) IBOutlet UIScrollView *myScrollView;
@property (nonatomic,strong) IBOutlet UITextView *myTextView;

@property (nonatomic,strong) IBOutlet UIButton *myTextureButton;
@property (nonatomic,strong) IBOutlet UIButton *myBGButton;
@property (nonatomic,strong) IBOutlet UIButton *myTextButton;
@property (nonatomic,strong) IBOutlet UIButton *myPhotoButton;
@property (nonatomic,strong) IBOutlet UIButton *myDoneButton;
@property (nonatomic,strong) IBOutlet UIButton *myDeleteButton;
@property (nonatomic,strong) IBOutlet UIButton *myInfoButton;



//- (id)initWithImage:(UIImage *)image;
-(void)handleChangeTexture:(id)sender;
-(void)handleChangeBG:(id)sender;
-(void)handlePhoto:(id)sender;
-(void)handleDone:(id)sender;
-(void)handleDelete:(id)sender;

//for infoviewcontroller
- (void)setCurrentToolByEnum:(EnumEffect) eEffect;
- (void)ShowTool:(EnumEffect) eEffect;

@end
