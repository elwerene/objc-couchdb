//
//  Document.h
//  objc-couchdb
//
//  Created by René Rössler on 08.04.13.
//  Copyright (c) 2013 FreshX GbR. All rights reserved.
//

#import "ObjC-CouchDB.h"

@class Database;

typedef void (^DeleteDocumentFinishedBlock)();
typedef void (^DeleteDocumentErrorBlock)(NSError* error);

typedef void (^PutPropertiesFinishedBlock)(Document* document);
typedef void (^PutPropertiesErrorBlock)(NSError* error);

typedef void (^PutAttachmentProgressBlock)(double progress);
typedef void (^PutAttachmentFinishedBlock)(Document* document);
typedef void (^PutAttachmentErrorBlock)(NSError* error);

@interface Document : NSObject {
    @private
    Database* _database;
    NSDictionary* _properties;
    
    NSString* _identifier;
    NSString* _revision;
    BOOL _deleted;
    NSDictionary* _attachments;
}

@property (nonatomic, readonly) Database* database;
@property (nonatomic, readonly) NSDictionary* properties;
@property (nonatomic, readonly) NSString* identifier;
@property (nonatomic, readonly) NSString* revision;
@property (nonatomic, readonly) BOOL deleted;
@property (nonatomic, readonly) NSDictionary* attachments;

-(id)initWithDatabase:(Database*)database properties:(NSDictionary*)properties;
-(void)deleteWithFinishedBlock:(DeleteDocumentFinishedBlock)finishedBlock errorBlock:(DeleteDocumentErrorBlock)errorBlock;
-(void)putProperties:(NSDictionary*)properties finishedBlock:(PutPropertiesFinishedBlock)finishedBlock errorBlock:(PutPropertiesErrorBlock)errorBlock;
-(void)putAttachmentNamed:(NSString*)name mimetype:(NSString*)mimetype data:(NSData*)data progressBlock:(PutAttachmentProgressBlock)progressBlock finishedBlock:(PutAttachmentFinishedBlock)finishedBlock errorBlock:(PutAttachmentErrorBlock)errorBlock;

@end
