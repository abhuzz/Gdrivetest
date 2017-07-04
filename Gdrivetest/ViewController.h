//
//  ViewController.h
//  Gdrivetest
//
//  Created by Abhay Korat on 03/07/17.
//  Copyright © 2017 Abhay Korat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Google/SignIn.h>
#import <GTLRDrive.h>

@interface ViewController : UIViewController <GIDSignInDelegate, GIDSignInUIDelegate>

@property (nonatomic, strong) IBOutlet GIDSignInButton *signInButton;
@property (nonatomic, strong) UITextView *output;
@property (nonatomic, strong) GTLRDriveService *service;
- (IBAction)Gotofileupload:(id)sender;

@end

