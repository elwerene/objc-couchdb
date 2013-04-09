//
//  Database.m
//  objc-couchdb
//
//  Created by René Rössler on 08.04.13.
//  Copyright (c) 2013 FreshX GbR. All rights reserved.
//

#import "objc_couchdb.h"

@implementation Database

-(id)initWithHostName:(NSString*)hostName port:(NSNumber*)port useSSL:(BOOL)useSSL username:(NSString*)username password:(NSString*)password name:(NSString*)name {
    self = [super init];
    if (self) {
        _hostName = hostName;
        _port = port;
        _useSSL = useSSL;
        _username = username;
        _password = password;
        _name = name;
        
        _engine = [[MKNetworkEngine alloc] initWithHostName:hostName];
        _engine.portNumber = (port != nil)?[port intValue]:0;
        _engine.apiPath = name;
    }
    return self;
}

-(NSString*)description {
    return [NSString stringWithFormat:@"<Database: hostName=%@ name=%@>",self.hostName,self.name];
}

#pragma mark - convenience functions
-(ChangesListener*)changesListenerWithFilter:(Filter*)filter {
    return [[ChangesListener alloc] initWithDatabase:self filter:filter];
}
-(ChangesListener*)changesListener {
    return [self changesListenerWithFilter:nil];
}

#pragma mark - general operations

-(MKNetworkOperation*) operationWithPath:(NSString*) path
                                  params:(NSDictionary*) body
                              httpMethod:(NSString*)method {
    MKNetworkOperation* operation = [self.engine operationWithPath:path params:body httpMethod:method ssl:self.useSSL];
    
    if (self.username != nil && self.password != nil) {
        [operation setUsername:self.username password:self.password];
    }
    
    return operation;
}

-(void)getPath:(NSString*)path params:(NSDictionary*)params progressBlock:(OperationProgressBlock)progressBlock finishedBlock:(OperationFinishedBlock)finishedBlock errorBlock:(OperationErrorBlock)errorBlock {
    MKNetworkOperation* operation = [self operationWithPath:path params:params httpMethod:@"GET"];
    
    [operation addCompletionHandler:^(MKNetworkOperation* completedOperation) {
        if (finishedBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                finishedBlock(completedOperation);
            });
        }
    } errorHandler:^(MKNetworkOperation* completedOperation, NSError* error) {
        if (errorBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                errorBlock(error);
            });
        } //TODO: main error block
    }];
    if (progressBlock != nil) {
        [operation onDownloadProgressChanged:^(double progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                progressBlock(progress);
            });
        }];
    }
    
    [self.engine enqueueOperation:operation];
}

-(void)putPath:(NSString*)path params:(NSDictionary*)params finishedBlock:(OperationFinishedBlock)finishedBlock errorBlock:(OperationErrorBlock)errorBlock {
    MKNetworkOperation* operation = [self operationWithPath:path params:params httpMethod:@"PUT"];
    operation.postDataEncoding = MKNKPostDataEncodingTypeJSON;
    
    [operation addCompletionHandler:^(MKNetworkOperation* completedOperation) {
        if (finishedBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                finishedBlock(completedOperation);
            });
        }
    } errorHandler:^(MKNetworkOperation* completedOperation, NSError* error) {
        if (errorBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                errorBlock(error);
            });
        } //TODO: main error block
    }];
    
    [self.engine enqueueOperation:operation];
}

-(void)deletePath:(NSString*)path params:(NSDictionary*)params finishedBlock:(OperationFinishedBlock)finishedBlock errorBlock:(OperationErrorBlock)errorBlock {
    MKNetworkOperation* operation = [self operationWithPath:path params:params httpMethod:@"DELETE"];
    
    [operation addCompletionHandler:^(MKNetworkOperation* completedOperation) {
        if (finishedBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                finishedBlock(completedOperation);
            });
        }
    } errorHandler:^(MKNetworkOperation* completedOperation, NSError* error) {
        if (errorBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                errorBlock(error);
            });
        } //TODO: main error block
    }];
    
    [self.engine enqueueOperation:operation];
}

#pragma mark - operations

-(void)loadDocumentWithIdentifier:(NSString*)identifier finishedBlock:(DocumentDownloadFinishedBlock)finishedBlock errorBlock:(DocumentDownloadErrorBlock)errorBlock {
    [self
     getPath:identifier
     params:nil
     progressBlock:nil
     finishedBlock:^(MKNetworkOperation* completedOperation) {
         if (finishedBlock) {
             NSDictionary* properties = completedOperation.responseJSON;
             Document* document = [[Document alloc] initWithDatabase:self properties:properties];
             finishedBlock(document);
         }
     }
     errorBlock:^(NSError* error) {
         if (errorBlock) {
             errorBlock(error);
         }
     }];
}

-(void)loadDesignDocumentWithIdentifier:(NSString*)identifier finishedBlock:(DesignDownloadFinishedBlock)finishedBlock errorBlock:(DesignDownloadErrorBlock)errorBlock {
    [self
     getPath:[NSString stringWithFormat:@"_design/%@",identifier]
     params:nil
     progressBlock:nil
     finishedBlock:^(MKNetworkOperation* completedOperation) {
         if (finishedBlock) {
             NSDictionary* properties = completedOperation.responseJSON;
             Design* design = [[Design alloc] initWithDatabase:self properties:properties];
             finishedBlock(design);
         }
     }
     errorBlock:^(NSError* error) {
         if (errorBlock) {
             errorBlock(error);
         }
     }];
}

-(void)newDocumentWithIdentifier:(NSString*)identifier finishedBlock:(CreateDocumentFinishedBlock)finishedBlock errorBlock:(CreateDocumentErrorBlock)errorBlock {
    [self
     putPath:identifier
     params:nil
     finishedBlock:^(MKNetworkOperation* completedOperation) {
         if (finishedBlock) {
             NSDictionary* properties = completedOperation.responseJSON;
             if ([[properties objectForKey:@"ok"] isEqualToNumber:@YES]) {
                 Document* document = [[Document alloc] initWithDatabase:self properties:@{@"_id":[properties objectForKey:@"id"],@"_rev":[properties objectForKey:@"rev"]}];
                 finishedBlock(document);
             } else {
                 errorBlock([NSError errorWithDomain:@"ServerError" code:0 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Can't create new document \"%@\"",identifier]}]);

             }
         }
     }
     errorBlock:^(NSError* error) {
         if (errorBlock) {
             errorBlock(error);
         }
     }];
}

-(void)newDocumentWithFinishedBlock:(CreateDocumentFinishedBlock)finishedBlock errorBlock:(CreateDocumentErrorBlock)errorBlock {
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString* identifier = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    
    [self newDocumentWithIdentifier:identifier finishedBlock:finishedBlock errorBlock:errorBlock];
}

@end
