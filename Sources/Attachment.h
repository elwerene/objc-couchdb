//
//  Attachment.h
//  objc-couchdb
//
//  Created by René Rössler on 08.04.13.
//  Copyright (c) 2013 FreshX GbR. All rights reserved.
//

#import "ObjC_CouchDB.h"

@class Attachment, Document;

typedef void (^AttachmentDownloadProgressBlock)(double progress);
typedef void (^AttachmentDownloadFinishedBlock)(Attachment* attachment);
typedef void (^AttachmentDownloadErrorBlock)(NSError* error);

typedef void (^DeleteAttachmentFinishedBlock)();
typedef void (^DeleteAttachmentErrorBlock)(NSError* error);

@interface Attachment : NSObject {
@private
    Document* _document;
    NSString* _name;
    NSString* _contentType;
    NSNumber* _revision;
    NSString* _digest;
    NSNumber* _length;
    BOOL _stub;
    NSData* _data;
}

@property (nonatomic, readonly) Document* document;
@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) NSString* contentType;
@property (nonatomic, readonly) NSNumber* revision;
@property (nonatomic, readonly) NSString* digest;
@property (nonatomic, readonly) NSNumber* length;
@property (nonatomic, readonly) BOOL stub;
@property (nonatomic, readonly) NSData* data;

-(id)initWithDocument:(Document*)document name:(NSString*)name properties:(NSDictionary*)properties;
-(void)loadWithProgressBlock:(AttachmentDownloadProgressBlock)progressBlock finishedBlock:(AttachmentDownloadFinishedBlock)finishedBlock errorBlock:(AttachmentDownloadErrorBlock)errorBlock;
-(void)loadWithFinishedBlock:(AttachmentDownloadFinishedBlock)finishedBlock errorBlock:(AttachmentDownloadErrorBlock)errorBlock;
-(void)deleteWithFinishedBlock:(DeleteAttachmentFinishedBlock)finishedBlock errorBlock:(DeleteAttachmentErrorBlock)errorBlock;

@end
