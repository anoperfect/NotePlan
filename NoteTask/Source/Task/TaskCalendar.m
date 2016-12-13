//
//  TaskCalendar.m
//  NoteTask
//
//  Created by Ben on 16/11/7.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "TaskCalendar.h"
@interface TaskCalendar () <JTCalendarDelegate>
{
    NSMutableDictionary *_eventsByDate;
    
    //单选模式.
    NSDate *_dateSelected;
    UITextField *_textInput;
    
    //多选模式.
    NSMutableArray *_datesSelected;
    BOOL _selectionMode;
    YYLabel *_datesDisplay;
    UIScrollView *_scrollView;
}

@property (nonatomic, strong) JTCalendarManager *calendarManager;
@property (nonatomic, strong) JTCalendarMenuView *calendarMenuView;
@property (nonatomic, strong) JTHorizontalCalendarView *calendarContentView;

@property (nonatomic, assign) BOOL mutilMode;
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
        
        _scrollView = [[UIScrollView alloc] init];
        _datesDisplay = [[YYLabel alloc] init];
        _datesDisplay.numberOfLines = 0;
        CGFloat fontSize = (SCREEN_WIDTH/22.0);
        UIFont *font = [UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:fontSize];
        _datesDisplay.font = font;
        _datesDisplay.textAlignment = NSTextAlignmentCenter;
        CGRect frameDatesDisplay = CGRectMake(0, 64, width, height - 64 - 36 - width);
        frameDatesDisplay = UIEdgeInsetsInsetRect(frameDatesDisplay, UIEdgeInsetsMake(10, 10, 10, 10));
        _scrollView.frame = frameDatesDisplay;
        _datesDisplay.frame = frameDatesDisplay;
        
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
        
        _datesSelected = [[NSMutableArray alloc] init];
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame andDayString:(NSString*)dayString
{
    LOG_POSTION
    self = [self initWithFrame:frame];
    self.mutilMode = NO;
    self.dayString = dayString;
    if(dayString) {
        _dateSelected = [NSString dateFromString:dayString];
        _textInput.text = dayString;
        _textInput.userInteractionEnabled = NO;
    }
    
    _textInput.hidden       = NO;
    _datesDisplay.hidden    = YES;
    _scrollView.hidden      = YES;
    
    NSLog(@"TaskCalendar init : date %@", _datesSelected);
    [_calendarManager reload];
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame andDayStrings:(NSArray<NSString*>*)dayStrings
{
    LOG_POSTION
    self = [self initWithFrame:frame];
    self.mutilMode = YES;
    self.dayStrings = dayStrings;
    if(dayStrings.count > 0) {
        for(NSString *dayString in dayStrings) {
            [_datesSelected addObject:[NSString dateFromString:dayString]];
        }
    }
    
    _textInput.hidden       = YES;
    _datesDisplay.hidden    = NO;
    _scrollView.hidden      = NO;
    
    NSLog(@"TaskCalendar init : selected %zd (%@)", _datesSelected.count, dayStrings);
    
    [_calendarManager reload];
    
    [self updateDatesSelected];
    
    return self;
}


- (void)updateDatesSelected
{
    LOG_POSTION
    NSMutableArray *dayStrings = [[NSMutableArray alloc] init];
    for(NSDate *date in _datesSelected) {
        [dayStrings addObject:[NSString dateStringOfDate:date]];
    }
    
    NSString *s = [NSString arrayDescriptionConbine:dayStrings seprator:@"  "];
    _datesDisplay.text = s;
    
    CGSize sizeFit = [_datesDisplay sizeThatFits:_scrollView.frame.size];
    if(sizeFit.height > _scrollView.frame.size.height) {
        _datesDisplay.hidden = NO;
        _scrollView.hidden = NO;
        [_scrollView addSubview:_datesDisplay];
        [self addSubview:_scrollView];
        
        _datesDisplay.frame = CGRectMake(0, 0, _scrollView.frame.size.width, sizeFit.height);
        _scrollView.contentSize = _datesDisplay.frame.size;
    }
    else {
        _datesDisplay.hidden = NO;
        _scrollView.hidden = YES;
        [self addSubview:_datesDisplay];
        _datesDisplay.frame = _scrollView.frame;
    }
    
    
    
    
}


#pragma mark - CalendarManager delegate

// Exemple of implementation of prepareDayView method
// Used to customize the appearance of dayView
- (void)calendar:(JTCalendarManager *)calendar prepareDayView:(JTCalendarDayView *)dayView
{
    if(!self.mutilMode) {
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
    else {
        // Today
        if([_calendarManager.dateHelper date:[NSDate date] isTheSameDayThan:dayView.date]){
            dayView.circleView.hidden = NO;
            dayView.circleView.backgroundColor = [UIColor blueColor];
            dayView.dotView.backgroundColor = [UIColor whiteColor];
            dayView.textLabel.textColor = [UIColor whiteColor];
        }
        // Selected date
        else if([self isInDatesSelected:dayView.date]){
            dayView.circleView.hidden = NO;
            dayView.circleView.backgroundColor = [UIColor redColor];
            dayView.dotView.backgroundColor = [UIColor whiteColor];
            dayView.textLabel.textColor = [UIColor whiteColor];
        }
        // Other month
        else if(![_calendarManager.dateHelper date:_calendarContentView.date isTheSameMonthThan:dayView.date]){
            dayView.circleView.hidden = YES;
            dayView.dotView.backgroundColor = [UIColor redColor];
            dayView.textLabel.textColor = [UIColor lightGrayColor];
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
}


- (BOOL)haveEventForDay:(NSDate *)date
{
    return NO;
}


- (void)calendar:(JTCalendarManager *)calendar didTouchDayView:(JTCalendarDayView *)dayView
{
    if(!self.mutilMode) {
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
    else {
        if(_selectionMode && _datesSelected.count == 1 && ![_calendarManager.dateHelper date:[_datesSelected firstObject] isTheSameDayThan:dayView.date]){
            [_datesSelected addObject:dayView.date];
            [self selectDates];
            _selectionMode = NO;
            [_calendarManager reload];
            return;
        }
        
        
        if([self isInDatesSelected:dayView.date]){
            [_datesSelected removeObject:dayView.date];
            
            [UIView transitionWithView:dayView
                              duration:.3
                               options:0
                            animations:^{
                                [_calendarManager reload];
                                dayView.circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
                            } completion:nil];
        }
        else{
            [_datesSelected addObject:dayView.date];
            
            dayView.circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
            [UIView transitionWithView:dayView
                              duration:.3
                               options:0
                            animations:^{
                                [_calendarManager reload];
                                dayView.circleView.transform = CGAffineTransformIdentity;
                            } completion:nil];
        }
        
        if(_selectionMode) {
            return;
        }
        
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
        
        NSMutableArray *dayStrings = [[NSMutableArray alloc] init];
        for(NSDate *date in _datesSelected) {
            [dayStrings addObject:[NSString dateStringOfDate:date]];
        }
        self.dayStrings = [NSArray arrayWithArray:dayStrings];
        NSLog(@"%@", self.dayStrings);
        
        [self updateDatesSelected];
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


#pragma mark - Date selection

- (BOOL)isInDatesSelected:(NSDate *)date
{
    for(NSDate *dateSelected in _datesSelected){
        if([_calendarManager.dateHelper date:dateSelected isTheSameDayThan:date]){
            return YES;
        }
    }
    
    return NO;
}

- (void)selectDates
{
    NSDate * startDate = [_datesSelected firstObject];
    NSDate * endDate = [_datesSelected lastObject];
    
    if([_calendarManager.dateHelper date:startDate isEqualOrAfter:endDate]){
        NSDate *nextDate = endDate;
        while ([nextDate compare:startDate] == NSOrderedAscending) {
            [_datesSelected addObject:nextDate];
            nextDate = [_calendarManager.dateHelper addToDate:nextDate days:1];
        }
    }
    else {
        NSDate *nextDate = startDate;
        while ([nextDate compare:endDate] == NSOrderedAscending) {
            [_datesSelected addObject:nextDate];
            nextDate = [_calendarManager.dateHelper addToDate:nextDate days:1];
        }
    }
}



@end
