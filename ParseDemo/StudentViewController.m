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

#define maxItems 4
@interface StudentViewController ()<StudentDetailViewControllerDelegate>
{
    NSMutableArray *studentArr;
    NSInteger pageNumber;
    
    int recordCount;
    int pageCount;
    int recordsPerPage;
    int currentPage;
}
@end

@implementation StudentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    studentArr = [[NSMutableArray alloc] init];

    recordCount = pageCount = currentPage = 0;
    recordsPerPage = maxItems*2;
    
    
    self.title = @"Students";
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(button_Add_Tapped)];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    self.navigationItem.rightBarButtonItem = [self editButtonItem];
    
    [self setUpHandlerForPullToRefreshWithTableView:self.tableView];
    
    //Get first page
    [self fetchNewData];
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

//        //query 20 items for each page
//        PFQuery *query = [PFQuery queryWithClassName:@"Student" predicate:[self predicateQuery]];
//    query.limit = 20;
//    query.skip =
//        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
//            
//            if (objects.count != 0) {
//                [self insertDataAfterQuerying:objects];
//            }
//            
//            [self.tableView.bottomRefreshControl endRefreshing];
//        }];
    
    [self countRecords];
    
}

- (void)countRecords {
    PFQuery *query = [PFQuery queryWithClassName:@"Student"];
    // Other query parameters assigned here...
    [query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        // Do better error handling in your app...
        recordCount = count;
        pageCount   = count / maxItems + 1;
        if (currentPage<pageCount && currentPage>=0)
        [self loadRecordsForPageIndex:currentPage countPerPage: maxItems];
         [self.tableView.bottomRefreshControl endRefreshing];
    }];
}
- (void)loadRecordsForPageIndex:(NSInteger)pageIndex countPerPage:(NSInteger)count {
        PFQuery *query = [PFQuery queryWithClassName:@"Student"];
        // Other query parameters assigned here...
        query.limit    = count;
        query.skip     = pageIndex * count;
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            
            if (objects.count != 0) {
                [self insertDataAfterQuerying:objects];
            }
        }];
        currentPage++;
}



-(NSPredicate *)predicateQuery{
    NSPredicate *predicate = [NSPredicate predicateWithFormat: [NSString stringWithFormat:@" %@ > %lu AND %@ <= %lu", rowIdKey, (unsigned long)studentArr.count, rowIdKey, (unsigned long)studentArr.count + 40]];
    return predicate;
}

-(void)insertDataAfterQuerying: (NSArray *)newObjects{
    NSMutableArray *mutableNewObjects = [NSMutableArray arrayWithArray:newObjects];
    // Prepare new indexPaths
    for (PFObject *object in newObjects){
        for (PFObject *studentObject in studentArr) {
            if([studentObject[@"objectId"] isEqualToString:object[@"objectId"]]){
               [mutableNewObjects removeObject:object];
            }
        }
    }
    int maximumItems = maxItems;
    if (mutableNewObjects.count < maxItems) {
        maximumItems = mutableNewObjects.count;
    }
    NSMutableArray *indexPathArr = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i<maximumItems; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:studentArr.count+i inSection:0];
        [indexPathArr addObject:indexPath];
    }
    
    if (indexPathArr.count != 0) {
        // Append new objects
        [studentArr addObjectsFromArray:mutableNewObjects];
        
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
    cell.label_Email.text = [NSString stringWithFormat:@"Email: %@",studentObject[emailKey]];
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
