//
//  AVTableFolderControllerTableViewController.h
//  UITableViewNavigation
//
//  Created by Anatoly Ryavkin on 07/06/2019.
//  Copyright © 2019 AnatolyRyavkin. All rights reserved.
//

#import <UIKit/UIKit.h>



NS_ASSUME_NONNULL_BEGIN

@interface AVTableFolderControllerTableViewController : UITableViewController <UITextFieldDelegate,NSFileManagerDelegate>

@property (nonatomic) NSString*path;
@property NSArray*content;
@property NSDictionary*dictionaryHeaders;
@property (weak) UITextField*addressTypeField;
@property NSString*tempPath;
@property (weak) UIButton*buttonEditTable;
@property NSString*pathTempForRecursForSize;
@property NSArray*contentTempForRecursForSize;

-(void)actionBackController:(UIBarButtonItem*)sender;
-(void)actionSort:(UIButton*)sender;
-(void)actionAddFolder:(UIButton*)sender;
-(void)actionToGoAddress:(UIButton*)sender;
-(NSString*)sizeFileAtIndexPath:(NSIndexPath*)indexPath;

@end

NS_ASSUME_NONNULL_END
