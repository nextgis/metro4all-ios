//
//  MFASelectCityViewModel.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 02.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>
#import <SSZipArchive/SSZipArchive.h>

#import "MFASelectCityViewModel.h"

@interface MFASelectCityViewModel () <NSURLSessionDownloadDelegate, SSZipArchiveDelegate>

@end

@implementation MFASelectCityViewModel

- (void)loadCitiesWithCompletion:(void (^)(void))completionBlock;
{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task =
    [session dataTaskWithURL:[NSURL URLWithString:@"http://metro4all.org/data/v2.7/meta.json"]
           completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
               if (!error) {
                   NSDictionary *citiesData = [NSJSONSerialization JSONObjectWithData:data
                                                                              options:0
                                                                                error:&error];
                   
                   _cities = citiesData[@"packages"];
                   
                   [[NSUserDefaults standardUserDefaults] setObject:_cities forKey:@"MFA_CITIES_DATA"];
                   
                   if (completionBlock) {
                       completionBlock();
                   }
               }
               else {
                   NSLog(@"Failed to retreive cities data: %@", error);
                   _cities = nil;
                   
                   if (completionBlock) {
                       completionBlock();
                   }
               }
           }];
    
    [task resume];
}

- (void)setSelectedCity:(NSDictionary *)selectedCity
{
    _selectedCity = selectedCity;
    
    // download archive with city data
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                          delegate:self
                                                     delegateQueue:[[NSOperationQueue alloc] init]];
    
    NSURL *archiveURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://metro4all.org/data/v2.7/%@.zip", selectedCity[@"path"]]];
    
    [SVProgressHUD showWithStatus:@"Загружаются данные города" maskType:SVProgressHUDMaskTypeBlack];
    [[session downloadTaskWithURL:archiveURL] resume];
}

- (void)showErrorMessage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка"
                                                        message:@"Произошла ошибка при загрузке данных. Попробуйте повторить операцию или обратитесь в поддержку"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        [alert show];
    });
}

#pragma mark - NSURLSession Delegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSLog(@"successfully loaded zip for %@ to %@", self.selectedCity[@"name"], location);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    NSAssert(basePath, @"Cannot get path to Documents directory");
    
    NSURL *pathURL = [NSURL fileURLWithPath:basePath];
    pathURL = [NSURL URLWithString:[NSString stringWithFormat:@"data/%@", self.selectedCity[@"path"]]
                     relativeToURL:pathURL];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:[[[pathURL filePathURL] absoluteURL] path]
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    
    if (error) {
        NSLog(@"Failed to create directory structure: %@", error);
        [self showErrorMessage];
        return;
    }
    
//    [SVProgressHUD showWithStatus:@"Загружаются данные города" maskType:SVProgressHUDMaskTypeBlack];
    
    error = nil;
    [SSZipArchive unzipFileAtPath:[[location filePathURL] path]
                    toDestination:[[pathURL filePathURL] path]
                        overwrite:YES
                         password:nil
                            error:&error
                         delegate:self];
    
    if (error) {
        NSLog(@"Failed to open zip archive: %@", error);
        [self showErrorMessage];
        return;
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    if (totalBytesExpectedToWrite != NSURLSessionTransferSizeUnknown) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showProgress:(((float)totalBytesWritten) / totalBytesExpectedToWrite)
                                 status:@"Загружаются данные города"
                               maskType:SVProgressHUDMaskTypeBlack];
        });
    }
}

#pragma mark - SSZipArchive Delegate

- (void)zipArchiveProgressEvent:(NSInteger)loaded total:(NSInteger)total
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showProgress:(((float)loaded)/total)
                             status:@"Загружаются данные города"
                           maskType:SVProgressHUDMaskTypeBlack];
    });
}

- (void)zipArchiveDidUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo unzippedPath:(NSString *)unzippedPath
{
    NSLog(@"Successfully unzipped data for %@ into %@", self.selectedCity[@"name"], unzippedPath);
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
    
    
}

@end