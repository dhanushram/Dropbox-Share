//
//  ViewController.m
//  uploadtest
//
//  Created by Dhanush Balachandran on 7/1/12.
//  Copyright (c) 2012 My Things App Inc. All rights reserved.
//

#import "ViewController.h"

#define TXT_FILE @"Sample.txt"

@interface ViewController ()
{
    NSString * txtFilePath;
    
    NSString * txtCopyFilePath;
    
    NSMutableData *receivedData;
    NSOutputStream *fileStream;
    
    DBRestClient * restClient;
    BOOL flag;
    int count;
}

@end

@implementation ViewController

    
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Original Txt file location
    txtFilePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:TXT_FILE];
    
    //Location of Txt file copy
    txtCopyFilePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Copy.txt"];
    
    flag = false;
    count = 0;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient =
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

//Set up link to Dropbox
- (IBAction)linkPressed:(id)sender {
    if (![[DBSession sharedSession] isLinked])
    {
		[[DBSession sharedSession] linkFromController:self];
    }
    else
    {
        DBLog(@"Dropbox Linked");
    }
}


// IBAction for copying text file to Dropbox
- (IBAction)copyPressed:(id)sender 
{

    NSString *localPath = txtFilePath;
    NSString *filename = TXT_FILE;
    NSString *destDir = @"/";
    [[self restClient] uploadFile:filename toPath:destDir
                    withParentRev:nil fromPath:localPath];
    
}

- (IBAction)downloadPressed:(id)sender 
{
    NSString *dbPath = [@"/" stringByAppendingString:TXT_FILE];
    [[self restClient] loadSharableLinkForFile:dbPath];
}


//Method to download file from Dropbox Sharable Link
- (void) downloadFile: (NSURL *) link
{
    if(flag)
    {
        fileStream = [NSOutputStream outputStreamToFileAtPath:txtCopyFilePath append:NO];
        [fileStream open];
    }
    
    // Create the request to download file through sharable link
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:link];
    NSURLConnection *theConnection=[NSURLConnection connectionWithRequest:theRequest delegate:self];
    if (!theConnection)
    {
        DBLog(@"No connection");
    }
}

#pragma mark - Application's documents directory
- (NSString *)applicationDocumentsDirectory 
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark - Log Error Method
- (void)logError:(NSError *)error inMethod:(SEL)method
{
    NSString *errorDescription = error.localizedDescription;
    if (!errorDescription) errorDescription = @"???";
    NSString *errorFailureReason = error.localizedFailureReason;
    if (!errorFailureReason) errorFailureReason = @"???";
    if (error) DBLog(@"[%@ %@] %@ (%@)", NSStringFromClass([self class]), NSStringFromSelector(method), errorDescription, errorFailureReason);
}

#pragma mark - Dropbox Delegates
- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata {
    
    DBLog(@"File uploaded successfully to path: %@", metadata.path);
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error
{
    [self logError:error inMethod:_cmd];
}


- (void)restClient:(DBRestClient*)restClient loadedSharableLink:(NSString*)link 
           forFile:(NSString*)path
{
    DBLog(@"Received Shareable Link: %@", link);
    [self downloadFile:[NSURL URLWithString:link]];
}
- (void)restClient:(DBRestClient*)restClient loadSharableLinkFailedWithError:(NSError*)error
{
    [self logError:error inMethod:_cmd];
}


#pragma mark - HTTP Delegates
- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse * httpResponse;
    NSString *          contentTypeHeader;
    
    
    httpResponse = (NSHTTPURLResponse *) response;
    assert( [httpResponse isKindOfClass:[NSHTTPURLResponse class]] );
    
    if ((httpResponse.statusCode / 100) != 2) {
        DBLog(@"%@",[NSString stringWithFormat:@"HTTP error %zd", (ssize_t) httpResponse.statusCode]);
    } else {
        contentTypeHeader = [httpResponse.allHeaderFields objectForKey:@"Content-Type"];
        if (contentTypeHeader == nil) {
            DBLog(@"No Content-Type!");
        } 
    }    
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
{
    NSInteger       dataLength;
    const uint8_t * dataBytes;
    NSInteger       bytesWritten;
    NSInteger       bytesWrittenSoFar;
    
    dataLength = [data length];
    dataBytes  = [data bytes];
    
    bytesWrittenSoFar = 0;
    do {
        bytesWritten = [fileStream write:&dataBytes[bytesWrittenSoFar] maxLength:dataLength - bytesWrittenSoFar];
        if (bytesWritten == -1) 
        {
            DBLog(@"File Stream: %@", fileStream);
            DBLog(@"File Stream Status: %u", fileStream.streamStatus);
            DBLog(@"File write error: %@", fileStream.streamError);
            break;
        } else {
            bytesWrittenSoFar += bytesWritten;
        }
    } while (bytesWrittenSoFar != dataLength);
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
{
    DBLog(@"Connection failed");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
    if(++count == 2) DBLog(@"Download through Share Link Finished!");
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
    if ([[[request URL] host] isEqualToString:@"www.dropbox.com"]  && !flag) 
    {
        NSString * restofcrap = [[request URL] relativePath]; 
        NSString * path = [@"https://dl.dropbox.com" stringByAppendingString:restofcrap];
        flag = true;
        [self downloadFile:[NSURL URLWithString:path]];
    }
    return request;
}

@end
