//
//  Attachment.m
//  objc-couchdb
//
//  Created by René Rössler on 08.04.13.
//  Copyright (c) 2013 FreshX GbR. All rights reserved.
//

#import "objc_couchdb.h"

@implementation Attachment

-(id)initWithDocument:(Document*)document name:(NSString*)name properties:(NSDictionary*)properties {
    self = [super init];
    if (self) {
        _document = document;
        _name = name;
        
        _contentType = [properties objectForKey:@"content_type"];
        _revision = [properties objectForKey:@"revpos"];
        _digest = [properties objectForKey:@"digest"];
        _length = [properties objectForKey:@"length"];
        _stub = [[properties objectForKey:@"stub"] isEqualToNumber:@YES];
        if (_stub == YES) {
            _data = nil;
        } else {
            _data = [properties objectForKey:@"data"];
        }
    }
    return self;
}

#pragma mark - load operation

-(void)loadWithProgressBlock:(AttachmentDownloadProgressBlock)progressBlock finishedBlock:(AttachmentDownloadFinishedBlock)finishedBlock errorBlock:(AttachmentDownloadErrorBlock)errorBlock {
    MKNetworkOperation* operation = [self.document.database operationWithPath:[NSString stringWithFormat:@"%@/%@",self.document.identifier,self.name] params:nil httpMethod:@"GET"];
        
    [operation addCompletionHandler:^(MKNetworkOperation* completedOperation) {
        _data = completedOperation.responseData;
        dispatch_async(dispatch_get_main_queue(), ^{
            finishedBlock(self);
        });
    } errorHandler:^(MKNetworkOperation* completedOperation, NSError* error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            errorBlock(error);
        });
        
    }];
    [operation onDownloadProgressChanged:^(double progress) {
        if (progressBlock != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                progressBlock(progress);
            });
        }
    }];
    
    [self.document.database.engine enqueueOperation:operation];
}

-(void)loadWithFinishedBlock:(AttachmentDownloadFinishedBlock)finishedBlock errorBlock:(AttachmentDownloadErrorBlock)errorBlock {
    [self loadWithProgressBlock:nil finishedBlock:finishedBlock errorBlock:errorBlock];
}

@end
