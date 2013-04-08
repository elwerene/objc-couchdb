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

-(MKNetworkOperation*) operationWithPath:(NSString*) path
                                  params:(NSDictionary*) body
                              httpMethod:(NSString*)method {
    MKNetworkOperation* operation = [self.engine operationWithPath:path params:body httpMethod:method ssl:self.useSSL];
    
    if (self.username != nil && self.password != nil) {
        [operation setUsername:self.username password:self.password];
    }
    
    return operation;
}

#pragma mark - convenience functions
-(ChangesListener*)changesListenerWithFilter:(Filter*)filter {
    return [[ChangesListener alloc] initWithDatabase:self filter:filter];
}
-(ChangesListener*)changesListener {
    return [self changesListenerWithFilter:nil];
}

-(void)loadDocumentWithIdentifier:(NSString*)identifier finishedBlock:(DocumentDownloadFinishedBlock)finishedBlock errorBlock:(DocumentDownloadErrorBlock)errorBlock {
    MKNetworkOperation* operation = [self operationWithPath:identifier params:nil httpMethod:@"GET"];
    
    [operation addCompletionHandler:^(MKNetworkOperation* completedOperation) {        
        NSDictionary* properties = completedOperation.responseJSON;
        Document* document = [[Document alloc] initWithDatabase:self properties:properties];
        dispatch_async(dispatch_get_main_queue(), ^{
            finishedBlock(document);
        });
    } errorHandler:^(MKNetworkOperation* completedOperation, NSError* error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            errorBlock(error);
        });
    }];
    
    
    [self.engine enqueueOperation:operation];
}

@end
