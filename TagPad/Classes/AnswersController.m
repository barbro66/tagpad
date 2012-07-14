//
//  AnswersController.m
//  TagPad
//
//  Created by Malcolm Hall on 08/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AnswersController.h"


@implementation AnswersController
@synthesize tableView = _tableView;
@synthesize choices,checkedRows;


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell.accessoryType == UITableViewCellAccessoryNone){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [checkedRows addObject:indexPath];
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
        [checkedRows removeObject:indexPath];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [choices count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyIdentifier1";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.text = [choices objectAtIndex:indexPath.row];
    if([checkedRows containsObject:indexPath]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
	return cell;
}

-(NSArray*)answers{
    NSMutableArray* a = [NSMutableArray array];
    for(NSIndexPath* n in checkedRows){
        [a addObject:[choices objectAtIndex:n.row]];
    }
    return a;
}

//array of strings
-(void)setAnswers:(NSArray*)a{
    self.checkedRows = [NSMutableArray array];
    for(NSString* s in a){
        int i = 0;
        for(NSString* s2 in choices){
            if([s isEqualToString:s2]){
                [self.checkedRows addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            i++;
        }
    }
}

@end
