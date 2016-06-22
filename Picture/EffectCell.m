#import "EffectCell.h"

@implementation EffectCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSubviews
{
	[super layoutSubviews];
    
	self.mylabelColor.frame = CGRectMake(self.frame.size.width-40.0f, 10.0f, self.contentView.bounds.size.height-24, self.contentView.bounds.size.height-24);
}

- (void)cellDidLoad
{
	self.mylabelColor = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.mylabelColor.layer setCornerRadius:3];
    [self.contentView addSubview:self.mylabelColor];
   }

- (void)cellWillAppear
{
    self.mylabelColor.backgroundColor = [UIColor greenColor];//g_arrayColors[self.indexRow];

    if(self.indexRow == g_eEffect)
    {
        self.mylabelColor.hidden = NO;
    }
    else
    {
         self.mylabelColor.hidden = YES;
    }
}


@end
