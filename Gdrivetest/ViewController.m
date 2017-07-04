//
//  ViewController.m
//  Gdrivetest
//
//  Created by Abhay Korat on 03/07/17.
//  Copyright © 2017 Abhay Korat. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    GIDSignIn* signIn = [GIDSignIn sharedInstance];
    signIn.delegate = self;
    signIn.uiDelegate = self;
    signIn.scopes = [NSArray arrayWithObjects:kGTLRAuthScopeDriveReadonly, nil];
    [signIn signInSilently];
    
    // Add the sign-in button.
    self.signInButton = [[GIDSignInButton alloc] init];
    [self.view addSubview:self.signInButton];
    
    // Create a UITextView to display output.
    self.output = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.output.editable = false;
    self.output.contentInset = UIEdgeInsetsMake(120.0, 100.0, 120.0, 100.0);
    self.output.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.output.hidden = true;
   // [self.view addSubview:self.output];
    
    // Initialize the service object.
    self.service = [[GTLRDriveService alloc] init];
}

- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    if (error != nil) {
        [self showAlert:@"Authentication Error" message:error.localizedDescription];
        self.service.authorizer = nil;
    } else {
        self.signInButton.hidden = true;
        self.output.hidden = false;
        self.service.authorizer = user.authentication.fetcherAuthorizer;
        [self listFiles];
    }
}

// List up to 10 files in Drive
- (void)listFiles {
    GTLRDriveQuery_FilesList *query = [GTLRDriveQuery_FilesList query];
    query.fields = @"nextPageToken, files(id, name)";
    query.pageSize = 10;
    
    [self.service executeQuery:query
                      delegate:self
             didFinishSelector:@selector(displayResultWithTicket:finishedWithObject:error:)];
}

// Process the response and display output
- (void)displayResultWithTicket:(GTLRServiceTicket *)ticket
             finishedWithObject:(GTLRDrive_FileList *)result
                          error:(NSError *)error {
    if (error == nil) {
        NSMutableString *output = [[NSMutableString alloc] init];
        if (result.files.count > 0) {
            [output appendString:@"Files:\n"];
            int count = 1;
            for (GTLRDrive_File *file in result.files) {
                [output appendFormat:@"%@ (%@)\n", file.name, file.identifier];
                count++;
            }
        } else {
            [output appendString:@"No files found."];
        }
        self.output.text = output;
    } else {
        NSMutableString *message = [[NSMutableString alloc] init];
        [message appendFormat:@"Error getting presentation data: %@\n", error.localizedDescription];
        [self showAlert:@"Error" message:message];
    }
}


// Helper for showing an alert
- (void)showAlert:(NSString *)title message:(NSString *)message {
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:title
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok =
    [UIAlertAction actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
     {
         [alert dismissViewControllerAnimated:YES completion:nil];
     }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)uploadFileURL:(NSURL *)fileToUploadURL {
    
    
    
   // GTLRDriveService *service = [[GTLRDriveService alloc] init]; //self.driveService;
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"filevoice" ofType:@"mp3"];
    
    NSURL *url=[NSURL fileURLWithPath:path];
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    
    NSString *filename = [path lastPathComponent];
    NSString *mimeType = @"audio/mpeg"; //@"application/octet-stream";
    
    
  //  GTLRUploadParameters *uploadParameters = [GTLRUploadParameters uploadParametersWithFileHandle:fileHandle MIMEType:mimeType];
    // @"audio/mp3"
    
    
    GTLRUploadParameters *uploadParameters =
    [GTLRUploadParameters uploadParametersWithFileURL:fileToUploadURL
                                             MIMEType:mimeType];
    
    GTLRDrive_File *newFile = [GTLRDrive_File object];
    newFile.name = path.lastPathComponent;
    NSLog(@"%@",newFile.name);
    GTLRDriveQuery_FilesCreate *query =
    [GTLRDriveQuery_FilesCreate queryWithObject:newFile
                               uploadParameters:uploadParameters];
    
    GTLRServiceTicket *uploadTicket =
    [self.service executeQuery:query
        completionHandler:^(GTLRServiceTicket *callbackTicket,
                            GTLRDrive_File *uploadedFile,
                            NSError *callbackError) {
            if (callbackError == nil) {
                NSLog(@"Succeeded");
            }
            else
            {
                NSLog(@"%@",callbackError);
            }
        }];
}


- (IBAction)Gotofileupload:(id)sender {
    
    // filevoice.mp3
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"filevoice" ofType:@"mp3"];
    
    NSURL *url=[NSURL fileURLWithPath:path];
    
    
    [self uploadFileURL:url];
    

    
}



@end
