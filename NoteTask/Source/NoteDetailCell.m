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
@property (nonatomic, strong) NotePropertyView *notePropertyView;

@property (nonatomic, assign) CGFloat optumizeHeight;

@property (nonatomic, assign) UIEdgeInsets edgeContainer;
@property (nonatomic, assign) UIEdgeInsets edgeLabel;

//not use.
@property (nonatomic, assign) BOOL onEditing;
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
    
    self.notePropertyView = [[NotePropertyView alloc] init];
    [self.container addSubview:self.notePropertyView];
    
    self.noteParagraphYYLabel = [[YYLabel alloc] init];
    [self.container addSubview:self.noteParagraphYYLabel];
    self.noteParagraphYYLabel.numberOfLines = 0;
    
    self.noteParagraphLabel = [[UILabel alloc] init];
    [self.container addSubview:self.noteParagraphLabel];
    self.noteParagraphLabel.numberOfLines = 0;
    
    self.noteParagraphTextView = [[UITextView alloc] init];
    [self.container addSubview:self.noteParagraphTextView];
//    self.noteParagraphTextView.numberOfLines = 0;
    self.noteParagraphTextView.editable = NO;
    self.noteParagraphTextView.scrollEnabled = NO;
    self.noteParagraphTextView.userInteractionEnabled = NO;
    
    
    self.edgeContainer = UIEdgeInsetsMake(10, 10, 10, 10);
    self.edgeLabel = UIEdgeInsetsMake(0, 10, 0, 10);
}


- (void)setLayout
{
    
}


- (void)setClassification:(NSString*)classification color:(NSString*)color
{
    CGFloat height = 45.0;
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
    
    CGRect frameContainer = self.bounds;
    self.container.frame = frameContainer;
    self.notePropertyView.frame = self.container.bounds;
    
    [self.notePropertyView setClassification:classification color:color];
    LOG_VIEW_RECT(self.notePropertyView, @"ppp");
//    self.notePropertyView.backgroundColor = [UIColor blueColor];
    for(UIView *view in self.notePropertyView.subviews) {
        NSLog(@"---%@", view);
    }
    
    
    self.noteParagraphYYLabel.hidden    = YES;
    self.noteParagraphLabel.hidden      = YES;
    self.noteParagraphTextView.hidden   = YES;
    self.notePropertyView.hidden        = NO;
    
    self.optumizeHeight = height;
}


- (void)setNoteParagraph:(NoteParagraphModel*)noteParagraph isTitle:(BOOL)isTitle sn:(NSInteger)sn onDisplayMode:(BOOL)displayMode
{
    CGFloat heightOptumize = 100.0;
    
    CGRect frame = self.frame;
    CGRect frameContainer = UIEdgeInsetsInsetRect(self.bounds, self.edgeContainer);
    CGSize sizeOptumizeLabel;
    CGRect frameLabel;
    
    frameLabel = CGRectMake(0, 0, frameContainer.size.width, frameContainer.size.height);
    frameLabel = UIEdgeInsetsInsetRect(frameLabel, self.edgeLabel);
    
    self.noteParagraphYYLabel.textAlignment = NSTextAlignmentLeft;
    self.noteParagraphYYLabel.attributedText = [noteParagraph attributedTextGenerated];
    sizeOptumizeLabel = [self.noteParagraphYYLabel sizeThatFits:frameLabel.size];
    frameLabel.size.height = sizeOptumizeLabel.height;
    self.noteParagraphYYLabel.frame = frameLabel;
    
    self.noteParagraphLabel.textAlignment = NSTextAlignmentLeft;
    self.noteParagraphLabel.attributedText = [noteParagraph attributedTextGenerated];
    sizeOptumizeLabel = [self.noteParagraphLabel sizeThatFits:frameLabel.size];
    frameLabel.size.height = sizeOptumizeLabel.height;
    self.noteParagraphLabel.frame = frameLabel;
    
    self.noteParagraphTextView.textAlignment = NSTextAlignmentLeft;
    self.noteParagraphTextView.attributedText = [noteParagraph attributedTextGenerated];
    sizeOptumizeLabel = [self.noteParagraphTextView sizeThatFits:frameLabel.size];
    frameLabel.size.height = sizeOptumizeLabel.height;
    if(self.onEditing) {
        frameLabel.size.height = 200.;
        if(self.heightFitToKeyboard > 0.0) {
            frameLabel.size.height = self.heightFitToKeyboard
                    - (self.edgeLabel.top + self.edgeLabel.bottom)
                    - (self.edgeContainer.top + self.edgeContainer.bottom);
        }
        self.noteParagraphTextView.editable = YES;
        self.noteParagraphTextView.scrollEnabled = YES;
        self.noteParagraphTextView.userInteractionEnabled = YES;
    }
    else {
        self.noteParagraphTextView.editable = NO;
        self.noteParagraphTextView.scrollEnabled = NO;
        self.noteParagraphTextView.userInteractionEnabled = NO;
    }
    self.noteParagraphTextView.frame = frameLabel;
    self.noteParagraphTextView.delegate = self;
    if(!displayMode && self.noteParagraphTextView.attributedText.string.length == 0) {
        
        
    }
    
    frameContainer.size.height = frameLabel.size.height + self.edgeLabel.top + self.edgeLabel.bottom;
    frame.size.height = frameContainer.size.height + self.edgeContainer.top + self.edgeContainer.bottom;
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
    
    self.noteParagraphYYLabel.hidden    = YES;
    self.noteParagraphLabel.hidden      = YES;
    self.noteParagraphTextView.hidden   = NO;
    self.notePropertyView.hidden        = YES;
    
    heightOptumize = frame.size.height;
    self.optumizeHeight = heightOptumize;
}


- (void)setCellDisplayHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    CGRect frameContainer = UIEdgeInsetsInsetRect(self.bounds, self.edgeContainer);
    
    CGRect frameLabel = CGRectMake(0, 0, frameContainer.size.width, frameContainer.size.height);
    frameLabel = UIEdgeInsetsInsetRect(frameLabel, self.edgeLabel);
    
    
    self.frame = frame;
    self.container.frame = frameContainer;
    self.noteParagraphTextView.frame = frameLabel;
    
    NSLog(@"cell height fit to keyboard : %f", self.frame.size.height);
}



-(BOOL) textViewShouldBeginEditing:(UITextView*)textView
{
    return YES;
}


-(void)textViewDidChange:(UITextView*)textView
{
    if([textView.text length]==0){
        textView.text =@"Foobar placeholder";
        textView.textColor =[UIColor lightGrayColor];
        textView.tag =0;
    }
}



@end
