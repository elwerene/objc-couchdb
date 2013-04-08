//
//  Database.h
//  objc-couchdb
//
//  Created by René Rössler on 08.04.13.
//  Copyright (c) 2013 FreshX GbR. All rights reserved.
//

#import "objc_couchdb.h"

@class CouchDB, MKNetworkEngine, MKNetworkOperation, ChangesListener, Filter;

typedef void (^DocumentDownloadFinishedBlock)(Document* document);
typedef void (^DocumentDownloadErrorBlock)(NSError* error);

@interface Database : NSObject {
    @private
    NSString* _hostName;
    NSNumber* _port;
    BOOL _useSSL;
    NSString* _username;
    NSString* _password;
    NSString* _name;
    MKNetworkEngine* _engine;
}

@property (nonatomic, readonly) NSString* hostName;
@property (nonatomic, readonly) NSNumber* port;
@property (nonatomic, readonly) BOOL useSSL;
@property (nonatomic, readonly) NSString* username;
@property (nonatomic, readonly) NSString* password;
@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) MKNetworkEngine* engine;

-(id)initWithHostName:(NSString*)hostName port:(NSNumber*)port useSSL:(BOOL)useSSL username:(NSString*)username password:(NSString*)password name:(NSString*)name;
-(MKNetworkOperation*)operationWithPath:(NSString*) path params:(NSDictionary*) body httpMethod:(NSString*)method;

-(ChangesListener*)changesListenerWithFilter:(Filter*)filter;
-(ChangesListener*)changesListener;

-(void)loadDocumentWithIdentifier:(NSString*)identifier finishedBlock:(DocumentDownloadFinishedBlock)finishedBlock errorBlock:(DocumentDownloadErrorBlock)errorBlock;

/* TODO:
 * 
 * newDoc (uuid)
 * getDoc
 * getDocs
 * getDesignDoc
 */

@end
