//
//  AVHeader.m
//  UITableViewNavigation
//
//  Created by Anatoly Ryavkin on 09/06/2019.
//  Copyright © 2019 AnatolyRyavkin. All rights reserved.
//

#import "AVHeader.h"

@implementation AVHeader

+(AVHeader*)superViewHeader:(UIView*)view{

    UIView*superView = view;
    UIView*superViewTemp;

    BOOL flagIsSuperView = YES;
    while (flagIsSuperView != NO) {
        superViewTemp = superView.superview;
        BOOL isHead = [superViewTemp isMemberOfClass:[AVHeader class]];
        if(superViewTemp== nil || isHead){
            flagIsSuperView = NO;
        }
        else{
            superView = superViewTemp;
            flagIsSuperView = YES;
        }
    }
    return (AVHeader*) superViewTemp;
}

@end
