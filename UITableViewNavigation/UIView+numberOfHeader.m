//
//  UIView+numberOfHeader.m
//  UITableViewNavigation
//
//  Created by Anatoly Ryavkin on 09/06/2019.
//  Copyright © 2019 AnatolyRyavkin. All rights reserved.
//

#import "UIView+numberOfHeader.h"

@implementation UIView (numberOfHeader)

-(UIView*)superViewRoot{

    UIView*superView = self;

    BOOL flagIsSuperView = YES;
    while (flagIsSuperView != NO) {
        UIView*superViewTemp = superView.superview;
        BOOL isHead = [superViewTemp isMemberOfClass:[UITableViewHeaderFooterView class]];
        if(superViewTemp== nil || isHead){
            flagIsSuperView = NO;
        }
        else{
            superView = superViewTemp;
            flagIsSuperView = YES;
        }
    }
    return superView;
}

@end
