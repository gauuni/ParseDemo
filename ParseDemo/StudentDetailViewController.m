//
//  StudentDetailViewController.m
//  ParseDemo
//
//  Created by Nguyen Khoi Nguyen on 12/18/15.
//  Copyright © 2015 Nguyen Khoi Nguyen. All rights reserved.
//

#import "StudentDetailViewController.h"
#import <ParseUI/ParseUI.h>

#define rowIdKey @"rowId"
#define firstNameKey @"firstName"
#define lastNameKey @"lastName"
#define emailKey @"email"
#define phoneKey @"phone"
#define addressKey @"address"
#define avatarKey @"avatar"

@interface StudentDetailViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>
{
    __weak IBOutlet UITableView *tableView_StudentDetail;
    __weak IBOutlet PFImageView *imageView_Avatar;
    __weak IBOutlet UIImageView *imageView_HeaderBackground;
}
@end

@implementation StudentDetailViewController

-(void)viewWillAppear:(BOOL)animated{
//    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
//    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    tableView_StudentDetail.dataSource = self;
    tableView_StudentDetail.delegate = self;
    tableView_StudentDetail.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (_studentObject[avatarKey]) {
        PFFile *imageAvatar = _studentObject[avatarKey];
        imageView_Avatar.file = imageAvatar;
        [imageView_Avatar loadInBackground];

    }else{
        imageView_Avatar.image = [UIImage imageNamed:@"user-small-icon"];
    }
    
    imageView_Avatar.contentMode = UIViewContentModeScaleAspectFill;
    imageView_Avatar.layer.cornerRadius = imageView_Avatar.frame.size.height/2;
    imageView_Avatar.clipsToBounds = YES;
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];

    imageView_HeaderBackground.backgroundColor = [UIColor colorWithRed:200/255 green:180/255 blue:190/255 alpha:1];
    if (!_studentObject) {
        _studentObject = [[PFObject alloc] initWithClassName:@"Student"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)button_Cancel_Tapped:(id)sender{
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)button_Done_Tapped:(id)sender{
    [self.view endEditing:YES];
    if (!_studentObject[rowIdKey]) {
        PFQuery *query = [PFQuery queryWithClassName:@"RowsNumber"];
        PFObject *rowsNumberObject = [query getFirstObject];
        int rowsNumber = [rowsNumberObject[@"rowsNumber"] intValue] + 1;
        rowsNumberObject[@"rowsNumber"] = [NSNumber numberWithInt:rowsNumber];
        _studentObject[rowIdKey] = [NSNumber numberWithInt:rowsNumber];
        
        [rowsNumberObject save];
    }
    [_studentObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [_delegate didCompleteWithObject:_studentObject];
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }else{
            
        }
    }];
}

-(IBAction)button_ChageAvatar_Tapped:(id)sender{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:nil
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *takePicture = [UIAlertAction actionWithTitle:@"Take Picture" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if ([UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
            pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            pickerController.delegate = self;
            [self presentViewController:pickerController animated:YES completion:nil];
        }
       
    }];
    
    UIAlertAction *pickGallery = [UIAlertAction actionWithTitle:@"Photos" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary]) {
            UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
            pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            pickerController.delegate = self;
            [self presentViewController:pickerController animated:YES completion:nil];
        }
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction: takePicture];
    [alertController addAction: pickGallery];
    [alertController addAction: cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - PickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    UIImage *chosenImage =  [self compressImage:info[UIImagePickerControllerOriginalImage]];
    NSData *imageData = UIImagePNGRepresentation(chosenImage);
    PFFile *imageFile = [PFFile fileWithName:[NSString stringWithFormat:@"%@.jpg",[self uuidString]] data:imageData];
    _studentObject[avatarKey] = imageFile;
    imageView_Avatar.image = chosenImage;

    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (UIImage*)compressImage:(UIImage*)image
{
    CGSize newSize = CGSizeMake(200, 200);
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(UIImage*)scaleImage: (UIImage*) sourceImage
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = 200 / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (NSString *)uuidString {
    // Returns a UUID
    
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    
    return uuidString;
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    UITextField *textField = (UITextField *)[cell.contentView viewWithTag:99];
    textField.delegate = self;
    switch (indexPath.row) {
        case 0:
            textField.placeholder = @"First Name";
            textField.text = _studentObject[firstNameKey];
            break;
        case 1:
            textField.placeholder = @"Last Name";
            textField.text = _studentObject[lastNameKey];
            break;
        case 2:
            textField.placeholder = @"Email";
            textField.text = _studentObject[emailKey];
            break;
        case 3:
            textField.placeholder = @"Phone";
            textField.text = _studentObject[phoneKey];
            break;
        default:
            textField.placeholder = @"Address";
            textField.text = _studentObject[addressKey];
            break;
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 52;
}

#pragma mark - Textfield
-(void)textFieldDidEndEditing:(UITextField *)textField{
    UITableViewCell *cell_FirstName = [tableView_StudentDetail cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UITextField *textField_FirstName = (UITextField *)[cell_FirstName.contentView viewWithTag:99];
    
    UITableViewCell *cell_LastName = [tableView_StudentDetail cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    UITextField *textField_LastName = (UITextField *)[cell_LastName.contentView viewWithTag:99];
    
    UITableViewCell *cell_Email = [tableView_StudentDetail cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    UITextField *textField_Email = (UITextField *)[cell_Email.contentView viewWithTag:99];
    
    UITableViewCell *cell_Phone = [tableView_StudentDetail cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    UITextField *textField_Phone = (UITextField *)[cell_Phone.contentView viewWithTag:99];
    
    UITableViewCell *cell_Address = [tableView_StudentDetail cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
    UITextField *textField_Address = (UITextField *)[cell_Address.contentView viewWithTag:99];
    
    if (textField == textField_FirstName) {
        _studentObject[firstNameKey] = textField.text;
    }
    
    if (textField == textField_LastName) {
        _studentObject[lastNameKey] = textField.text;
    }
    
    if (textField == textField_Email) {
        _studentObject[emailKey] = textField.text;
    }
    
    if (textField == textField_Phone) {
        _studentObject[phoneKey] = textField.text;
    }
    
    if (textField == textField_Address) {
        _studentObject[addressKey] = textField.text;
    }
}

#pragma mark - Keyboard
- (void)keyboardDidShow:(NSNotification *)notification
{
    // Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    //Given size may not account for screen rotation
    int height = MIN(keyboardSize.height,keyboardSize.width);
    [tableView_StudentDetail setContentInset:UIEdgeInsetsMake(0, 0, height + 20, 0)];
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    [tableView_StudentDetail setContentInset:UIEdgeInsetsZero];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
