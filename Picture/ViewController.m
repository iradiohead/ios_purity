#import "ViewController.h"
#import "InfoViewController.h"
#import "CLImageTools.h"
#import "UIView+Frame.h"
#import "UIImage+Utility.h"
#import "CLBlurTool.h"
#import "CLFilterTool.h"
#include<AssetsLibrary/AssetsLibrary.h> 
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/UTCoreTypes.h>
//#import "WeixinSessionActivity.h"
//#import "WeixinTimelineActivity.h"
//#import "GADBannerView.h"
#import "GoogleMobileAds/GADInterstitial.h"
#import "GoogleMobileAds/GADBannerView.h"

@interface ViewController ()

@property (nonatomic, strong)  CLBlurTool * blurTool;
@property (nonatomic, strong)  CLFilterTool * filterTool;
@property (nonatomic, strong)  CLImageToolBase *currentTool;
@property (nonatomic, strong)  UIPopoverController *popOverVC;
@property (copy,   nonatomic)  NSString *lastChosenMediaType;
@property (nonatomic, strong)  UIButton * myKeyboardButton;
@property (nonatomic, strong)  NSArray * BGColorArray;
@property (nonatomic, strong)  NSArray * textColorArray;
@property (nonatomic, strong)  NSArray * fontArray;
@property (nonatomic, strong)  UIImage * oriImage;

@property (nonatomic)  int currentTEXTindex;
@property (nonatomic)  int currentTEXTUREindex;
@property (nonatomic)  int currentBGindex;
@property (nonatomic)  int currentFontIndex;
@property (nonatomic)  BOOL bShowingTool;
@property(nonatomic, strong)  GADBannerView * banner;

@end

@implementation ViewController
{
    float firstX;
    float firstY;
    
   
  //  UIImage *_originalImage;
}
//ios7 hide status bar
- (BOOL)prefersStatusBarHidden
{
    return YES;
}


#pragma mark image tool
- (void)setCurrentToolByEnum:(EnumEffect) eEffect
{
    if(eEffect == enumBlur)
    {
        self.currentTool = self.blurTool;
    }
    else if(eEffect == enumFilters)
    {
        self.currentTool = self.filterTool;
    }
    
}

- (void)setTool:(CLImageToolBase *) Tool
{
    [Tool cleanup];
    [Tool setup];
}

//FOR INFOVIEWCONTROLLER CALL
- (void)ShowTool:(EnumEffect) eEffect
{
    if(self.bShowingTool) // 如果当前模式不是图片模式，不用加载tool
    {
        //清空所有tool的UI
        [self.blurTool cleanup];
        [self.filterTool cleanup];
        //还原image为没处理过之前的image
        self.myImageView.image = self.oriImage;
        //设置当前tool的UI
        [self.currentTool setup];
    }
}

#pragma mark viewcontroller
- (void) initDatas
{
    self.BGColorArray = @[BGCOLOR0, BGCOLOR1, BGCOLOR2, BGCOLOR3, BGCOLOR4, BGCOLOR5
                          ,BGCOLOR6,BGCOLOR7,BGCOLOR8,BGCOLOR9,BGCOLOR10];
    self.textColorArray = @[TEXTCOLOR,Cornsilk,DarkGreen, Firebrick, Yellow, LightSkyBlue];
    
    self.fontArray = @[@"Lobster1.4",@"Avenir-Heavy", @"Age", @"ALoveofThunder",@"Venera900",@"TrendHMSlabOne",
                       @"TheanoDidot-Regular",@"Intro-Inline"];
    
    self.blurTool = [[CLBlurTool alloc] initWithImageEditor:self];
    self.filterTool = [[CLFilterTool alloc] initWithImageEditor:self];
    [self setCurrentToolByEnum:g_eEffect];
    self.bShowingTool = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //解决字体居中问题
    [self observeValueForKeyPath:nil ofObject:self.myTextView change:nil context:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initDatas];
    //backgound view color
    
    self.view.backgroundColor = BGVIEWCOLOR;
    //set imageview property
    NSLog(@"width = %f",ScreenWidth);
    self.myImageView.frame = CGRectMake(0, 0, ScreenWidth, ScreenWidth);
    self.myImageView.contentMode = UIViewContentModeScaleAspectFill;
    //证图片比例不变，但是是填充整个ImageView的，可能只有部分图片显示出来,compare with UIViewContentModeScaleAspectFit
    [self.myImageView setClipsToBounds:YES];//ipad need this if use UIViewContentModeScaleAspectFill, or else imageview will be bigger
    
    [self.view addSubview:self.myImageView];
  
    
    //1:textview
    self.myTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, 20, ScreenWidth-40, ScreenWidth-40)];
    self.myTextView.backgroundColor = [UIColor clearColor];
    self.myTextView.delegate = self;
    [self setTextandCursorColor:0];
    //[self setCursorColor:YES]; // GRAY
    self.myTextView.font = TEXTFONT;
    self.myTextView.text = DEFAULT_TEXT;
    
    self.currentFontIndex = 0;
    self.myTextView.font = [UIFont fontWithName:self.fontArray[self.currentFontIndex] size:FONTSIZE];
    self.myTextView.text = @"Text Here";
    //let text in the center of uitextview
    self.myTextView.textAlignment = NSTextAlignmentCenter;
    [self.myTextView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
    [self.view addSubview:self.myTextView];
    
    //set pangesture for textview
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [panGesture setMinimumNumberOfTouches:1];
    [panGesture setMaximumNumberOfTouches:1];
    [self.myTextView addGestureRecognizer:panGesture];
    
    //2:image view
    self.currentBGindex = 0; //white color
    self.myImageView.backgroundColor = self.BGColorArray[self.currentBGindex];//[UIColor redColor];
    self.currentTEXTUREindex = 0;
    NSString * imageName = [[NSString alloc] initWithFormat:@"1_%d.png", self.currentTEXTUREindex];
    UIImage * image =[[UIImage imageNamed:imageName] imageByApplyingAlpha:0.6];
    self.myImageView.image = image;

    //put textview as subview of imageview
    [self.myImageView addSubview:self.myTextView];
    [self.myImageView setUserInteractionEnabled:YES];
    [self.myTextView setUserInteractionEnabled:YES];
    //set tapgesture for imageview
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(whenClickImage:)];
    [self.myImageView addGestureRecognizer:singleTap];
    
    //3:keyboard button
    self.myKeyboardButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    if(RK_IS_IPHONE)
    {
        if(ScreenHeight == 480)
        {
            [self.myKeyboardButton setFrame:CGRectMake(ScreenWidth - 34, ScreenWidth - 114, 24, 24)];
        }
        else
        {
            [self.myKeyboardButton setFrame:CGRectMake(ScreenWidth - 34, ScreenWidth - 34, 24, 24)];
        }
    }
    else if(RK_IS_IPAD)
    {
        [self.myKeyboardButton setFrame:CGRectMake(ScreenWidth - 34, ScreenWidth - 94, 24, 24)];
    }
    [self.myKeyboardButton addTarget:self action:@selector(handleKeyBoardButtonClick) forControlEvents:UIControlEventTouchUpInside];
    //self.myKeyboardButton.backgroundColor = [UIColor redColor];
    [self.myKeyboardButton setBackgroundImage:[UIImage imageNamed:@"keyboard.png"] forState:UIControlStateNormal];
    self.myKeyboardButton.hidden = YES;
    [self.view addSubview:self.myKeyboardButton];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    //------set banner
    int height = ScreenHeight;
    NSLog(@"heithg = %d", height);
    self.banner = [[GADBannerView alloc] initWithFrame:CGRectMake(0, ScreenHeight-50,
                                                                  ScreenWidth,
                                                                  GAD_SIZE_320x50.height)];
    
    
    self.banner.adUnitID = @"ca-app-pub-2492190986050641/7878704817"; //use photocap2
    self.banner.rootViewController = self;
    [self.view addSubview:self.banner];
    [self.banner loadRequest:[GADRequest request]];
    //--------------------------
    
    //set buttons frame
    int x = (ScreenWidth - 48*5 )/6;
    int y = (ScreenHeight-ScreenWidth)/2 -24 + ScreenWidth;
    self.myTextureButton = [[UIButton alloc] initWithFrame:CGRectMake(x,y,48,48)];
    [self.myTextureButton setBackgroundImage:[UIImage imageNamed:@"texture.png"] forState:UIControlStateNormal];
    [self.myTextureButton addTarget:self action:@selector(handleChangeTexture:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.myTextureButton];
    
    self.myBGButton = [[UIButton alloc] initWithFrame:CGRectMake(x+48+x,y,48,48)];
    [self.myBGButton setBackgroundImage:[UIImage imageNamed:@"color.png"] forState:UIControlStateNormal];
    [self.myBGButton addTarget:self action:@selector(handleChangeBG:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.myBGButton];
    
    //font
    self.myTextButton = [[UIButton alloc] initWithFrame:CGRectMake(x+48+x+48+x, y, 48, 48)];
    [self.myTextButton setBackgroundImage:[UIImage imageNamed:@"font.png"] forState:UIControlStateNormal];
    [self.myTextButton addTarget:self action:@selector(handleChangeFont:) forControlEvents:UIControlEventTouchUpInside];
    
    //button长按事件
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(fontBtnLongPressHandle:)];
    longPress.minimumPressDuration = 0.6; //定义按的时间
    [self.myTextButton addGestureRecognizer:longPress];
    
    [self.view addSubview:self.myTextButton];
    
    self.myPhotoButton = [[UIButton alloc] initWithFrame:CGRectMake(x+48+x+48+x+48+x,y,48,48)];
    [self.myPhotoButton setBackgroundImage:[UIImage imageNamed:@"photo.png"] forState:UIControlStateNormal];
    [self.myPhotoButton addTarget:self action:@selector(handlePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.myPhotoButton];
    
    self.myDoneButton = [[UIButton alloc] initWithFrame:CGRectMake(x+48+x+48+x+48+x+48+x,y,48,48)];
    [self.myDoneButton setBackgroundImage:[UIImage imageNamed:@"done.png"] forState:UIControlStateNormal];
    [self.myDoneButton addTarget:self action:@selector(handleDone:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.myDoneButton];
    
    self.myDeleteButton = [[UIButton alloc] initWithFrame:CGRectMake(x+48+x,y,48,48)]; //bg button postion
    [self.myDeleteButton setBackgroundImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
    [self.myDeleteButton addTarget:self action:@selector(handleDelete:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.myDeleteButton];
    self.myDeleteButton.hidden = YES;
    
    //-------
    
   // self.myInfoButton = [[UIButton alloc] initWithFrame:CGRectMake(16, ScreenHeight-40, 24, 24)]; //bg button postion
   // [self.myInfoButton setBackgroundImage:[UIImage imageNamed:@"info.png"] forState:UIControlStateNormal];
    
    self.myInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.myInfoButton setImage:[UIImage imageNamed:@"info.png"]forState:UIControlStateNormal];
    [self.myInfoButton setFrame:CGRectMake (0,ScreenHeight-48,48,48)];
    [self.myInfoButton setContentMode : UIViewContentModeCenter ];
    
    [self.myInfoButton addTarget:self action:@selector(handleInfo:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.myInfoButton setShowsTouchWhenHighlighted : YES ];
    //[self.view addSubview:self.myInfoButton];
    
    NSLog(@"height = %f",ScreenHeight);
    //----

}

#pragma mark uitextview callback
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    dispatch_async(dispatch_get_main_queue(),
    ^{
        if([self.myTextView.text isEqualToString:DEFAULT_TEXT])
        {
            self.myTextView.text = @"";
        }
    });
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    //text在myTextView居中，IOS9之后出现了这个问题才调用了下面的函数，不知道原因：（
    [self observeValueForKeyPath:nil ofObject:self.myTextView change:nil context:nil];
}

#pragma mark keyboard callback
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    //NSDictionary* info = [aNotification userInfo];
    //CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.myKeyboardButton.hidden = NO;
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    self.myKeyboardButton.hidden = YES;
}

-(void)handleKeyBoardButtonClick
{
    [self.myTextView resignFirstResponder];
     NSLog(@"fsfsdfldk");
   // [self.navigationController popToRootViewControllerAnimated:YES];
}

//让文字在textview中间，imagepickerview选择图片后要调用这个，不然文字会跑到开头，分享后也要调用
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    UITextView *txtview = object;
    CGFloat topoffset = ([txtview bounds].size.height - [txtview contentSize].height * [txtview zoomScale])/2.0;
    topoffset = ( topoffset < 0.0 ? 0.0 : topoffset );
    txtview.contentOffset = (CGPoint){.x = 0, .y = -topoffset};
}

-(void)whenClickImage:(id)sender
{
    //UITapGestureRecognizer *singleTap = (UITapGestureRecognizer *)sender;
    
    [self.myTextView resignFirstResponder];
   // NSLog(@"%d",[singleTap view].tag]);
}

-(void)handlePanGesture:(id)sender
{
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
    NSLog(@"translatedPoint = %f, translatedPoint y = %f ",translatedPoint.x, translatedPoint.y);
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan)
    {
        firstX = [[sender view] center].x;
        firstY = [[sender view] center].y;
         NSLog(@"firstX = %f, firstY y = %f ",firstX, firstY);
       
    }
    translatedPoint = CGPointMake(firstX + translatedPoint.x, firstY + translatedPoint.y);
    if(RK_IS_IPHONE)
    {
        if( translatedPoint.x > 300 ||  translatedPoint.y > 300  ||translatedPoint.x < 20 || translatedPoint.y <20)
        {
           // NSLog(@"fsdf");
            return;
        }
    }
    else if(RK_IS_IPAD)
    {
        if( translatedPoint.x > 700 ||  translatedPoint.y > 700  ||translatedPoint.x < 20 || translatedPoint.y <20)
        {
            // NSLog(@"fsdf");
            return;
        }
    }
    // NSLog(@"translatedPoint2222x = %f, translatedPoint222y = %f ",translatedPoint.x , translatedPoint.y);
    [[sender view] setCenter:translatedPoint];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark Button callback
-(void)handleChangeBG:(id)sender
{
    int colorIndex = (self.currentBGindex+1)%self.BGColorArray.count;
    self.myImageView.backgroundColor = self.BGColorArray[colorIndex];
   // self.myTextView.tintColor = self.textColorArray[colorIndex];
    self.currentBGindex = colorIndex;
    
    //
    if (self.currentBGindex != 0)
    {
      //  [self setCursorColor:NO];
    }
    else
    {
      //  [self setCursorColor:YES];
    }
}

-(void)handleChangeTexture:(id)sender
{
    dispatch_async(dispatch_get_global_queue(0, 0),
    ^{
        // 处理耗时操作的代码块...
        int index = (self.currentTEXTUREindex +1 )%12;
        NSString * imageName = [[NSString alloc] initWithFormat:@"1_%d.png",index];
        
        UIImage * image =[[UIImage imageNamed:imageName] imageByApplyingAlpha:0.6];
      //  UIImage * removeBlackImage = [[UIImage imageNamed:imageName] imageBlackToTransparent:image];
        self.currentTEXTUREindex = index;
        //通知主线程刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            //回调或者说是通知主线程刷新，
            self.myImageView.image = image;
            NSLog(@"imagename = %@", imageName);
           // [self setTool:self.filterTool];
        });
    });
        
    
 //   NSLog(@"imagename = %@", imageName);
   /* int colorIndex = (self.currentTCindex+1)%self.textColorArray.count;
    self.myTextView.textColor = self.textColorArray[colorIndex];
    self.myTextView.tintColor = self.textColorArray[colorIndex];
    self.currentTCindex = colorIndex;*/
}

-(void)handleChangeFont:(id)sender
{
    int fontIndex = (self.currentFontIndex+1)%self.fontArray.count;
    NSString *fontName = self.fontArray[fontIndex];
    self.myTextView.font = [UIFont fontWithName:fontName size:FONTSIZE];
    //text在myTextView居中，IOS9之后出现了这个问题才调用了下面的函数，不知道原因：（
    [self observeValueForKeyPath:nil ofObject:self.myTextView change:nil context:nil];
    self.currentFontIndex = fontIndex;
}

-(void)fontBtnLongPressHandle:(UILongPressGestureRecognizer *)gestureRecognizer
{
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan)
    {
        NSLog(@"长按事件");
        UIActionSheet *popupQuery = [[UIActionSheet alloc]
                                     initWithTitle:@"Choose Text Color"
                                     delegate:self
                                     cancelButtonTitle:@"Cancel"
                                     destructiveButtonTitle:nil
                                     otherButtonTitles:@"Azure4",@"Cornsilk",@"DarkGreen",@"Firebrick",@"Yellow",@"LightSkyBlue",nil];
        
        popupQuery.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        popupQuery.tag = 3;
        [popupQuery showInView:self.view];
        
    }
}

-(void)handlePhoto:(id)sender
{
    UIActionSheet *popupQuery = [[UIActionSheet alloc]
                             initWithTitle:@"Use Camera or Library?"
                             delegate:self
                             cancelButtonTitle:@"Cancel"
                             destructiveButtonTitle:nil
                             otherButtonTitles:@"Camera",@"Library",nil];

    popupQuery.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    popupQuery.tag = 2;
    [popupQuery showInView:self.view];
}

-(void)handleDone:(id)sender
{
    UIActionSheet *popupQuery = [[UIActionSheet alloc]
                                 initWithTitle:@"Share to Your Friends or Save to Photo Album?"
                                 delegate:self
                                 cancelButtonTitle:@"Cancel"
                                 destructiveButtonTitle:nil
                                 otherButtonTitles:@"Share",@"Save",nil];
    
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    popupQuery.tag = 1;
    [popupQuery showInView:self.view];
}
/*  如果这个接口打开，用户无法输入文字，直接发送
-(BOOL)isDirectShareInIconActionSheet
{
    return YES;
}*/

-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的微博平台名
        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
    }
    NSLog(@"didFinishGetUMSocialDataInViewController is %d",response.responseCode);
    //[self observeValueForKeyPath:nil ofObject:self.myTextView change:nil context:nil];
    
    NSString * temp = self.myTextView.text;
    self.myTextView.text =temp;
   // NSLog(@"  self.myTextView.text is %@",  self.myTextView.text);
    [self.myTextView setNeedsDisplay];//  分享后文字消失
}


-(void)handleDelete:(id)sender
{
    [self handleChangeTexture:nil];
    
    [self.currentTool cleanup];
    self.bShowingTool = NO;
    [self setButtonsPosition:NO];
    
    if (self.currentBGindex != 0)
    {
        
    	//[self setCursorColor:NO];
    }
    else
    {
        if(self.currentTEXTindex == 1) // if bg is white and text color is white, should change text color to black
        {
            [self setTextandCursorColor:0];
        }
    	//[self setCursorColor:YES];
    }
}

-(void)handleInfo:(id)sender
{
   /* UMSocialData *socialData = [[UMSocialData alloc] initWithIdentifier:@"identifier"];
    UMSocialControllerServiceComment *socialControllerService = [[UMSocialControllerServiceComment alloc] initWithUMSocialData:socialData];
    
    UINavigationController *commentList = [socialControllerService getSocialCommentListController];
    [self presentModalViewController:commentList animated:YES];*/
    
    InfoViewController * infoVC = [[InfoViewController alloc] initWithStyle:UITableViewStyleGrouped];
    infoVC.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:infoVC];
    [self presentViewController:navigationController animated:YES completion:nil];
}

/*-(void)popupActivityView:( UIImage* )image
{
    NSMutableArray * activityItems = [[NSMutableArray alloc] init];
    
    //for weixin
    [activityItems addObject:image]; //iphone icon image
    
    NSArray *activities = (@[[[WeixinSessionActivity alloc] init], [[WeixinTimelineActivity alloc] init]]);
    
    UIActivityViewController * activityViewController = [[UIActivityViewController alloc]
                                                         initWithActivityItems:activityItems
                                                         applicationActivities:activities];
    [activityViewController setCompletionHandler:^(NSString *activityType, BOOL completed)
    {
        if([activityType isEqualToString: UIActivityTypeSaveToCameraRoll] && completed)
        {
        }
        if([activityType isEqualToString: UIActivityTypePostToWeibo])
        {
            NSLog(@"weobo");
        }
        if([activityType isEqualToString: @"WeixinSessionActivity"] && completed)
        {
            NSLog(@"WeixinSessionActivity");
        }
        if([activityType isEqualToString: @"WeixinTimelineActivity"] && completed)
        {
            NSLog(@"WeixinTimelineActivity");
        }
        
        if(completed)
        {
            UIButton *btnCustom1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            btnCustom1.layer.cornerRadius = 5;
            [btnCustom1 setTitle:@"Done" forState:UIControlStateNormal];
            btnCustom1.backgroundColor = COMBUTTONCOLOR;
            [btnCustom1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btnCustom1.titleLabel.font =COMPTEXTFONT;
            btnCustom1.frame = CGRectMake((ScreenWidth-80)/2, (ScreenHeight-32)/2, 80, 32);
            [self.view addSubview:btnCustom1];
            
            [UIView animateWithDuration:1 animations:^
            {
            	btnCustom1.alpha = 0;
                
            }
            completion:^(BOOL finished)
            {
           		
            }];
        }     
    }];
    
    activityViewController.excludedActivityTypes = (@[
     UIActivityTypeAssignToContact,
     UIActivityTypeMessage,
     UIActivityTypePrint,
     UIActivityTypeCopyToPasteboard
     ]);
    
    [self presentViewController:activityViewController animated:YES completion:NULL];
}*/

#pragma mark reposion buttons
- (void)setButtonsPosition:(BOOL) bPhoto
{
    if(bPhoto)
    {
        int scrollviewheight = self.myScrollView.bounds.size.height;
        int x = (ScreenWidth - 48*4 )/5;
        int y = (ScreenHeight-ScreenWidth-scrollviewheight)/2 -24 + ScreenWidth+scrollviewheight;
        
        self.myTextureButton.hidden = YES;
        self.myBGButton.hidden = YES;
        self.myDeleteButton.hidden = NO;
        
		[UIView animateWithDuration:0.3f
		                      delay:0
		                    options:UIViewAnimationOptionCurveEaseIn
		                  animations:^
		                   { 
		                  	  self.myDeleteButton.frame = CGRectMake(x, y, 48, 48);
                              self.myTextButton.frame = CGRectMake(x+48+x, y, 48, 48);
      						  self.myPhotoButton.frame = CGRectMake(x+48+x+48+x, y, 48, 48);
        					  self.myDoneButton.frame = CGRectMake(x+48+x+48+x+48+x, y, 48, 48);
		                  
			               }
			               completion:^(BOOL finished)
			               {
			               	
			               }
		];
    }
    else
    {
        int x = (ScreenWidth - 48*5 )/6;
        int y = (ScreenHeight-ScreenWidth)/2 -24 + ScreenWidth;
        
        self.myDeleteButton.hidden = YES;
        self.myTextureButton.hidden = NO;
        self.myBGButton.hidden = NO;
        
		[UIView animateWithDuration:0.3f
                      delay:0
                    options:UIViewAnimationOptionCurveEaseIn
                  animations:^
                   { 
                  	    self.myTextureButton.frame = CGRectMake(x, y, 48, 48);
				        self.myBGButton.frame = CGRectMake(x+48+x, y, 48, 48);
                        self.myTextButton.frame = CGRectMake(x+48+x+48+x, y, 48, 48);
				        self.myPhotoButton.frame = CGRectMake(x+48+x+48+x+48+x, y, 48, 48);
				        self.myDoneButton.frame =CGRectMake(x+48+x+48+x+48+x+48+x, y, 48, 48);
	               }
	               completion:^(BOOL finished)
	               {
                       
	               }
		];
    }
}

#pragma mark actionsheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == 1) //DONE
    {
        if (buttonIndex == 0)
        {
            [self.filterTool executeWithCompletionBlock:^(UIImage *image, NSError *error, NSDictionary *userInfo)
             {
                 if(error)
                 {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     [alert show];
                 }
                 
                 NSString * textInSocialNetwork = nil;
                 if([self.myTextView.text isEqualToString:DEFAULT_TEXT] || [self.myTextView.text isEqualToString:@""])
                 {
                     textInSocialNetwork = @"Purity";
                 }
                 else
                 {
                     textInSocialNetwork = self.myTextView.text;
                 }
                 
                 
                 UIImage * imageOnView = [self createImage:self.myImageView];
                 
                 [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage ;
                 
                 [UMSocialSnsService presentSnsIconSheetView:self
                                                      appKey:@"54d57f0afd98c50e66001647"
                                                   shareText:textInSocialNetwork
                                                  shareImage:imageOnView
                                             shareToSnsNames:[NSArray arrayWithObjects:
                                                              UMShareToInstagram,
                                                              UMShareToTwitter,
                                                              UMShareToFacebook,
                                                              UMShareToSina,
                                                              UMShareToTencent,
                                                              UMShareToWechatSession,UMShareToWechatTimeline,UMShareToWechatFavorite,
                                                              UMShareToRenren,
                                                              UMShareToDouban,
                                                              UMShareToEmail,
                                                              UMShareToWhatsapp,
                                                              UMShareToLine,
                                                              UMShareToTumblr,
                                                              
                                                              nil]
                                                    delegate:self];
                 
                 
             }];
        }
        else if(buttonIndex == 1)
        {
            [self.filterTool executeWithCompletionBlock:^(UIImage *image, NSError *error, NSDictionary *userInfo)
             {
                 if(error)
                 {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     [alert show];
                 }
                 
                 [self SaveImageToAlbum:self.myImageView];
                 
             }];
        }
    }
    else if(actionSheet.tag ==2) // camera 
    {
        if (buttonIndex == 0)
        {
            SCNavigationController *nav = [[SCNavigationController alloc] init];
            nav.scNaigationDelegate = self;
            [nav showCameraWithParentController:self];
            //[self pickMediaFromSource:UIImagePickerControllerSourceTypeCamera];
            //camera
        }
        else if(buttonIndex == 1)
        {
            //libaray
            [self pickMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
        }
    }
    else if(actionSheet.tag ==3) // text color
    {
        if(buttonIndex>=0 && buttonIndex <=5)
        {
            [self setTextandCursorColor:buttonIndex];
        }
    }
}

/*- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    if(actionSheet.tag ==3) // text color
    {
        int i =0 ;
        for (UIView *subview in actionSheet.subviews)
        {
            i++;
            if ([subview isKindOfClass:[UIButton class]])
            {
                NSLog(@"HERE4");
                UIButton *button = (UIButton *)subview;
                if(i==3) //first one button
                {
                    NSLog(@"HERE2");
                    [button setTitleColor:self.textColorArray[0] forState:UIControlStateHighlighted];
                    [button setTitleColor:self.textColorArray[0] forState:UIControlStateNormal];
                    [button setTitleColor:self.textColorArray[0] forState:UIControlStateSelected];
                    //[button setBackgroundColor:self.textColorArray[0]];
                }
                else if(i == 4)
                {
                    NSLog(@"HERE3");
                    [button setTitleColor:self.textColorArray[1] forState:UIControlStateHighlighted];
                    [button setTitleColor:self.textColorArray[1] forState:UIControlStateNormal];
                    [button setTitleColor:self.textColorArray[1] forState:UIControlStateSelected];
                    //[button setBackgroundColor:self.textColorArray[1]];
                }
                else if(i == 5)
                {
                    NSLog(@"HERE3");
                    [button setTitleColor:self.textColorArray[2] forState:UIControlStateHighlighted];
                    [button setTitleColor:self.textColorArray[2] forState:UIControlStateNormal];
                    [button setTitleColor:self.textColorArray[2] forState:UIControlStateSelected];
                    //[button setBackgroundColor:self.textColorArray[2]];
                }
                else if(i == 6)
                {
                    NSLog(@"HERE3");
                    [button setTitleColor:self.textColorArray[3] forState:UIControlStateHighlighted];
                    [button setTitleColor:self.textColorArray[3] forState:UIControlStateNormal];
                    [button setTitleColor:self.textColorArray[3] forState:UIControlStateSelected];
                }
                else if(i == 7)
                {
                    NSLog(@"HERE3");
                    [button setTitleColor:self.textColorArray[4] forState:UIControlStateHighlighted];
                    [button setTitleColor:self.textColorArray[4] forState:UIControlStateNormal];
                    [button setTitleColor:self.textColorArray[4] forState:UIControlStateSelected];
                }
                else if(i == 8)
                {
                    NSLog(@"HERE3");
                    [button setTitleColor:self.textColorArray[5] forState:UIControlStateHighlighted];
                    [button setTitleColor:self.textColorArray[5] forState:UIControlStateNormal];
                    [button setTitleColor:self.textColorArray[5] forState:UIControlStateSelected];
                }
                else if(i == 9)
                {
                    NSLog(@"HERE3");
                    [button setTitleColor:self.textColorArray[6] forState:UIControlStateHighlighted];
                    [button setTitleColor:self.textColorArray[6] forState:UIControlStateNormal];
                    [button setTitleColor:self.textColorArray[6] forState:UIControlStateSelected];
                }
                else if(i == 10)
                {
                    NSLog(@"HERE3");
                    [button setTitleColor:self.textColorArray[7] forState:UIControlStateHighlighted];
                    [button setTitleColor:self.textColorArray[7] forState:UIControlStateNormal];
                    [button setTitleColor:self.textColorArray[7] forState:UIControlStateSelected];
                }
            }
        }
    }
}*/

/*
-(void) setCursorColor:(BOOL)bGrayOrWhite //yes gray no:white
{
	if(bGrayOrWhite)
	{
		self.currentTEXTindex = 0;
        self.myTextView.textColor = self.textColorArray[self.currentTEXTindex];
        self.myTextView.tintColor = self.textColorArray[self.currentTEXTindex];
	}
	else
	{
		self.currentTEXTindex = 1;
        self.myTextView.textColor = self.textColorArray[self.currentTEXTindex];
        self.myTextView.tintColor = self.textColorArray[self.currentTEXTindex];
	}
}
 */

-(void)setTextandCursorColor:(NSInteger)textColorArrayIndex
{
    self.currentTEXTindex = (int)textColorArrayIndex;
    self.myTextView.textColor = self.textColorArray[textColorArrayIndex];
    self.myTextView.tintColor = self.textColorArray[textColorArrayIndex];
}

- (void)didTakePicture:(SCNavigationController*)navigationController image:(UIImage*)image
{
    [navigationController dismissViewControllerAnimated:YES
                                             completion:^(void){
                                                 // Code
                                             }];
    //[navigationController dismissModalViewControllerAnimated:YES];
    NSLog(@"test");
    self.myImageView.image = image;

    
    [self setTool:self.currentTool];
    self.bShowingTool = YES;
    
    [self setButtonsPosition:YES];

    if(self.currentTEXTindex == 0)
    {
        [self setTextandCursorColor:1];
    }
    [self observeValueForKeyPath:nil ofObject:self.myTextView change:nil context:nil];
}

#pragma mark imagePicker
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.lastChosenMediaType = info[UIImagePickerControllerMediaType];
    if ([self.lastChosenMediaType isEqual:(NSString *)kUTTypeImage])
    {
        UIImage *chosenImage = info[UIImagePickerControllerEditedImage];        
        //NSData *imgData = UIImageJPEGRepresentation(chosenImage,0);
        
        self.myImageView.image = chosenImage;
        self.oriImage = chosenImage;
        
        [self setTool:self.currentTool];
        self.bShowingTool = YES;
        
        [self setButtonsPosition:YES];
        if(self.currentTEXTindex == 0)
        {
            [self setTextandCursorColor:1];
        }
        //[self setCursorColor:NO];
    
        
        [self observeValueForKeyPath:nil ofObject:self.myTextView change:nil context:nil];
     //   [self.arrImageDatas addObject:imgData];
        
        if(RK_IS_IPAD)
        {
            [self.popOverVC dismissPopoverAnimated:YES];
        }
     //   _nSections++;
     //   [self addImageCell:_nSections-1];
    }
    else if ([self.lastChosenMediaType isEqual:(NSString *)kUTTypeMovie])
    {
        // NSURL *urlOfVideo = info[UIImagePickerControllerMediaURL];
        // NSLog(@"Video URL = %@", urlOfVideo);
    }
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)pickMediaFromSource:(UIImagePickerControllerSourceType)sourceType
{
    NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]&& [mediaTypes count] > 0)
    {
        void(^blk)() = ^() 
        {    
            NSArray *mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
            //[UIImagePickerController availableMediaTypesForSourceType:sourceType];
            UIImagePickerController *picker = [[UIImagePickerController alloc] init] ;
            picker.mediaTypes = mediaTypes;
            picker.delegate = self;
            picker.allowsEditing = YES;// try if set NO.
            picker.sourceType = sourceType;
            
            if(RK_IS_IPHONE)
            {
                picker.mediaTypes = mediaTypes;
                picker.delegate = self;
                picker.allowsEditing = YES;// try if set NO.
                picker.sourceType = sourceType;
                [self presentViewController:picker animated:YES completion:NULL];
            }
            else
            {
                if (self.popOverVC.isPopoverVisible)
                {
                    [self.popOverVC dismissPopoverAnimated:NO];
                }
                self.popOverVC = [[UIPopoverController alloc] initWithContentViewController:picker];
                UIBarButtonItem *BarButton = [[UIBarButtonItem alloc] initWithCustomView:self.myPhotoButton];
                [self.popOverVC presentPopoverFromBarButtonItem:BarButton
                                       permittedArrowDirections:UIPopoverArrowDirectionAny
                                                       animated:YES];
                
            }
            
        };
        
        // Make sure we have permission, otherwise request it first
        ALAssetsLibrary* assetsLibrary = [[ALAssetsLibrary alloc] init];
        ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
        
        
        if (authStatus == ALAuthorizationStatusAuthorized)
        {
            blk();
        } else if (authStatus == ALAuthorizationStatusDenied || authStatus == ALAuthorizationStatusRestricted)
        {
            UIAlertView *someError1 = [[UIAlertView alloc] initWithTitle: @"Grant photos permission" message:@"Grant permission to your photos. Go to Settings App > Privacy > Photos." delegate: self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
	        [someError1 show];
	       // [someError1 release];
            
            //   [[UIAlertView alertViewWithTitle:@"Grant photos permission" message:@"Grant permission to your photos. Go to Settings App > Privacy > Photos."] show];
        }
        else if (authStatus == ALAuthorizationStatusNotDetermined)
        {
            [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                // Catch the final iteration, ignore the rest
                if (group == nil)
                    dispatch_async(dispatch_get_main_queue(), ^{
                        blk();
                    });
                *stop = YES;
            } 
            failureBlock:^(NSError *error) 
            {
                // failure :(
                dispatch_async(dispatch_get_main_queue(),^{
                    
                    UIAlertView *someError1 = [[UIAlertView alloc] initWithTitle: @"Grant photos permission" message:@"Grant permission to your photos. Go to Settings App > Privacy > Photos." delegate: self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [someError1 show];
                 //   [someError1 release];
                    
                    //      [[UIAlertView alertViewWithTitle:@"Grant photos permission" message:@"Grant permission to your photos. Go to Settings App > Privacy > Photos."] show];
                });
            }];
        }
    }
}

//----------------------------
-(UIImage *)createImage:(UIImageView *)imgView
{
    UIGraphicsBeginImageContextWithOptions(imgView.bounds.size, NO, 0); //创建一个基于位图的上下文（context）,并将其设置为当前上下文(context)
    CGContextRef context = UIGraphicsGetCurrentContext();
    [imgView.layer renderInContext:context];
    UIImage *imgs = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //UIImageWriteToSavedPhotosAlbum(imgs, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    return imgs;
}

-(UIImage *)SaveImageToAlbum:(UIImageView *)imgView
{
    UIGraphicsBeginImageContextWithOptions(imgView.bounds.size, NO, 0); //创建一个基于位图的上下文（context）,并将其设置为当前上下文(context)
    CGContextRef context = UIGraphicsGetCurrentContext();
    [imgView.layer renderInContext:context];
    UIImage *imgs = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(imgs, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    return imgs;
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    UIAlertView *alertView;
    if(error)
    {
        alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Error Occured" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
    }
    else
    {
        UIButton *btnCustom1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnCustom1.layer.cornerRadius = 5;
        [btnCustom1 setTitle:@"Done" forState:UIControlStateNormal];
        btnCustom1.backgroundColor = COMBUTTONCOLOR;
        [btnCustom1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnCustom1.titleLabel.font =COMPTEXTFONT;
        btnCustom1.frame = CGRectMake((ScreenWidth-80)/2, (ScreenHeight-32)/2, 80, 32);
        [self.view addSubview:btnCustom1];
        
        [UIView animateWithDuration:1 animations:^
         {
             btnCustom1.alpha = 0;
         }
                         completion:^(BOOL finished)
         {
             
         }];

       // alertView=[[UIAlertView alloc]initWithTitle:@"Success" message:@"Your image has been saved successfully to your photo album." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
       // [alertView show];
    }
}

@end
