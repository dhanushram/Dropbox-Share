//
//  AppDelegate.m
//  uploadtest
//
//  Created by Dhanush Balachandran on 7/1/12.
//  Copyright (c) 2012 My Things App Inc. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
{
    NSString * relinkUserId;
}

@end


@implementation AppDelegate

@synthesize window = _window;

@synthesize dbcontext, dbmodel, dbstorecoor, dbstore;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setUpSampleTxt];
    [self setUpDropbox];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	if ([[DBSession sharedSession] handleOpenURL:url]) {
		if ([[DBSession sharedSession] isLinked]) {
			NSLog(@"open url called");
		}
		return YES;
	}
	
	return NO;
}

- (void) setUpSampleTxt
{
    NSString * string = @"This is a Sample Text File";
    NSString *filePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Sample.txt"];
    [string writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    
}


#pragma mark - Dropbox Setup
- (void) setUpDropbox
{
    NSString* appKey = @"APPKEY";
	NSString* appSecret = @"APPSECRET";
	NSString *root = kDBRootAppFolder; // Should be set to either kDBRootAppFolder or kDBRootDropbox
    
    DBSession* session = [[DBSession alloc] initWithAppKey:appKey appSecret:appSecret root:root];
	session.delegate = self; // DBSessionDelegate methods allow you to handle re-authenticating
	[DBSession setSharedSession:session];
    [DBRequest setNetworkRequestDelegate:self];
}

#pragma mark - Application's documents directory

- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark - DBSessionDelegate methods

- (void)sessionDidReceiveAuthorizationFailure:(DBSession*)session userId:(NSString *)userId {
	relinkUserId = userId;
	[[[UIAlertView alloc] 
	   initWithTitle:@"Dropbox Session Ended" message:@"Do you want to relink?" delegate:self 
	   cancelButtonTitle:@"Cancel" otherButtonTitles:@"Relink", nil] show];
}


#pragma mark - DBNetworkRequestDelegate methods

static int outstandingRequests;

- (void)networkRequestStarted {
	outstandingRequests++;
	if (outstandingRequests == 1) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	}
}

- (void)networkRequestStopped {
	outstandingRequests--;
	if (outstandingRequests == 0) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}
}



@end
