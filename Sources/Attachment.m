//
//  Attachment.m
//  objc-couchdb
//
//  Created by René Rössler on 08.04.13.
//  Copyright (c) 2013 FreshX GbR. All rights reserved.
//

#import "ObjC-CouchDB.h"
#import <CocoaLumberjack/DDLog.h>
extern int ddLogLevel;

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
    DDLogVerbose(@"[Attachment] Loading attachment:%@ of document:%@", self.name, self.document.identifier);
    OperationProgressBlock myProgressBlock = nil;
    
    if (progressBlock) {
        myProgressBlock = ^(double progress){
            DDLogVerbose(@"[Attachment] New progress:%f in loading attachment:%@ of document:%@", progress, self.name, self.document.identifier);
            progressBlock(progress);
        };
    }
    
    [self.document.database
     getPath:[NSString stringWithFormat:@"%@/%@",self.document.identifier,self.name]
     params:nil
     progressBlock:myProgressBlock
     finishedBlock:^(MKNetworkOperation* completedOperation) {
         DDLogVerbose(@"[Attachment] Done loading attachment:%@ of document:%@", self.name, self.document.identifier);
         
         _data = completedOperation.responseData;
         
         if (self.contentType == nil) {
             _contentType = completedOperation.readonlyResponse.MIMEType;
         }
         if (self.length == nil) {
             _length = [NSNumber numberWithInteger:_data.length];
         }
         
         if (finishedBlock) {
             finishedBlock(self);
         }
     }
     errorBlock:^(NSError* error) {
         DDLogError(@"[Attachment] Error:%@ loading attachment:%@ of document:%@", error.localizedDescription, self.name, self.document.identifier);
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
    DDLogVerbose(@"[Attachment] Deleting attachment:%@ of document:%@", self.name, self.document.identifier);
    
    [self.document.database
     deletePath:[NSString stringWithFormat:@"%@/%@",self.document.identifier,self.name]
     params:@{@"rev":self.document.revision}
     finishedBlock:^(MKNetworkOperation* completedOperation) {
         if (finishedBlock) {
             DDLogVerbose(@"[Attachment] Done deleting attachment:%@ of document:%@ - reloading document", self.name, self.document.identifier);
             [self.document.database loadDocumentWithIdentifier:self.document.identifier finishedBlock:^(Document* document) {
                 DDLogVerbose(@"[Attachment] Done reloading document after deleting attachment:%@ of document:%@", self.name, self.document.identifier);
                 finishedBlock(document);
             } errorBlock:^(NSError* error) {
                 DDLogVerbose(@"[Attachment] Error:%@ reloading document after deleting attachment:%@ of document:%@", error.localizedDescription, self.name, self.document.identifier);
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
         DDLogError(@"[Attachment] Error:%@ deleting attachment:%@ of document:%@", error.localizedDescription, self.name, self.document.identifier);
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
