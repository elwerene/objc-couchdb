//
//  Document.m
//  objc-couchdb
//
//  Created by René Rössler on 08.04.13.
//  Copyright (c) 2013 FreshX GbR. All rights reserved.
//

#import "objc_couchdb.h"

@implementation Document

-(id)initWithDatabase:(Database*)database properties:(NSDictionary*)properties {
    self = [super init];
    if (self) {
        _database = database;
        _properties = properties;
        _identifier = [properties objectForKey:@"_id"];
        _revision = [properties objectForKey:@"_rev"];
        _deleted = [[properties objectForKey:@"deleted"] isEqualToNumber:@YES];
        
        NSDictionary* metaAttachments = [properties objectForKey:@"_attachments"];
        if (metaAttachments == nil || metaAttachments.count == 0) {
            _attachments = @{};
        } else {
            NSMutableDictionary* attachments = [NSMutableDictionary dictionary];
            for (NSString* name in metaAttachments.allKeys) {
                NSDictionary* metaAttachment = [metaAttachments objectForKey:name];
                Attachment* attachment = [[Attachment alloc] initWithDocument:self name:name properties:metaAttachment];
                [attachments setObject:attachment forKey:name];
            }
            _attachments = attachments;
        }
    }
    return self;
}

-(NSString*)description {
    return [NSString stringWithFormat:@"<Document: database=%@ identifier=%@ revision=%@>",self.database,self.identifier,self.revision];
}

#pragma mark - operations

-(void)deleteWithFinishedBlock:(DeleteDocumentFinishedBlock)finishedBlock errorBlock:(DeleteDocumentErrorBlock)errorBlock {
    [self.database
     deletePath:self.identifier
     params:@{@"rev":self.revision}
     finishedBlock:^(MKNetworkOperation* completedOperation) {
         if (finishedBlock) {
             finishedBlock();
         }
     }
     errorBlock:^(NSError* error) {
         if (errorBlock) {
             errorBlock(error);
         }
     }];
}

-(void)putProperties:(NSDictionary*)properties finishedBlock:(PutPropertiesFinishedBlock)finishedBlock errorBlock:(PutPropertiesErrorBlock)errorBlock {
    if (![[properties objectForKey:@"_id"] isEqualToString:self.identifier]) {
        if (errorBlock) {
            errorBlock([NSError errorWithDomain:@"UsageError" code:0 userInfo:@{NSLocalizedDescriptionKey:@"Changing document identifier is not allowed."}]);
        }
        return;
    }
    if (![[properties objectForKey:@"_rev"] isEqualToString:self.revision]) {
        if (errorBlock) {
            errorBlock([NSError errorWithDomain:@"UsageError" code:0 userInfo:@{NSLocalizedDescriptionKey:@"Changing document revision is not allowed."}]);
        }
        return;
    }
    
    [self.database
     putPath:self.identifier
     params:properties
     finishedBlock:^(MKNetworkOperation* completedOperation) {
         if (finishedBlock) {
             NSString* revision = [completedOperation.responseJSON objectForKey:@"rev"];
             NSMutableDictionary* newProperties = [properties mutableCopy];
             [newProperties setObject:revision forKey:@"_rev"];
             Document* document = [[Document alloc] initWithDatabase:self.database properties:newProperties];
             finishedBlock(document);
         }
     }
     errorBlock:^(NSError* error) {
         if (errorBlock) {
             errorBlock(error);
         }
     }];
}

-(void)putAttachmentNamed:(NSString*)name mimetype:(NSString*)mimetype data:(NSData*)data progressBlock:(PutAttachmentProgressBlock)progressBlock finishedBlock:(PutAttachmentFinishedBlock)finishedBlock errorBlock:(PutAttachmentErrorBlock)errorBlock {
    MKNetworkOperation* operation = [self.database operationWithPath:[NSString stringWithFormat:@"%@/%@?rev=%@",self.identifier,name,self.revision] params:nil httpMethod:@"PUT"];
    
    NSInputStream* input = [[NSInputStream alloc] initWithData:data];
    [operation setUploadStream:input];
    
    [operation addHeaders:@{@"Content-Type":mimetype,@"Content-Length":[NSString stringWithFormat:@"%i",data.length]}];
    
    [operation addCompletionHandler:^(MKNetworkOperation* completedOperation) {
        if (finishedBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.database loadDocumentWithIdentifier:self.identifier finishedBlock:^(Document* document) {
                    finishedBlock(document);
                } errorBlock:^(NSError* error) {
                    if (errorBlock) {
                        errorBlock(error);
                    }
                }];
            });
        }
    } errorHandler:^(MKNetworkOperation* completedOperation, NSError* error) {
        if (errorBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                errorBlock(error);
            });
        }
    }];
    
    if (progressBlock) {
        [operation onUploadProgressChanged:^(double progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                progressBlock(progress);
            });
        }];
    }
    
    [self.database.engine enqueueOperation:operation];
}

@end
