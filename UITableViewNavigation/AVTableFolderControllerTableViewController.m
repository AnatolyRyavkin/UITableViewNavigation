//
//  AVTableFolderControllerTableViewController.m
//  UITableViewNavigation
//
//  Created by Anatoly Ryavkin on 07/06/2019.
//  Copyright © 2019 AnatolyRyavkin. All rights reserved.
///     /Users/ryavkinto/Documents/Objective C

#import "AVTableFolderControllerTableViewController.h"
#import "UIView+numberOfHeader.h"
#import "AVHeader.h"

FOUNDATION_EXPORT NSFileAttributeKey const NSFileSize;


static NSString*identifaerDirectory = @"identifaerDirectory";
static NSString*identifaerFile = @"identifaerFile";
static NSString*identifierHeader = @"identifierHeader";

@interface AVTableFolderControllerTableViewController ()


@end

@implementation  AVTableFolderControllerTableViewController

#pragma mark DidLoad and functionsAccess

-(BOOL)isDirectoryAtIndexPath:(NSIndexPath*)indexPath{
    BOOL isDirectory = NO;
    NSString*fileName = [self.content objectAtIndex:indexPath.row];
    NSString*path = [self.path stringByAppendingPathComponent:fileName];
    [[NSFileManager defaultManager]fileExistsAtPath:path isDirectory:&isDirectory];
    return isDirectory;
}

-(NSDictionary*)getInfoItemAtPath:(NSString*)path{
    NSError*error = nil;
    NSFileManager*manager =  [NSFileManager defaultManager];
    NSDictionary*dict = [manager attributesOfItemAtPath:path error:&error];
    if(error){
        NSLog(@"%@",[error localizedDescription]);
    }
    return dict;
}

-(void)setPath:(NSString *)path{
    _path = path;
    NSError*error = nil;
    self.content = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:self.path error:&error];
    if(error){
        NSLog(@"%@",[error localizedDescription]);
    }
    else{
        [self.tableView reloadData];
        self.navigationItem.title = [self.path lastPathComponent];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(self.navigationController.viewControllers.count>1){
        UIBarButtonItem*buttonItem = [[UIBarButtonItem alloc]initWithTitle:@"BackController" style:UIBarButtonItemStylePlain target:self action:@selector(actionBackController:)];
        NSArray*arrayRigtBarButtons = @[buttonItem];
        [self.navigationItem setRightBarButtonItems:arrayRigtBarButtons animated:YES];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        NSLog(@"count = %@",self.navigationController.viewControllers);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if(!self.path)
         self.path = @"/Users/ryavkinto/Documents";
     self.tempPath = [NSString stringWithString:self.path];
     self.tableView.sectionHeaderHeight = 50;
    self.dictionaryHeaders = [[NSDictionary alloc]init];
    self.addressTypeField.delegate = self;
}

#pragma mark - SizeOutput

-(BOOL)isDirectoryAtPath:(NSString*)path{
    BOOL isDirectory = NO;
    [[NSFileManager defaultManager]fileExistsAtPath:path isDirectory:&isDirectory];
    return isDirectory;
}

-(NSUInteger)sizeFolderAtPath:(NSString*)fullPath inContent:(NSArray*)currentContext{
    NSUInteger sizeInt = 0;
    NSString*path = fullPath;
    NSError*error = nil;
    NSArray*content = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:path error:&error];
    if(error){
        NSLog(@"%@",[error localizedDescription]);
    }
    else{
        for(NSString*name in content){
            NSString*newPath = [path stringByAppendingPathComponent:name];
             if([self isDirectoryAtPath:newPath]){

                 sizeInt = sizeInt + [self sizeFolderAtPath:newPath inContent:content];

             }else{
                 NSDictionary*dictionaryInfo = [self getInfoItemAtPath:newPath];
                 NSUInteger size = [[dictionaryInfo objectForKey:NSFileSize] integerValue];
                 sizeInt = sizeInt + size;
             }
        }
    }
    return sizeInt;
}

-(NSString*)sizeFileAtIndexPath:(NSIndexPath*)indexPath{
   NSString*name = [self.content objectAtIndex:indexPath.row];
   NSString*path = [self.path stringByAppendingPathComponent:name];
   NSDictionary*dictionaryInfo = [self getInfoItemAtPath:path];
   NSUInteger size = [[dictionaryInfo objectForKey:NSFileSize] integerValue];
    return [self sizeAtInt:size];
}

-(NSString*)sizeAtInt:(NSUInteger)sizeInt{
    CGFloat size = (CGFloat)sizeInt;
    NSString*result;
    if(size<1024){
        result = [NSString stringWithFormat:@"%d Bt",(int)size];
    }else if(size<1024*1024){
        result = [NSString stringWithFormat:@"%.2f KBt",size/1024];
    }else if(size<1024*1024*1024){
        result = [NSString stringWithFormat:@"%.2f MBt",size/(1024*1024)];
    }else{
        result = [NSString stringWithFormat:@"%.2f GBt",size/(1024*1024*1024)];
    }
    return result;
}


#pragma mark - TextFieldAddAddress


-(NSString*)stringAtAddrres: (NSString*)textFieldString stringNewName: (NSString*)string rangeInput: (NSRange)range{

    NSMutableString*stringTemp=[[NSMutableString alloc]initWithString:textFieldString];

    NSMutableCharacterSet *setControl = [NSMutableCharacterSet letterCharacterSet];
    [setControl addCharactersInString:@"/1234567890. "];
    [setControl invert];
    NSLog(@"%@",setControl);

    NSArray*arrayCheckAtNumber=[string componentsSeparatedByCharactersInSet:setControl];

    if(arrayCheckAtNumber.count==1){
        [stringTemp replaceCharactersInRange:range withString:string];
        return stringTemp;
    }else{
        return textFieldString;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    switch (textField.tag) {
        case 1:
            if(textField.text.length+string.length<50 && ![string isEqualToString:@""]){
                textField.text = [self stringAtAddrres:textField.text stringNewName:string rangeInput:range];
                return NO;
            }else if([string isEqualToString:@""]){
                return YES;
            }
            break;
        default:
            return NO;
            break;
    }
    return NO;
}


- (BOOL)textFieldShouldClear:(UITextField *)textField{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSArray*array=[NSArray arrayWithObjects:self.addressTypeField, nil];
    if(textField.tag==1){
        [textField resignFirstResponder];
    }else{
        [[array objectAtIndex:textField.tag] becomeFirstResponder];
    }
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if(textField.tag==1){
        NSError*error;
        NSArray*content = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:textField.text error:&error];
        if(error){
            NSLog(@"%@",[error localizedDescription]);
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning!!!"
                                                                           message:@"This addres dont exist!"
                                                                    preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel
                                                                  handler:^(UIAlertAction * action) {NSLog(@"allert appears!");}];

            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            [self.tableView reloadData];
        }else{
            AVTableFolderControllerTableViewController*vc = [[AVTableFolderControllerTableViewController alloc]init];
            vc.path = textField.text;
            [self.navigationController pushViewController:vc animated:YES];
            [self.tableView reloadData];
        }
    }

}

#pragma mark - Action

-(void)actionGoUp:(UIButton*)sender{
    NSString*path = self.path.stringByDeletingLastPathComponent;
    //NSLog(@"%@",[self getInfoItemAtPath:path]);
    if([self isDirectoryAtPath:path]){
        AVTableFolderControllerTableViewController*vc = [[AVTableFolderControllerTableViewController alloc]init];
        vc.path = path;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

-(void) editActionBegin:(UIBarButtonItem*)sender{
        if(self.tableView.isEditing == YES){
            [self.buttonEditTable setTitle:@"EDIT" forState:UIControlStateNormal];
            self.tableView.editing = NO;
        }else{
            [self.buttonEditTable setTitle:@"DOWN" forState:UIControlStateNormal];
            self.tableView.editing = YES;
        }
}

-(void)actionSort:(UIButton*)sender{

    NSMutableArray*arrayFileTemp = [[NSMutableArray alloc]init];
    NSMutableArray*arrayFolderTemp = [[NSMutableArray alloc]init];
    NSMutableArray*arrayResult = [[NSMutableArray alloc]init];

    NSInteger countPath = [self.tableView numberOfRowsInSection:0];
    for(int i=0;i<countPath;i++){
        NSIndexPath*indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        if([self isDirectoryAtIndexPath:indexPath])
            [arrayFolderTemp addObject:[self.content objectAtIndex:i]];
        else
            [arrayFileTemp addObject:[self.content objectAtIndex:i]];
    }
    [arrayFolderTemp sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];

    [arrayFileTemp sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];

    [arrayResult addObjectsFromArray:arrayFolderTemp];
    [arrayResult addObjectsFromArray:arrayFileTemp];
    self.content = [NSArray arrayWithArray:arrayResult];
    [self.tableView reloadData];

}

-(void)actionAddFolder:(UIButton*)sender{
    static int numberNewFile = 0;
    numberNewFile++;
    NSString*path = [self.path stringByAppendingPathComponent:[NSString stringWithFormat:@"New folder%d",numberNewFile]];
    NSFileManager *fileManager= [NSFileManager defaultManager];
    NSError *error = nil;
    if(![fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
        NSLog(@"Failed to create directory \"%@\". Error: %@", path, error);
    }
    self.path = self.path;
}

-(void)actionToGoAddress:(UIButton*)sender{

    AVHeader*header =[AVHeader superViewHeader:sender];
    UITextField*inputAddressFild = [[UITextField alloc]initWithFrame:CGRectMake(450, 10, CGRectGetWidth(self.tableView.bounds)-480,30)];
    inputAddressFild.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:1];
    inputAddressFild.placeholder = @"                 type address";
    inputAddressFild.text = @"/";
    [header addSubview:inputAddressFild];
    inputAddressFild.tag = 1;
    self.addressTypeField = inputAddressFild;
    self.addressTypeField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.addressTypeField.delegate = self;
    self.addressTypeField.allowsEditingTextAttributes = YES;
    [self.addressTypeField becomeFirstResponder];

}

-(void)actionBackController:(UIBarButtonItem*)sender{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - NSFileManagerDelegate

- (BOOL)isDeletableFileAtPath:(NSString *)path{
    NSLog(@"%@",path);
    return YES;
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{

    NSString*fileName = [self.content objectAtIndex:indexPath.row];
    NSString*path = [self.path stringByAppendingPathComponent:fileName];
    NSLog(@"%d",[[NSFileManager defaultManager]isDeletableFileAtPath:path]);
    NSError*error = nil;
    [[NSFileManager defaultManager]removeItemAtPath:path error:&error];
    if(error){
        NSLog(@"%@",[error localizedDescription]);
    }
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    self.path = self.path;
    [self.tableView endUpdates];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.content.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell*cell;



    if([self isDirectoryAtIndexPath:indexPath]){
        cell = [tableView dequeueReusableCellWithIdentifier:identifaerDirectory];
        if(!cell)
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifaerDirectory];
        NSString*name = [self.content objectAtIndex:indexPath.row];
        cell.textLabel.text = name;
        cell.imageView.image = [UIImage imageNamed:@"folder.png"];
        self.pathTempForRecursForSize = [self.path stringByAppendingPathComponent:name];
        self.contentTempForRecursForSize = [NSArray arrayWithArray:self.content];
        cell.detailTextLabel.text = [self sizeAtInt:[self sizeFolderAtPath:self.pathTempForRecursForSize inContent:self.content]];
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:identifaerFile];
        if(!cell)
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifaerFile];
        NSString*name = [self.content objectAtIndex:indexPath.row];
        cell.textLabel.text = name;
        cell.imageView.image = [UIImage imageNamed:@"file.png"];
        cell.detailTextLabel.text = [self sizeFileAtIndexPath:indexPath];
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    AVHeader *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:identifierHeader];

    if(headerView==nil){

        headerView = [[AVHeader alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), 50)];
        headerView.contentView.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:1];

        UIButton*buttonGoUp = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttonGoUp addTarget:self action:@selector(actionGoUp:) forControlEvents:UIControlEventTouchDown];
        buttonGoUp.frame = CGRectMake(0, 0, 60, 50);
        [buttonGoUp setTitle:@"GoUp" forState:UIControlStateNormal];
        [buttonGoUp setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [buttonGoUp setContentMode:UIViewContentModeCenter];
        [buttonGoUp setBackgroundColor:[UIColor grayColor]];

        UIButton*buttonEditTable = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttonEditTable addTarget:self action:@selector(editActionBegin:) forControlEvents:UIControlEventTouchDown];
        buttonEditTable.frame = CGRectMake(70, 0,60, 50);
        [buttonEditTable setTitle:@"EDIT" forState:UIControlStateNormal];
        [buttonEditTable setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [buttonEditTable setContentMode:UIViewContentModeCenter];
        [buttonEditTable setBackgroundColor:[UIColor grayColor]];

        UIButton*buttonSort = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttonSort addTarget:self action:@selector(actionSort:) forControlEvents:UIControlEventTouchDown];
        buttonSort.frame = CGRectMake(140, 0, 60, 50);
        [buttonSort setTitle:@"SORT" forState:UIControlStateNormal];
        [buttonSort setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [buttonSort setContentMode:UIViewContentModeCenter];
        [buttonSort setBackgroundColor:[UIColor grayColor]];

        UIButton*buttonAddFolder = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttonAddFolder addTarget:self action:@selector(actionAddFolder:) forControlEvents:UIControlEventTouchDown];
        buttonAddFolder.frame = CGRectMake(210, 0, 100, 50);
        [buttonAddFolder setTitle:@"AddFolder" forState:UIControlStateNormal];
        [buttonAddFolder setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [buttonAddFolder setContentMode:UIViewContentModeCenter];
        [buttonAddFolder setBackgroundColor:[UIColor grayColor]];

        UIButton*buttonGoAddress = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttonGoAddress addTarget:self action:@selector(actionToGoAddress:) forControlEvents:UIControlEventTouchDown];
        buttonGoAddress.frame = CGRectMake(320, 0, 120, 50);
        [buttonGoAddress setTitle:@"GoToAddress" forState:UIControlStateNormal];
        [buttonGoAddress setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [buttonGoAddress setContentMode:UIViewContentModeCenter];
        [buttonGoAddress setBackgroundColor:[UIColor grayColor]];

        [headerView addSubview:buttonSort];
        [headerView addSubview:buttonAddFolder];
        [headerView addSubview:buttonGoAddress];
        [headerView addSubview:buttonEditTable];
        [headerView addSubview:buttonGoUp];

        self.buttonEditTable = buttonEditTable;

        NSMutableDictionary*dictionaryHeaderTemp = [NSMutableDictionary dictionaryWithDictionary:self.dictionaryHeaders];
        [dictionaryHeaderTemp setObject:headerView forKey:[NSNumber numberWithInteger:section]];
        self.dictionaryHeaders = [NSDictionary dictionaryWithDictionary:dictionaryHeaderTemp];

    }

    headerView.section = section;

    return headerView;
}

#pragma mark - Delegat

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSString*name = [self.content objectAtIndex:indexPath.row];
    NSString*path = [self.path stringByAppendingPathComponent:name];
   // NSLog(@"%@",[self getInfoItemAtPath:path]);
    if([self isDirectoryAtIndexPath:indexPath]){
        AVTableFolderControllerTableViewController*vc = [[AVTableFolderControllerTableViewController alloc]init];
        vc.path = path;
        [self.navigationController pushViewController:vc animated:YES];

    }
}



@end
