//
//  AVHeader.h
//  UITableViewNavigation
//
//  Created by Anatoly Ryavkin on 09/06/2019.
//  Copyright © 2019 AnatolyRyavkin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVHeader : UITableViewHeaderFooterView

@property (nonatomic) NSInteger section;

+(AVHeader*)superViewHeader:(UIView*)view;

@end

NS_ASSUME_NONNULL_END
