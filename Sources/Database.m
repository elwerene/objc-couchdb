//
//  Database.m
//  objc-couchdb
//
//  Created by René Rössler on 08.04.13.
//  Copyright (c) 2013 FreshX GbR. All rights reserved.
//

#import "ObjC-CouchDB.h"
#import <PathHelper/PathHelper.h>
#import <CocoaLumberjack/DDLog.h>
extern int ddLogLevel;

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
        
        _globalErrorBlock = nil;
        _engine = [[MKNetworkEngine alloc] initWithHostName:hostName];
        _engine.portNumber = (port != nil)?[port intValue]:0;
        _engine.apiPath = name;
    }
    return self;
}

-(void)setGlobalErrorBlock:(DatabaseErrorBlock)globalErrorBlock {
    _globalErrorBlock = globalErrorBlock;
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

-(MKNetworkOperation*) operationWithPath:(NSString*)path
                                  params:(NSDictionary*)_params
                              httpMethod:(NSString*)method
                              jsonParams:(BOOL)jsonParams {
    
    NSDictionary* params = _params;
    if (jsonParams && ([method isEqualToString:@"GET"] || [method isEqualToString:@"DELETE"])) {
        NSMutableDictionary* fixedParams = [NSMutableDictionary dictionaryWithCapacity:params.count];
        for (id key in params.allKeys) {
            id obj = [params objectForKey:key];
            if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]) {
                [fixedParams setObject:obj forKey:key];
            } else {
                NSString* jsonObj = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:obj options:0 error:nil] encoding:NSUTF8StringEncoding];
                if (jsonObj) {
                    [fixedParams setObject:jsonObj forKey:key];
                }
            }
        }
        params = fixedParams;
    }
    
    MKNetworkOperation* operation = [self.engine operationWithPath:path params:params httpMethod:method ssl:self.useSSL];
    
    if (self.username != nil && self.password != nil) {
        [operation setUsername:self.username password:self.password basicAuth:YES];
    }
    
    return operation;
}

-(void)getPath:(NSString*)path params:(NSDictionary*)params progressBlock:(OperationProgressBlock)progressBlock finishedBlock:(OperationFinishedBlock)finishedBlock errorBlock:(OperationErrorBlock)errorBlock jsonParams:(BOOL)jsonParams {
    MKNetworkOperation* operation = [self operationWithPath:path params:params httpMethod:@"GET" jsonParams:jsonParams];
    
    [operation addCompletionHandler:^(MKNetworkOperation* completedOperation) {
        if (finishedBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                finishedBlock(completedOperation);
                [self.engine emptyCache];
            });
        }
    } errorHandler:^(MKNetworkOperation* completedOperation, NSError* error) {
        if (errorBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                errorBlock(error);
            });
        }
        if (self.globalErrorBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.globalErrorBlock(error);
            });
        }
    }];
    if (progressBlock != nil) {
        [operation onDownloadProgressChanged:^(double progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                progressBlock(progress);
            });
        }];
    }
    
    [self.engine enqueueOperation:operation forceReload:YES];
}

-(void)putPath:(NSString*)path params:(NSDictionary*)params progressBlock:(OperationProgressBlock)progressBlock finishedBlock:(OperationFinishedBlock)finishedBlock errorBlock:(OperationErrorBlock)errorBlock jsonParams:(BOOL)jsonParams {
    MKNetworkOperation* operation = [self operationWithPath:path params:params httpMethod:@"PUT" jsonParams:jsonParams];
    if (jsonParams) {
        operation.postDataEncoding = MKNKPostDataEncodingTypeJSON;
    }
    
    [operation addCompletionHandler:^(MKNetworkOperation* completedOperation) {
        if (finishedBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                finishedBlock(completedOperation);
                [self.engine emptyCache];
            });
        }
    } errorHandler:^(MKNetworkOperation* completedOperation, NSError* error) {
        if (errorBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                errorBlock(error);
            });
        }
        if (self.globalErrorBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.globalErrorBlock(error);
            });
        }
    }];
    if (progressBlock != nil) {
        [operation onUploadProgressChanged:^(double progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                progressBlock(progress);
            });
        }];
    }
    
    [self.engine enqueueOperation:operation forceReload:YES];
}

-(void)deletePath:(NSString*)path params:(NSDictionary*)params finishedBlock:(OperationFinishedBlock)finishedBlock errorBlock:(OperationErrorBlock)errorBlock jsonParams:(BOOL)jsonParams {
    MKNetworkOperation* operation = [self operationWithPath:path params:params httpMethod:@"DELETE" jsonParams:jsonParams];
    
    [operation addCompletionHandler:^(MKNetworkOperation* completedOperation) {
        if (finishedBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                finishedBlock(completedOperation);
                [self.engine emptyCache];
            });
        }
    } errorHandler:^(MKNetworkOperation* completedOperation, NSError* error) {
        if (errorBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                errorBlock(error);
            });
        }
        if (self.globalErrorBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.globalErrorBlock(error);
            });
        }
    }];
    
    [self.engine enqueueOperation:operation forceReload:YES];
}

#pragma mark - operations

-(void)loadDocumentWithIdentifier:(NSString*)identifier finishedBlock:(DocumentDownloadFinishedBlock)finishedBlock errorBlock:(DocumentDownloadErrorBlock)errorBlock {
    DDLogVerbose(@"[Database] Loading document with identifier:%@", identifier);
    
    [self
     getPath:identifier
     params:nil
     progressBlock:nil
     finishedBlock:^(MKNetworkOperation* completedOperation) {
             DDLogVerbose(@"[Database] Done loading document with identifier:%@", identifier);
         if (finishedBlock) {
             NSDictionary* properties = completedOperation.responseJSON;
             Document* document = [[Document alloc] initWithDatabase:self properties:properties];
             finishedBlock(document);
         }
     }
     errorBlock:^(NSError* error) {
         DDLogError(@"[Database] Error:%@ loading document with identifier:%@", error.localizedDescription, identifier);

         if (errorBlock) {
             errorBlock(error);
         }
         if (self.globalErrorBlock) {
             self.globalErrorBlock(error);
         }
     }
     jsonParams:NO];
}

-(void)loadDesignDocumentWithIdentifier:(NSString*)identifier finishedBlock:(DesignDownloadFinishedBlock)finishedBlock errorBlock:(DesignDownloadErrorBlock)errorBlock {
    DDLogVerbose(@"[Database] Loading design document with identifier:%@", identifier);
    
    [self
     getPath:[NSString stringWithFormat:@"_design/%@",identifier]
     params:nil
     progressBlock:nil
     finishedBlock:^(MKNetworkOperation* completedOperation) {
         DDLogVerbose(@"[Database] Done loading design document with identifier:%@", identifier);

         if (finishedBlock) {
             NSDictionary* properties = completedOperation.responseJSON;
             Design* design = [[Design alloc] initWithDatabase:self properties:properties];
             finishedBlock(design);
         }
     }
     errorBlock:^(NSError* error) {
         DDLogError(@"[Database] Error:%@ loading document with identifier:%@", error.localizedDescription, identifier);

         if (errorBlock) {
             errorBlock(error);
         }
         if (self.globalErrorBlock) {
             self.globalErrorBlock(error);
         }
     }
     jsonParams:NO];
}

-(void)newDocumentWithIdentifier:(NSString*)identifier properties:(NSDictionary*)properties finishedBlock:(CreateDocumentFinishedBlock)finishedBlock errorBlock:(CreateDocumentErrorBlock)errorBlock {
    DDLogVerbose(@"[Database] Creating new document with identifier:%@, properties:%@", identifier, properties);
    
    [self
     putPath:identifier
     params:properties
     progressBlock:nil
     finishedBlock:^(MKNetworkOperation* completedOperation) {
         DDLogVerbose(@"[Database] Done creating new document with identifier:%@, properties:%@", identifier, properties);
         
         if (finishedBlock) {
             NSMutableDictionary* properties = [completedOperation.responseJSON mutableCopy];
             [properties addEntriesFromDictionary:@{@"_id":[properties getStringWithPath:@"id"],@"_rev":[properties getStringWithPath:@"rev"]}];
             
             Document* document = [[Document alloc] initWithDatabase:self properties:properties];
             finishedBlock(document);
         }
     }
     errorBlock:^(NSError* error) {
         DDLogError(@"[Database] Error:%@ creating new document with identifier:%@, properties:%@", error.localizedDescription, identifier, properties);
         
         if (errorBlock) {
             errorBlock(error);
         }
         if (self.globalErrorBlock) {
             self.globalErrorBlock(error);
         }
     }
     jsonParams:YES];
}

-(void)newDocumentWithProperties:(NSDictionary *)properties finishedBlock:(CreateDocumentFinishedBlock)finishedBlock errorBlock:(CreateDocumentErrorBlock)errorBlock {
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString* identifier = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    
    DDLogVerbose(@"[Database] Creating new document with uuid identifier:%@ properties:%@", identifier, properties);
    [self newDocumentWithIdentifier:identifier properties:properties finishedBlock:finishedBlock errorBlock:errorBlock];
}

@end
