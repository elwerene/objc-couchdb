//
//  Document.m
//  objc-couchdb
//
//  Created by René Rössler on 08.04.13.
//  Copyright (c) 2013 FreshX GbR. All rights reserved.
//

#import "ObjC-CouchDB.h"
#import <PathHelper/PathHelper.h>
#import <CocoaLumberjack/DDLog.h>
extern int ddLogLevel;

@implementation Document

-(id)initWithDatabase:(Database*)database properties:(NSDictionary*)properties {
    self = [super init];
    if (self) {
        _database = database;
        _properties = properties;
        _identifier = [properties getStringWithPath:@"_id"];
        _revision = [properties getStringWithPath:@"_rev"];
        _deleted = [[properties getNumberWithPath:@"deleted"] isEqualToNumber:@YES];
        
        NSDictionary* metaAttachments = [properties getNonEmptyDictionaryWithPath:@"_attachments"];
        NSMutableDictionary* attachments = [NSMutableDictionary dictionary];
        for (NSString* name in metaAttachments.allKeys) {
            NSDictionary* metaAttachment = [metaAttachments objectForKey:name];
            Attachment* attachment = [[Attachment alloc] initWithDocument:self name:name properties:metaAttachment];
            [attachments setObject:attachment forKey:name];
        }
        _attachments = attachments;
    }
    return self;
}

-(NSString*)description {
    return [NSString stringWithFormat:@"<Document: database=%@ identifier=%@ revision=%@>",self.database,self.identifier,self.revision];
}

#pragma mark - operations

-(void)deleteWithFinishedBlock:(DeleteDocumentFinishedBlock)finishedBlock errorBlock:(DeleteDocumentErrorBlock)errorBlock {
    DDLogVerbose(@"[Document] Deleting document with identifier:%@", self.identifier);
    [self.database
     deletePath:self.identifier
     params:@{@"rev":self.revision}
     finishedBlock:^(MKNetworkOperation* completedOperation) {
         DDLogVerbose(@"[Document] Done deleting document with identifier:%@", self.identifier);
         if (finishedBlock) {
             finishedBlock();
         }
     }
     errorBlock:^(NSError* error) {
         DDLogVerbose(@"[Document] Error:%@ deleting document with identifier:%@", error.localizedDescription, self.identifier);
         
         if (errorBlock) {
             errorBlock(error);
         }
         if (self.database.globalErrorBlock) {
             self.database.globalErrorBlock(error);
         }
     }
     jsonParams:NO];
}

-(void)putProperties:(NSDictionary*)properties finishedBlock:(PutPropertiesFinishedBlock)finishedBlock errorBlock:(PutPropertiesErrorBlock)errorBlock {
    DDLogVerbose(@"[Document] Putting new properties:%@ for Document with identifier:%@", properties, self.identifier);
    if (![[properties getStringWithPath:@"_id"] isEqualToString:self.identifier]) {
        NSError* error = [NSError errorWithDomain:@"UsageError" code:0 userInfo:@{NSLocalizedDescriptionKey:@"Changing document identifier is not allowed."}];
        DDLogError(@"[Document] Error:%@ putting new properties:%@ for Document with identifier:%@", error.localizedDescription, properties, self.identifier);
        if (errorBlock) {
            errorBlock(error);
        }
        if (self.database.globalErrorBlock) {
            self.database.globalErrorBlock(error);
        }
        return;
    }
    if (![[properties getStringWithPath:@"_rev"] isEqualToString:self.revision]) {
        NSError* error = [NSError errorWithDomain:@"UsageError" code:0 userInfo:@{NSLocalizedDescriptionKey:@"Changing document revision is not allowed."}];
        DDLogError(@"[Document] Error:%@ putting new properties:%@ for Document with identifier:%@", error.localizedDescription, properties, self.identifier);
        if (errorBlock) {
            errorBlock(error);
        }
        if (self.database.globalErrorBlock) {
            self.database.globalErrorBlock(error);
        }
        return;
    }
    DDLogVerbose(@"[Document] Deleting document with identifier:%@", self.identifier);
    
    [self.database
     putPath:self.identifier
     params:properties
     progressBlock:nil
     finishedBlock:^(MKNetworkOperation* completedOperation) {
         DDLogVerbose(@"[Document] Done putting new properties:%@ for Document with identifier:%@", properties, self.identifier);
         
         if (finishedBlock) {
             NSString* revision = [completedOperation.responseJSON getStringWithPath:@"rev"];
             NSMutableDictionary* newProperties = [properties mutableCopy];
             [newProperties setObject:revision forKey:@"_rev"];
             Document* document = [[Document alloc] initWithDatabase:self.database properties:newProperties];
             finishedBlock(document);
         }
     }
     errorBlock:^(NSError* error) {
         DDLogError(@"[Document] Error:%@ putting new properties:%@ for Document with identifier:%@", error.localizedDescription, properties, self.identifier);
         if (errorBlock) {
             errorBlock(error);
         }
         if (self.database.globalErrorBlock) {
             self.database.globalErrorBlock(error);
         }
     }
     jsonParams:YES];
}

-(void)putAttachmentNamed:(NSString*)name mimetype:(NSString*)mimetype data:(NSData*)data progressBlock:(PutAttachmentProgressBlock)progressBlock finishedBlock:(PutAttachmentFinishedBlock)finishedBlock errorBlock:(PutAttachmentErrorBlock)errorBlock {
    DDLogVerbose(@"[Document] Putting attachment named:%@ for Document with identifier:%@", name, self.identifier);
    
    MKNetworkOperation* operation = [self.database operationWithPath:[NSString stringWithFormat:@"%@/%@?rev=%@",self.identifier,name,self.revision] params:nil httpMethod:@"PUT" jsonParams:NO];
    
    NSInputStream* input = [[NSInputStream alloc] initWithData:data];
    [operation setUploadStream:input];
    
    [operation addHeaders:@{@"Content-Type":mimetype,@"Content-Length":[NSString stringWithFormat:@"%i",data.length]}];
    
    [operation addCompletionHandler:^(MKNetworkOperation* completedOperation) {
        if (finishedBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                DDLogVerbose(@"[Document] Done putting attachment named:%@ for Document with identifier:%@ - reloading document", name, self.identifier);
                
                [self.database loadDocumentWithIdentifier:self.identifier finishedBlock:^(Document* document) {
                    DDLogVerbose(@"[Document] Done reloading document after putting attachment named:%@ for Document with identifier:%@", name, self.identifier);
                    
                    finishedBlock(document);
                } errorBlock:^(NSError* error) {
                    DDLogError(@"[Document] Error:%@ reloading document after putting attachment named:%@ for Document with identifier:%@", error.localizedDescription, name, self.identifier);
                    
                    if (errorBlock) {
                        errorBlock(error);
                    }
                    if (self.database.globalErrorBlock) {
                        self.database.globalErrorBlock(error);
                    }
                }];
            });
        }
    } errorHandler:^(MKNetworkOperation* completedOperation, NSError* error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            DDLogError(@"[Document] Error:%@ putting attachment named:%@ for Document with identifier:%@", error.localizedDescription, name, self.identifier);
            
            if (errorBlock) {
                errorBlock(error);
            }
            if (self.database.globalErrorBlock) {
                self.database.globalErrorBlock(error);
            }
        });
    }];
    
    if (progressBlock) {
        [operation onUploadProgressChanged:^(double progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                DDLogVerbose(@"[Document] New progress:%f in putting attachment named:%@ for Document with identifier:%@", progress, name, self.identifier);
                
                progressBlock(progress);
            });
        }];
    }
    
    [self.database.engine enqueueOperation:operation];
}

@end
