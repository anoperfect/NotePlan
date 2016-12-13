//
//  NoteDetailCell.m
//  NoteTask
//
//  Created by Ben on 16/10/27.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "NoteDetailCell.h"






@interface NoteDetailCell () <UITextViewDelegate>

@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) YYLabel *noteParagraphYYLabel;
@property (nonatomic, strong) UILabel *noteParagraphLabel;
@property (nonatomic, strong) UITextView *noteParagraphTextView;

@property (nonatomic, assign) CGFloat optumizeHeight;

@property (nonatomic, assign) UIEdgeInsets edgeContainer;
@property (nonatomic, assign) UIEdgeInsets edgeLabel;


@property (nonatomic, assign) CGFloat heightFitToKeyboard;

@end


@implementation NoteDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
    [super setHighlighted:highlighted animated:animated];
    
    NS0Log(@"setHighlighted");
    
    if (self.highlighted) {
        
        
    } else {
        
    }
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self initSubviews];
        [self setLayout];
    }
    return self;
}


- (void)initSubviews
{
    self.container = [[UIView alloc] init];
    [self addSubview:self.container];
    

    
//    self.noteParagraphYYLabel = [[YYLabel alloc] init];
    [self.container addSubview:self.noteParagraphYYLabel];
    self.noteParagraphYYLabel.numberOfLines = 0;
    
    self.noteParagraphLabel = [[UILabel alloc] init];
    [self.container addSubview:self.noteParagraphLabel];
    self.noteParagraphLabel.numberOfLines = 0;
    
//    self.noteParagraphTextView = [[UITextView alloc] init];
    [self.container addSubview:self.noteParagraphTextView];
    self.noteParagraphTextView.editable = NO;
    self.noteParagraphTextView.scrollEnabled = NO;
    self.noteParagraphTextView.userInteractionEnabled = NO;
}


- (void)setLayout
{
    
}


- (void)setNoteParagraph:(NoteParagraphModel*)noteParagraph isTitle:(BOOL)isTitle sn:(NSInteger)sn onDisplayMode:(BOOL)displayMode
{
    CGFloat heightOptumize = 100.0;
    
    self.noteParagraphYYLabel.hidden    = YES;
    self.noteParagraphLabel.hidden      = NO;
    self.noteParagraphTextView.hidden   = YES;
    
    CGRect frame = self.frame;
    CGRect frameContainer = UIEdgeInsetsInsetRect(self.bounds, NOTEDETAILCELL_EDGE_CONTAINER);
    CGSize sizeOptumizeLabel;
    CGRect frameLabel;
    
    UIEdgeInsets edgeLabel = UIEdgeInsetsZero;
    
    frameLabel = CGRectMake(0, 0, frameContainer.size.width, frameContainer.size.height);
    
    if(self.noteParagraphTextView && !self.noteParagraphTextView.hidden) {
        
        edgeLabel = UIEdgeInsetsZero;
        frameLabel = UIEdgeInsetsInsetRect(frameLabel, edgeLabel);
        
        self.noteParagraphTextView.attributedText = [noteParagraph attributedTextGenerated];
        sizeOptumizeLabel = [self.noteParagraphTextView sizeThatFits:frameLabel.size];
        frameLabel.size.height = sizeOptumizeLabel.height;

        self.noteParagraphTextView.editable = NO;
        self.noteParagraphTextView.scrollEnabled = NO;
        self.noteParagraphTextView.userInteractionEnabled = NO;
    
        self.noteParagraphTextView.frame = frameLabel;
        self.noteParagraphTextView.delegate = self;
    }
    else if(self.noteParagraphYYLabel && !self.noteParagraphYYLabel.hidden) {
        
        edgeLabel = NOTEDETAILCELL_EDGE_LABEL;
        frameLabel = UIEdgeInsetsInsetRect(frameLabel, edgeLabel);
        
        self.noteParagraphYYLabel.attributedText = [noteParagraph attributedTextGenerated];
        sizeOptumizeLabel = [self.noteParagraphYYLabel sizeThatFits:frameLabel.size];
        frameLabel.size.height = sizeOptumizeLabel.height;
        self.noteParagraphYYLabel.frame = frameLabel;
    }
    else if(self.noteParagraphLabel && !self.noteParagraphLabel.hidden) {
        edgeLabel = NOTEDETAILCELL_EDGE_LABEL;
        frameLabel = UIEdgeInsetsInsetRect(frameLabel, edgeLabel);
        
        self.noteParagraphLabel.attributedText = [noteParagraph attributedTextGenerated];
        sizeOptumizeLabel = [self.noteParagraphLabel sizeThatFits:frameLabel.size];
        frameLabel.size.height = sizeOptumizeLabel.height;
        self.noteParagraphLabel.frame = frameLabel;
    }
    
    if(!displayMode && self.noteParagraphTextView.attributedText.string.length == 0) {
        
        
    }
    
    frameContainer.size.height = frameLabel.size.height + edgeLabel.top + edgeLabel.bottom;
    frame.size.height = frameContainer.size.height + NOTEDETAILCELL_EDGE_CONTAINER.top + NOTEDETAILCELL_EDGE_CONTAINER.bottom;
    self.frame = frame;
    self.container.frame = frameContainer;
    
    //设置边框.
    if([noteParagraph.styleDictionay[@"border"] isEqualToString:@"1px solid #000"]) {
        self.container.layer.borderWidth = 1.0;
        self.container.layer.borderColor = [UIColor blackColor].CGColor;
    }
    else {
        self.container.layer.borderWidth = 0.0;
    }
    
    heightOptumize = frame.size.height;
    self.optumizeHeight = heightOptumize;
}


-(BOOL) textViewShouldBeginEditing:(UITextView*)textView
{
    return YES;
}


-(void)textViewDidChange:(UITextView*)textView
{
    if([textView.text length]==0){

    }
}



@end
