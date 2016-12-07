//
//  TaskDaySelectViewController.m
//  NoteTask
//
//  Created by Ben on 16/11/7.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "TaskDaySelectViewController.h"

@interface TaskDaySelectViewController ()

@end

@implementation TaskDaySelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    

    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

#if 0
@interface TaskDaySelector ()

@property (nonatomic, strong) UIView     *container;



@property (nonatomic, strong) UILabel    *label1;
@property (nonatomic, strong) UILabel    *label2;
@property (nonatomic, strong) UITextField    *textInput1;
@property (nonatomic, strong) UITextField    *textInput2;
@property (nonatomic, strong) UILabel    *labelDays;


@property (nonatomic, strong) UISegmentedControl *daysTypeSelector;
@property (nonatomic, strong) NSArray<NSString*> *daysTypes;


@property (nonatomic, strong) NSString *daysType;
@property (nonatomic, strong) NSString *dayString;
@property (nonatomic, strong) NSArray<NSString*> *mutilDays;
@property (nonatomic, strong) NSString *dayStringFrom;
@property (nonatomic, strong) NSString *dayStringTo;

@end


@implementation TaskDaySelector




- (instancetype)init
{
    LOG_POSTION
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.container = [[UIView alloc] init];
        [self addSubview:self.container];
        
        self.label1 = [[UILabel alloc] init];
        self.label2 = [[UILabel alloc] init];
        self.textInput1 = [[UITextField alloc] init];
        self.textInput2 = [[UITextField alloc] init];
        
        self.labelDays = [[UILabel alloc] init];
        self.mutilDays = [[NSMutableArray alloc] init];
        
        self.daysTypes = @[kStringSelectorDay, kStringSelectorDays, kStringSelectorContinuous];
        self.daysTypeSelector = [[UISegmentedControl alloc] init];
        for(NSInteger idx = 0; idx < self.daysTypes.count; idx ++) {
            [self.daysTypeSelector insertSegmentWithTitle:self.daysTypes[idx] atIndex:idx animated:YES];
        }
        [self.daysTypeSelector addTarget:self action:@selector(actionDaysTypeSelector:) forControlEvents:UIControlEventValueChanged];
        
        [self.container addSubview:self.label1];
        [self.container addSubview:self.label2];
        [self.container addSubview:self.textInput1];
        [self.container addSubview:self.textInput2];
        [self.container addSubview:self.labelDays];
        [self.container addSubview:self.daysTypeSelector];
        
        
        
    }
    return self;
}


- (void)layoutSubviews
{
    CGRect frame = self.bounds;
    NSLog(@"%lf %lf", frame.size.width, frame.size.height);
    self.container.frame = frame;
    [self updateDisplay];
}


- (void)updateDisplay
{
    LOG_POSTION
    
    CGFloat widthTotal = self.container.frame.size.width;
    CGFloat widthDaysTypeSelector = 200;
    self.daysTypeSelector.frame = CGRectMake((widthTotal-widthDaysTypeSelector) / 2 , 10, widthDaysTypeSelector, 28);
    
    
    
    CGFloat y = 50;
    
    self.label1.frame = CGRectMake(10, y, 100, 36);
    self.label1.text = @"任务执行日期 : ";
    self.label1.font = FONT_SMALL;
    self.label1.textAlignment = NSTextAlignmentRight;
    self.textInput1.frame = CGRectMake(121, y, 100, 36);
    self.textInput1.font = FONT_SMALL;
    
    
    
    
    self.daysType = kStringSelectorDays;
    
    if([self.daysType isEqualToString:kStringSelectorDay]) {
        self.label1.text = @"任务执行日期 : ";
        
        self.label2.hidden = YES;
        self.textInput2.hidden = YES;
        self.labelDays.hidden = YES;
        
        UIToolbar *keyboardAccessory = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 36)];
        keyboardAccessory.backgroundColor = [UIColor whiteColor];
        [keyboardAccessory setItems:@[
                                      [[UIBarButtonItem alloc] initWithTitle:@"今天" style:UIBarButtonItemStylePlain target:self action:@selector(inputStringToday:)],
                                      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                      [[UIBarButtonItem alloc] initWithTitle:@"明天" style:UIBarButtonItemStylePlain target:self action:@selector(inputStringTomorrow:)],
                                      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                      [[UIBarButtonItem alloc] initWithTitle:@"日历" style:UIBarButtonItemStylePlain target:self action:@selector(openCalendar:)]
                                      ]
                           animated:YES];
        self.textInput1.inputAccessoryView = keyboardAccessory;
        
        CALayer *underlineLayer = nil;
        for(CALayer *layer in self.textInput1.layer.sublayers) {
            if([layer.name isEqualToString:@"underline"]) {
                underlineLayer = layer;
                break;
            }
        }
        if(!underlineLayer) {
            underlineLayer = [CALayer layer];
            [self.textInput1.layer addSublayer:underlineLayer];
        }
        underlineLayer.position = CGPointMake(self.textInput1.frame.size.width / 2, self.textInput1.frame.size.height - 10);
        underlineLayer.bounds = CGRectMake(0, 0, self.textInput1.frame.size.width, 1);
        underlineLayer.backgroundColor = [UIColor blueColor].CGColor;
        self.optumizeHeight = 56;
    }
    else if([self.daysType isEqualToString:kStringSelectorDays]) {
        self.label1.text = @"任务执行日期 : ";
        
        self.label2.hidden = YES;
        self.textInput2.hidden = YES;
        self.labelDays.hidden = NO;
        self.labelDays.frame = CGRectMake(121, 96, self.container.frame.size.width - 121, 36);
        self.labelDays.font = FONT_SMALL;
        if(self.mutilDays.count == 0) {
            self.labelDays.text = @"选定的执行日期在此显示";
        }
        else {
            
        }
        
        UIToolbar *keyboardAccessory = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 36)];
        keyboardAccessory.backgroundColor = [UIColor whiteColor];
        [keyboardAccessory setItems:@[
                                      [[UIBarButtonItem alloc] initWithTitle:@"今天" style:UIBarButtonItemStylePlain target:self action:@selector(inputStringToday:)],
                                      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                      [[UIBarButtonItem alloc] initWithTitle:@"明天" style:UIBarButtonItemStylePlain target:self action:@selector(inputStringTomorrow:)],
                                      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                      [[UIBarButtonItem alloc] initWithTitle:@"增加" style:UIBarButtonItemStylePlain target:self action:@selector(daysModeAddDay:)],
                                      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                      [[UIBarButtonItem alloc] initWithTitle:@"日历" style:UIBarButtonItemStylePlain target:self action:@selector(openCalendar:)]
                                      ]
                           animated:YES];
        self.textInput1.inputAccessoryView = keyboardAccessory;
        
        CALayer *underlineLayer = nil;
        for(CALayer *layer in self.textInput1.layer.sublayers) {
            if([layer.name isEqualToString:@"underline"]) {
                underlineLayer = layer;
                break;
            }
        }
        if(!underlineLayer) {
            underlineLayer = [CALayer layer];
            [self.textInput1.layer addSublayer:underlineLayer];
        }
        underlineLayer.position = CGPointMake(self.textInput1.frame.size.width / 2, self.textInput1.frame.size.height - 10);
        underlineLayer.bounds = CGRectMake(0, 0, self.textInput1.frame.size.width, 1);
        underlineLayer.backgroundColor = [UIColor blueColor].CGColor;
        self.optumizeHeight = SCREEN_HEIGHT;
        
        
        
        
        
    }
    
    
    
}


- (void)actionDaysTypeSelector:(UISegmentedControl*)segmentedControl
{
    LOG_POSTION
    NSInteger idx = segmentedControl.selectedSegmentIndex;
    if(idx >= 0 && idx < self.daysTypes.count) {
        LOG_POSTION
        self.daysType = self.daysTypes[idx];
        [self updateDisplay];
    }
}


- (void)inputStringToday:(id)sender
{
    if([self.daysType isEqualToString:kStringSelectorDay]) {
        self.textInput1.text = [NSString dateStringToday];
        [self.textInput1 resignFirstResponder];
    }
    else if([self.daysType isEqualToString:kStringSelectorDays]) {
        self.textInput1.text = [NSString dateStringToday];
    }
    else if([self.daysType isEqualToString:kStringSelectorContinuous]) {
        if(self.textInput1.editing) {
            self.textInput1.text = [NSString dateStringToday];
            [self.textInput1 resignFirstResponder];
            [self.textInput2 becomeFirstResponder];
        }
        else if(self.textInput2.editing) {
            self.textInput2.text = [NSString dateStringToday];
            [self.textInput2 resignFirstResponder];
        }
    }
}


- (void)inputStringTomorrow:(id)sender
{
    if(self.textInput1.editing) {
        self.textInput1.text = [NSString dateStringTomorrow];
        [self.textInput1 resignFirstResponder];
    }
    
    if(self.textInput2.editing) {
        self.textInput2.text = [NSString dateStringTomorrow];
        [self.textInput2 resignFirstResponder];
    }
}


- (void)openCalendar:(id)sender
{
    
    
}


- (void)daysModeAddDay:(id)sender
{
    LOG_POSTION
    
    
    
}


- (void)drawRect:(CGRect)rect
{
    //    CGContextRef context = UIGraphicsGetCurrentContext();
    //
    //    //设置属性
    //    [[UIColor colorWithName:@"TaskRecordTimeLine"] set];
    //
    //
    //
    //    CGFloat yBorder = 6;
    //    CGFloat y1 = yBorder;
    //    CGFloat y2 = rect.size.height - yBorder;
    //
    //    CGFloat widthPercentage = 0.6;
    //    CGFloat xBorder = 6;
    //    CGPoint point0 = CGPointMake(xBorder + xBorder, y1);
    //    CGPoint point1 = CGPointMake(rect.size.width * widthPercentage, y1);
    //    CGPoint point2 = CGPointMake(rect.size.width * widthPercentage - xBorder, y2);
    //    CGPoint point3 = CGPointMake(xBorder, y2);
    //
    //    CGContextMoveToPoint(context, point0.x, point1.y);
    //    CGContextAddLineToPoint(context, point1.x,point1.y);
    //    CGContextAddLineToPoint(context, point2.x,point2.y);
    //    CGContextAddLineToPoint(context, point3.x,point3.y);
    //    CGContextAddLineToPoint(context, point0.x,point0.y);
    //    CGContextStrokePath(context);
    
    
    
    
    
    
    
}





@end

#endif














@interface TaskCalendar () <JTCalendarDelegate>
{
    NSMutableDictionary *_eventsByDate;
    NSDate *_dateSelected;
    UITextField *_textInput;
}

@property (nonatomic, strong) JTCalendarManager *calendarManager;
@property (nonatomic, strong) JTCalendarMenuView *calendarMenuView;
@property (nonatomic, strong) JTHorizontalCalendarView *calendarContentView;

@property (nonatomic, strong) NSString *dayString;
@property (nonatomic, strong) NSArray<NSString*> *dayStrings;

@end



@implementation TaskCalendar


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        CGFloat width = frame.size.width;
        CGFloat height = frame.size.height;
        
        CGFloat xTextInput = 60;
        CGFloat yTextInput = 60;
        CGFloat heightTextInput = 36;
        _textInput = [[UITextField alloc] initWithFrame:CGRectMake(xTextInput, yTextInput, width - xTextInput * 2, heightTextInput)];
        _textInput.textAlignment = NSTextAlignmentCenter;
        _textInput.layer.borderColor = [UIColor colorWithName:@"TaskBorderCommon"].CGColor;
        _textInput.layer.borderWidth = 1;
        _textInput.layer.cornerRadius = _textInput.frame.size.height / 2;
        
        _calendarMenuView = [[JTCalendarMenuView alloc] initWithFrame:CGRectMake(0, height - width - 50, width, 36)];
        _calendarContentView = [[JTHorizontalCalendarView alloc] initWithFrame:CGRectMake(0, height - width, width, width)];
        _calendarManager = [[JTCalendarManager alloc] init];
        _calendarManager.delegate = self;
        
        _calendarMenuView.contentRatio = .75;
        _calendarManager.settings.weekDayFormat = JTCalendarWeekDayFormatSingle;
        _calendarManager.dateHelper.calendar.locale = [NSLocale currentLocale];
        
        [_calendarManager setMenuView:_calendarMenuView];
        [_calendarManager setContentView:_calendarContentView];
        [_calendarManager setDate:[NSDate date]];
        
        [self addSubview:_textInput];
        [self addSubview:_calendarMenuView];
        [self addSubview:_calendarContentView];
    }
    return self;
}


#pragma mark - CalendarManager delegate

// Exemple of implementation of prepareDayView method
// Used to customize the appearance of dayView
- (void)calendar:(JTCalendarManager *)calendar prepareDayView:(JTCalendarDayView *)dayView
{
    dayView.hidden = NO;
    
    // Other month
    if([dayView isFromAnotherMonth]){
        dayView.hidden = YES;
    }
    // Today
    else if([_calendarManager.dateHelper date:[NSDate date] isTheSameDayThan:dayView.date]){
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor blueColor];
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    // Selected date
    else if(_dateSelected && [_calendarManager.dateHelper date:_dateSelected isTheSameDayThan:dayView.date]){
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor redColor];
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    // Another day of the current month
    else{
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor redColor];
        dayView.textLabel.textColor = [UIColor blackColor];
    }
    
    if([self haveEventForDay:dayView.date]){
        dayView.dotView.hidden = NO;
    }
    else{
        dayView.dotView.hidden = YES;
    }
}


- (void)calendar:(JTCalendarManager *)calendar didTouchDayView:(JTCalendarDayView *)dayView
{
    _dateSelected = dayView.date;
    
    NSString *dateString = [NSString dateStringOfDate:dayView.date];
    NSLog(@"%@", dateString);
    _textInput.text = dateString;
    self.dayString = dateString;
    
    // Animation for the circleView
    dayView.circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
    [UIView transitionWithView:dayView
                      duration:.3
                       options:0
                    animations:^{
                        dayView.circleView.transform = CGAffineTransformIdentity;
                        [_calendarManager reload];
                    } completion:nil];
    
    
    // Don't change page in week mode because block the selection of days in first and last weeks of the month
    if(_calendarManager.settings.weekModeEnabled){
        return;
    }
    
    // Load the previous or next page if touch a day from another month
    
    if(![_calendarManager.dateHelper date:_calendarContentView.date isTheSameMonthThan:dayView.date]){
        if([_calendarContentView.date compare:dayView.date] == NSOrderedAscending){
            [_calendarContentView loadNextPageWithAnimation];
        }
        else{
            [_calendarContentView loadPreviousPageWithAnimation];
        }
    }
}

#pragma mark - Views customization

- (UIView *)calendarBuildMenuItemView:(JTCalendarManager *)calendar
{
    UILabel *label = [UILabel new];
    
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"Avenir-Medium" size:16];
    
    return label;
}

- (void)calendar:(JTCalendarManager *)calendar prepareMenuItemView:(UILabel *)menuItemView date:(NSDate *)date
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"MMMM yyyy";
        
        dateFormatter.locale = _calendarManager.dateHelper.calendar.locale;
        dateFormatter.timeZone = _calendarManager.dateHelper.calendar.timeZone;
    }
    
    menuItemView.text = [dateFormatter stringFromDate:date];
}

- (UIView<JTCalendarWeekDay> *)calendarBuildWeekDayView:(JTCalendarManager *)calendar
{
    JTCalendarWeekDayView *view = [JTCalendarWeekDayView new];
    
    for(UILabel *label in view.dayViews){
        label.textColor = [UIColor blackColor];
        label.font = [UIFont fontWithName:@"Avenir-Light" size:14];
    }
    
    return view;
}

- (UIView<JTCalendarDay> *)calendarBuildDayView:(JTCalendarManager *)calendar
{
    JTCalendarDayView *view = [JTCalendarDayView new];
    
    view.textLabel.font = [UIFont fontWithName:@"Avenir-Light" size:13];
    
    view.circleRatio = .8;
    view.dotRatio = 1. / .9;
    
    return view;
}

#pragma mark - Fake data

// Used only to have a key for _eventsByDate
- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"dd-MM-yyyy";
    }
    
    return dateFormatter;
}

- (BOOL)haveEventForDay:(NSDate *)date
{
    NSString *key = [[self dateFormatter] stringFromDate:date];
    
    if(_eventsByDate[key] && [_eventsByDate[key] count] > 0){
        return YES;
    }
    
    return NO;
    
}

- (void)createRandomEvents
{
    _eventsByDate = [NSMutableDictionary new];
    
    for(int i = 0; i < 30; ++i){
        // Generate 30 random dates between now and 60 days later
        NSDate *randomDate = [NSDate dateWithTimeInterval:(rand() % (3600 * 24 * 60)) sinceDate:[NSDate date]];
        
        // Use the date as key for eventsByDate
        NSString *key = [[self dateFormatter] stringFromDate:randomDate];
        
        if(!_eventsByDate[key]){
            _eventsByDate[key] = [NSMutableArray new];
        }
        
        [_eventsByDate[key] addObject:randomDate];
    }
}

@end
