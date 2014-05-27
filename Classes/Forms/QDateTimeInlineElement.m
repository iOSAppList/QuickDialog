//                                
// Copyright 2011 ESCOZ Inc  - http://escoz.com
// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this 
// file except in compliance with the License. You may obtain a copy of the License at 
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software distributed under
// the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF 
// ANY KIND, either express or implied. See the License for the specific language governing
// permissions and limitations under the License.
//

#import "QDateInlineTableViewCell.h"
#import "QDateTimeInlineElement.h"
#import "QDateEntryTableViewCell.h"

@implementation QDateTimeInlineElement {
@private
    NSDate *_maximumDate;
    NSDate *_minimumDate;

    __weak QTableViewCell *_cell;
}

@synthesize mode = _mode;
@synthesize centerLabel = _centerLabel;
@synthesize maximumDate = _maximumDate;
@synthesize minimumDate = _minimumDate;
@synthesize onValueChanged = _onValueChanged;
@synthesize minuteInterval = _minuteInterval;


- (QDateTimeInlineElement *)init {
    self = [super init];
    _dateValue = [NSDate date];
    self.keepSelected = YES;
    return self;
}

- (QDateTimeInlineElement *)initWithKey:(NSString *)key {
    self = [super initWithKey:key];
    _dateValue = [NSDate date];
    self.keepSelected = YES;
    return self;
}

- (QDateTimeInlineElement *)initWithTitle:(NSString *)string date:(NSDate *)date andMode:(UIDatePickerMode)mode{
    self = [super initWithTitle:string Value:[date description]];
    if (self!=nil){
        _dateValue = date;
        _mode = mode;
    }
    return self;
}


- (void)setTicksValue:(NSNumber *)ticks {
    if (ticks!=nil)
        self.dateValue = [NSDate dateWithTimeIntervalSince1970:ticks.doubleValue];
}

- (void)setDateValue:(NSDate *)date {
    _dateValue = date;
}

- (NSDate *)dateValue
{
    if (self.mode == UIDatePickerModeDate)   {
        NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *dateComponents = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:_dateValue];
        _dateValue = [gregorian dateFromComponents:dateComponents];
    }
    return _dateValue;
}

-(NSNumber *)ticksValue {
    return [NSNumber numberWithDouble:[self.dateValue timeIntervalSince1970]];
}

- (QDateTimeInlineElement *)initWithDate:(NSDate *)date andMode:(UIDatePickerMode)mode{
    return [self initWithTitle:nil date:date andMode:mode];
}

- (UITableViewCell *)getCellForTableView:(QuickDialogTableView *)tableView controller:(QuickDialogController *)controller {

    QTableViewCell *cell= self.showPickerInCell ? [self getInlineCell:tableView] : [self getEntryCell:tableView];
    return cell;
}

- (QDateInlineTableViewCell *)getInlineCell:(QuickDialogTableView *)tableView
{
    QDateInlineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QuickformDateTimeInlineElement"];
    if (cell == nil){
        cell = [[QDateInlineTableViewCell alloc] init];
    }
    _cell = cell;
    [cell prepareForElement:self inTableView:tableView];
    cell.selectionStyle = !self.enabled || self.showPickerInCell ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleBlue;
    cell.imageView.image = self.image;
    cell.labelingPolicy = self.labelingPolicy;

    return cell;
}

- (QDateEntryTableViewCell *)getEntryCell:(QuickDialogTableView *)tableView
{
    QDateEntryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QuickformDateTimeInlineElement"];
    if (cell == nil){
         cell = [[QDateEntryTableViewCell alloc] init];
    }
    _cell = cell;
    [cell prepareForElement:self inTableView:tableView];
    cell.selectionStyle = self.enabled ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
    cell.textField.enabled = self.enabled;
    cell.textField.userInteractionEnabled = self.enabled;
    cell.imageView.image = self.image;
    cell.labelingPolicy = self.labelingPolicy;
    return cell;
}

- (void)performAction
{
    if (self.showPickerInCell){
        BOOL shouldEdit = !_cell.isEditing;

        [((QuickDialogController *)self.controller).quickDialogTableView endEditingOnVisibleCells];
        [_cell setEditing:shouldEdit];
        [((QuickDialogController *)self.controller).quickDialogTableView reloadRowHeights];
    }
}


- (NSString *)textValue {
    NSTimeInterval timeInterval = self.dateValue.timeIntervalSinceNow;
    NSInteger ti = (NSInteger)timeInterval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02li:%02li:%02li", (long)hours, (long)minutes, (long)seconds];
}


- (void)fetchValueIntoObject:(id)obj {
	if (_key==nil)
		return;
    [obj setValue:_dateValue forKey:_key];
}

- (CGFloat)getRowHeightForTableView:(QuickDialogTableView *)tableView
{
    CGFloat height = [super getRowHeightForTableView:tableView];
    if (!_cell.isEditing || !self.showPickerInCell) {
        return height;
    }
    
    return height + 200;
}


@end
