//
//  AppDelegate.h
//  uploadtest
//
//  Created by Dhanush Balachandran on 7/1/12.
//  Copyright (c) 2012 My Things App Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <DropboxSDK/DropboxSDK.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, DBNetworkRequestDelegate, DBSessionDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSManagedObjectContext * dbcontext;
@property (strong, nonatomic) NSManagedObjectModel * dbmodel;
@property (strong, nonatomic) NSPersistentStoreCoordinator * dbstorecoor;
@property (strong, nonatomic) NSPersistentStore * dbstore;

@end
