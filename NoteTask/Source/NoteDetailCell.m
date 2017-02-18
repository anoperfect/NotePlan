//
//  NoteDetailCell.m
//  NoteTask
//
//  Created by Ben on 16/10/27.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "NoteDetailCell.h"






@interface NoteDetailCell () <UITextViewDelegate>
@property (nonatomic, strong) NoteParagraphModel* noteParagraph;
@property (nonatomic, assign) NSInteger sn;
@property (nonatomic, assign) NSInteger mode;


@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) YYLabel *noteParagraphYYLabel;
@property (nonatomic, strong) UILabel *noteParagraphLabel;
@property (nonatomic, strong) UITextView *noteParagraphTextView;

@property (nonatomic, strong) UIImageView *noteImageView;

@property (nonatomic, strong) UIView  *dottedLine;

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
    
    self.noteImageView = [[UIImageView alloc] init];
    [self.container addSubview:self.noteImageView];
    self.noteImageView.hidden = YES;
    
    self.dottedLine = [[UIView alloc] init];
    [self addSubview:self.dottedLine];
    self.dottedLine.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"DottedLine"]];
}


- (void)setLayout
{
    
}


- (void)setNoteParagraph:(NoteParagraphModel*)noteParagraph sn:(NSInteger)sn onMode:(NSInteger)mode image:(UIImage*)image imageSize:(CGSize)imageSize
{
    self.noteParagraph  = noteParagraph;
    self.sn             = sn;
    self.mode           = mode;
    
    if(image) {
        NSLog(@"setNoteParagraph %zd, image(%@) : %f x %f, resize to %f x %f .", sn, image, image.size.width, image.size.height, imageSize.width, imageSize.height);
    }
    else {
        NSLog(@"setNoteParagraph %zd, image nil.", sn);
    }
    
    self.noteImageView.hidden = YES;
    
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
    
    NSAttributedString *textAttributedString = [noteParagraph attributedTextGeneratedOnSn:sn onMode:mode];
    
    if(self.noteParagraphTextView && !self.noteParagraphTextView.hidden) {
        
        edgeLabel = UIEdgeInsetsZero;
        frameLabel = UIEdgeInsetsInsetRect(frameLabel, edgeLabel);
        
        self.noteParagraphTextView.attributedText = textAttributedString;
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
        
        self.noteParagraphYYLabel.attributedText = textAttributedString;
        sizeOptumizeLabel = [self.noteParagraphYYLabel sizeThatFits:frameLabel.size];
        frameLabel.size.height = sizeOptumizeLabel.height;
        self.noteParagraphYYLabel.frame = frameLabel;
    }
    else if(self.noteParagraphLabel && !self.noteParagraphLabel.hidden) {
        edgeLabel = NOTEDETAILCELL_EDGE_LABEL;
        
        if(noteParagraph.image.length > 0 && image) {
            self.noteImageView.hidden = NO;
            self.noteImageView.frame = CGRectMake((frameContainer.size.width - imageSize.width) / 2, 0, imageSize.width, imageSize.height);
            self.noteImageView.image = image;
            edgeLabel.top += imageSize.height;
            
            NSLog(@"---%@", image);
            LOG_RECT(self.container.frame, @"container");
            LOG_RECT(self.noteImageView.frame, @"noteImageView");
        }
        else {

        }
        
        frameLabel = UIEdgeInsetsInsetRect(frameLabel, edgeLabel);
        
        self.noteParagraphLabel.attributedText = textAttributedString;
        NS0Log(@"sn : %zd, content : %@, text : %@. \n(%@)", sn
              , noteParagraph.content
              , self.noteParagraphLabel.attributedText.string
              , self.noteParagraphLabel.attributedText);
        
        sizeOptumizeLabel = [self.noteParagraphLabel sizeThatFits:frameLabel.size];
        if(sizeOptumizeLabel.height > 10) {
            frameLabel.size.height = sizeOptumizeLabel.height;
        }
        else {
            frameLabel.size.height = 10;
        }
        self.noteParagraphLabel.frame = frameLabel;
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
    
    //给编辑状态的paragraph标记. 以下为使用UIView加虚线的方式. 已经不适用.
    if(mode == NOTEPARAGRAPH_MODE_EDIT || mode == NOTEPARAGRAPH_MODE_CREATE) {
        NSLog(@"xxxxx---")
        self.dottedLine.hidden = NO;
        self.dottedLine.frame = CGRectMake(20, frame.size.height - 6, frame.size.width - 20 - 20, 0.5);
    }
    else {
        self.dottedLine.hidden = YES;
    }
    
    heightOptumize = frame.size.height;
    NS0Log(@"heightOptumize : %f", heightOptumize);
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
