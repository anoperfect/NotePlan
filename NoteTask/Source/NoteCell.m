//
//  NoteCell.m
//  NoteTask
//
//  Created by Ben on 16/7/10.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "NoteCell.h"

@implementation NoteCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (self.highlighted) {
        NS0Log(@"setHighlighted : 1");
        POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        scaleAnimation.duration           = 0.1f;
        scaleAnimation.toValue            = [NSValue valueWithCGPoint:CGPointMake(0.95, 0.95)];
        [self.titleLabel pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
        
    }
    else {
        NS0Log(@"setHighlighted : 0");
        POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        scaleAnimation.toValue             = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
        scaleAnimation.velocity            = [NSValue valueWithCGPoint:CGPointMake(2, 2)];
        scaleAnimation.springBounciness    = 20.f;
        [self.titleLabel pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
    }
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        [self initSubviews];
        [self setLayout];
    }
    
    return self;
}


- (void)initSubviews
{
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.contentView addSubview:self.titleLabel];
    
    self.propertyLabel = [[UILabel alloc] init];
    self.propertyLabel.numberOfLines = 0;
    self.propertyLabel.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
    self.propertyLabel.font = [UIFont systemFontOfSize:12];
    self.propertyLabel.textColor = [UIColor blueColor];
    [self.contentView addSubview:self.propertyLabel];
    
    self.bodyLabel = [[UILabel alloc] init];
    self.bodyLabel.numberOfLines = 1;
    self.bodyLabel.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
    self.bodyLabel.font = [UIFont systemFontOfSize:13];
    self.bodyLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:self.bodyLabel];
    
    self.authorLabel = [[UILabel alloc] init];
    self.authorLabel.font = [UIFont systemFontOfSize:12];
    //self.authorLabel.textColor = [UIColor nameColor];
    [self.contentView addSubview:self.authorLabel];
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.font = [UIFont systemFontOfSize:12];
    self.timeLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:self.timeLabel];
    
    self.commentCount = [[UILabel alloc] init];
    self.commentCount.font = [UIFont systemFontOfSize:12];
    self.commentCount.textColor = [UIColor grayColor];
    [self.contentView addSubview:self.commentCount];
    
    [self.bodyLabel setLayoutMargins:UIEdgeInsetsMake(10, 10, 10, 10)];
}


- (void)setLayout
{
    
}


- (void)setLayout1
{
    for (UIView *view in [self.contentView subviews]) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    NSDictionary *viewsDict = NSDictionaryOfVariableBindings(_titleLabel, _bodyLabel, _authorLabel, _timeLabel, _commentCount);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_titleLabel]-5-[_bodyLabel]"
                                                                             options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                             metrics:nil views:viewsDict]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_bodyLabel]-5-[_authorLabel]-8-|"
                                                                             options:NSLayoutFormatAlignAllLeft
                                                                             metrics:nil views:viewsDict]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_titleLabel]-8-|"
                                                                             options:0 metrics:nil views:viewsDict]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_authorLabel]-10-[_timeLabel]-10-[_commentCount]-10-|"
                                                                             options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom
                                                                             metrics:nil views:viewsDict]];
}


- (void)setNote:(NoteModel*)note
{
    _note = note;
    
    self.titleLabel.text    = [note previewTitle];
    self.bodyLabel.text     = [note previewSummary];
    
    NSString *modifiedAtDay = _note.modifiedAt.length >=10 ? [_note.modifiedAt substringToIndex:10] : _note.modifiedAt;
    
    NSString *classification = _note.classification.length > 0 ? _note.classification : @"未分类" ;
    self.propertyLabel.text = [NSString stringWithFormat:@"%@   /%@/", modifiedAtDay, classification];
    
    self.timeLabel.text     = @"2016-11-01 10:10:10";
    self.commentCount.text  = @"评论";
    
    [self layoutSubviews];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //进入到编辑模式, 不重新布局. title的行数可能变多导致cell高度变化, 需手动刷新显示.
    if(self.editing) {
        return;
    }
    
    CGFloat x = 8;
    CGFloat y = 0;
    CGFloat width = self.contentView.frame.size.width - 2 * x;
    
    y += 10;
    CGSize sizeTitle = [self.titleLabel sizeThatFits:CGSizeMake(width, 36)];
    CGRect frameTitleLabel = CGRectMake(x, y, width, sizeTitle.height);
    self.titleLabel.frame = frameTitleLabel;
    y += frameTitleLabel.size.height;
    
    y += 6;
    self.propertyLabel.frame = CGRectMake(x, y, width, 20);
    y += self.propertyLabel.frame.size.height;
    
    y += 6;
    self.bodyLabel.frame = CGRectMake(x, y, width, 20);
    y += self.bodyLabel.frame.size.height;
    
    y += 6;
    
    CGRect frameContentView = self.contentView.frame;
    frameContentView.size.height = y;
    self.contentView.frame = frameContentView;
    
    self.optumizeHeight = frameContentView.size.height;
}






@end
