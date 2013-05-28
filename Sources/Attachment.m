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

#pragma mark - operations

-(void)loadWithProgressBlock:(AttachmentDownloadProgressBlock)progressBlock finishedBlock:(AttachmentDownloadFinishedBlock)finishedBlock errorBlock:(AttachmentDownloadErrorBlock)errorBlock {
    OperationProgressBlock myProgressBlock = nil;
    
    if (progressBlock) {
        myProgressBlock = ^(double progress){
            progressBlock(progress);
        };
    }
    
    [self.document.database
     getPath:[NSString stringWithFormat:@"%@/%@",self.document.identifier,self.name]
     params:nil
     progressBlock:myProgressBlock
     finishedBlock:^(MKNetworkOperation* completedOperation) {
         _data = completedOperation.responseData;
         if (finishedBlock) {
             finishedBlock(self);
         }
     }
     errorBlock:^(NSError* error) {
         if (errorBlock) {
             errorBlock(error);
         }
         if (self.document.database.globalErrorBlock) {
             self.document.database.globalErrorBlock(error);
         }
     }
     jsonParams:NO];
}

-(void)loadWithFinishedBlock:(AttachmentDownloadFinishedBlock)finishedBlock errorBlock:(AttachmentDownloadErrorBlock)errorBlock {
    [self loadWithProgressBlock:nil finishedBlock:finishedBlock errorBlock:errorBlock];
}

-(void)deleteWithFinishedBlock:(DeleteAttachmentFinishedBlock)finishedBlock errorBlock:(DeleteAttachmentErrorBlock)errorBlock {
    [self.document.database
     deletePath:[NSString stringWithFormat:@"%@/%@",self.document.identifier,self.name]
     params:@{@"rev":self.document.revision}
     finishedBlock:^(MKNetworkOperation* completedOperation) {
         if (finishedBlock) {
             [self.document.database loadDocumentWithIdentifier:self.document.identifier finishedBlock:^(Document* document) {
                 finishedBlock(document);
             } errorBlock:^(NSError* error) {
                 if (errorBlock) {
                     errorBlock(error);
                 }
                 if (self.document.database.globalErrorBlock) {
                     self.document.database.globalErrorBlock(error);
                 }
             }];
         }
     }
     errorBlock:^(NSError* error) {
         if (errorBlock) {
             errorBlock(error);
         }
         if (self.document.database.globalErrorBlock) {
             self.document.database.globalErrorBlock(error);
         }
     }
     jsonParams:NO];
}

@end
