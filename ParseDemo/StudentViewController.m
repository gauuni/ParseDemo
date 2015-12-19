//
//  StudentViewController.m
//  ParseDemo
//
//  Created by Nguyen Khoi Nguyen on 12/18/15.
//  Copyright © 2015 Nguyen Khoi Nguyen. All rights reserved.
//

#import "StudentViewController.h"
#import "StudentCell.h"
#import "StudentDetailViewController.h"

#import <Parse/Parse.h>
#import "SVPullToRefresh.h"
#import "UIScrollView+BottomRefreshControl.h"

#define rowIdKey @"rowId"
#define firstNameKey @"firstName"
#define lastNameKey @"lastName"
#define emailKey @"email"
#define phoneKey @"phone"
#define addressKey @"address"
#define avatarKey @"avatar"

@interface StudentViewController ()<StudentDetailViewControllerDelegate>
{
    NSMutableArray *studentArr;
    NSInteger pageNumber;
}
@end

@implementation StudentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    studentArr = [[NSMutableArray alloc] init];

    
    
    self.title = @"Students";
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(button_Add_Tapped)];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    self.navigationItem.rightBarButtonItem = [self editButtonItem];
    
    [self setUpHandlerForPullToRefreshWithTableView:self.tableView];
    
    //Get first page
    [self.tableView triggerPullToRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setUpHandlerForPullToRefreshWithTableView: (UITableView *)tableView{
    
    // Initialize the refresh control.
    UIRefreshControl *refreshControl = [UIRefreshControl new];
    refreshControl.triggerVerticalOffset = 100.;
    [refreshControl addTarget:self action:@selector(fetchNewData) forControlEvents:UIControlEventValueChanged];
    self.tableView.bottomRefreshControl = refreshControl;
    
}


-(void)fetchNewData{

        //query 20 items for each page
        PFQuery *query = [PFQuery queryWithClassName:@"Student" predicate:[self predicateQuery]];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            
            if (objects.count != 0) {
                [self insertDataAfterQuerying:objects];
            }
            
            [self.tableView.bottomRefreshControl endRefreshing];
        }];
    
 
    
}

-(NSPredicate *)predicateQuery{
    NSPredicate *predicate = [NSPredicate predicateWithFormat: [NSString stringWithFormat:@" %@ > %lu AND %@ <= %lu", rowIdKey, (unsigned long)studentArr.count, rowIdKey, (unsigned long)studentArr.count + 20]];
    return predicate;
}

-(void)insertDataAfterQuerying: (NSArray *)newObjects{
    // Prepare new indexPaths
    NSMutableArray *indexPathArr = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i<newObjects.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:studentArr.count+i inSection:0];
        [indexPathArr addObject:indexPath];
    }
    
    if (indexPathArr.count != 0) {
        // Append new objects
        [studentArr addObjectsFromArray:newObjects];
        
        // Add more cells
        [self.tableView insertRowsAtIndexPaths:indexPathArr withRowAnimation:UITableViewRowAnimationRight];

    }
}

#pragma mark - BarButton
-(void)button_Add_Tapped{
    StudentDetailViewController *studentDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"StudentDetailViewController"];
    studentDetailVC.delegate = self;
    [self presentViewController:studentDetailVC animated:YES completion:nil];
}

//-(void)button_Edit_Tapped: (UIBarButtonItem *)sender{
//    if (sender. == UIBarButtonSystemItemAdd) {
//       [self.tableView setEditing:YES animated:YES];
//        
//    }else{
//        [self.tableView setEditing:NO animated:YES];
//        
//    }
//    
//}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    // Add your custom code here
    [self.tableView setEditing:editing animated:YES];

}
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return studentArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    StudentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    PFObject *studentObject = [studentArr objectAtIndex:indexPath.row];
    
    cell.imageView_Avatar.image = nil;
    if (studentObject[avatarKey]) {
        PFFile *imageAvatar = studentObject[avatarKey];
        cell.imageView_Avatar.file = imageAvatar;
        [cell.imageView_Avatar loadInBackground];
    }else{
        cell.imageView_Avatar.image = [UIImage imageNamed:@"user-small-icon"];
    }
   
    cell.label_Name.text = [NSString stringWithFormat:@"%@ %@", studentObject[firstNameKey], studentObject[lastNameKey]];
    cell.label_Email.text = [NSString stringWithFormat:@"Emal: %@",studentObject[emailKey]];
    cell.label_Phone.text = [NSString stringWithFormat:@"Phone: %@", studentObject[phoneKey]];
    cell.label_Address.text = [NSString stringWithFormat:@"Address %@", studentObject[addressKey]];
    
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 140;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        PFObject *object = [studentArr objectAtIndex:indexPath.row];
        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [studentArr removeObject:object];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
            
        }];
       
    }
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    StudentCell *cell = (StudentCell *)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    StudentDetailViewController *studentDetailVC = (StudentDetailViewController *)segue.destinationViewController;
    studentDetailVC.delegate = self;
    studentDetailVC.studentObject = [studentArr objectAtIndex:indexPath.row];
}

-(void)didCompleteWithObject:(PFObject *)studentObject{
    
    if ([studentArr containsObject:studentObject]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[studentArr indexOfObject:studentObject] inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }else{
        [studentArr insertObject:studentObject atIndex:0];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }
    
}

@end
