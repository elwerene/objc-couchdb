//
//  Database.h
//  objc-couchdb
//
//  Created by René Rössler on 08.04.13.
//  Copyright (c) 2013 FreshX GbR. All rights reserved.
//

#import "objc_couchdb.h"

@class CouchDB, Design, MKNetworkEngine, MKNetworkOperation, ChangesListener, Filter;

typedef void (^OperationProgressBlock)(double progress);
typedef void (^OperationFinishedBlock)(MKNetworkOperation* completedOperation);
typedef void (^OperationErrorBlock)(NSError* error);

typedef void (^DocumentDownloadFinishedBlock)(Document* document);
typedef void (^DocumentDownloadErrorBlock)(NSError* error);

typedef void (^DesignDownloadFinishedBlock)(Design* design);
typedef void (^DesignDownloadErrorBlock)(NSError* error);

typedef void (^CreateDocumentFinishedBlock)(Document* document);
typedef void (^CreateDocumentErrorBlock)(NSError* error);

typedef void (^DatabaseErrorBlock)(NSError* error);

@interface Database : NSObject {
    @private
    NSString* _hostName;
    NSNumber* _port;
    BOOL _useSSL;
    NSString* _username;
    NSString* _password;
    NSString* _name;
    MKNetworkEngine* _engine;
    DatabaseErrorBlock _globalErrorBlock;
}

@property (nonatomic, readonly) NSString* hostName;
@property (nonatomic, readonly) NSNumber* port;
@property (nonatomic, readonly) BOOL useSSL;
@property (nonatomic, readonly) NSString* username;
@property (nonatomic, readonly) NSString* password;
@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) MKNetworkEngine* engine;
@property (nonatomic, readonly) DatabaseErrorBlock globalErrorBlock;

-(id)initWithHostName:(NSString*)hostName port:(NSNumber*)port useSSL:(BOOL)useSSL username:(NSString*)username password:(NSString*)password name:(NSString*)name;
-(void)setGlobalErrorBlock:(DatabaseErrorBlock)globalErrorBlock;

-(ChangesListener*)changesListenerWithFilter:(Filter*)filter;
-(ChangesListener*)changesListener;

-(MKNetworkOperation*)operationWithPath:(NSString*) path params:(NSDictionary*) body httpMethod:(NSString*)method jsonParams:(BOOL)jsonParams;
-(void)getPath:(NSString*)path params:(NSDictionary*)params progressBlock:(OperationProgressBlock)progressBlock finishedBlock:(OperationFinishedBlock)finishedBlock errorBlock:(OperationErrorBlock)errorBlock jsonParams:(BOOL)jsonParams;
-(void)putPath:(NSString*)path params:(NSDictionary*)params progressBlock:(OperationProgressBlock)progressBlock finishedBlock:(OperationFinishedBlock)finishedBlock errorBlock:(OperationErrorBlock)errorBlock jsonParams:(BOOL)jsonParams;
-(void)deletePath:(NSString*)path params:(NSDictionary*)params finishedBlock:(OperationFinishedBlock)finishedBlock errorBlock:(OperationErrorBlock)errorBlock jsonParams:(BOOL)jsonParams;

-(void)loadDocumentWithIdentifier:(NSString*)identifier finishedBlock:(DocumentDownloadFinishedBlock)finishedBlock errorBlock:(DocumentDownloadErrorBlock)errorBlock;
-(void)loadDesignDocumentWithIdentifier:(NSString*)identifier finishedBlock:(DesignDownloadFinishedBlock)finishedBlock errorBlock:(DesignDownloadErrorBlock)errorBlock;
-(void)newDocumentWithIdentifier:(NSString*)identifier properties:(NSDictionary*)properties finishedBlock:(CreateDocumentFinishedBlock)finishedBlock errorBlock:(CreateDocumentErrorBlock)errorBlock;
-(void)newDocumentWithProperties:(NSDictionary*)properties finishedBlock:(CreateDocumentFinishedBlock)finishedBlock errorBlock:(CreateDocumentErrorBlock)errorBlock;

@end
