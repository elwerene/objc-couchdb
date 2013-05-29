//
//  Update.h
//  objc-couchdb
//
//  Created by René Rössler on 09.04.13.
//  Copyright (c) 2013 FreshX GbR. All rights reserved.
//

#import "ObjC-CouchDB.h"

typedef void (^UpdateDocumentFinishedBlock)(MKNetworkOperation* completedOperation);
typedef void (^UpdateDocumentErrorBlock)(NSError* error);
typedef void (^UpdateDocumentProgressBlock)(double progress);

@interface Update : NSObject {
@private
    Design* _design;
    NSString* _name;
}

@property (nonatomic, readonly) Design* design;
@property (nonatomic, readonly) NSString* name;

-(id)initWithDesign:(Design*)design name:(NSString*)name;
-(void)updateDocument:(Document*)document withProperties:(NSDictionary*)properties finishedBlock:(UpdateDocumentFinishedBlock)finishedBlock errorBlock:(UpdateDocumentErrorBlock)errorBlock progressBlock:(UpdateDocumentProgressBlock)progressBlock;
-(void)updateDocumentWithIdentifier:(NSString*)identifier withProperties:(NSDictionary*)properties finishedBlock:(UpdateDocumentFinishedBlock)finishedBlock errorBlock:(UpdateDocumentErrorBlock)errorBlock progressBlock:(UpdateDocumentProgressBlock)progressBlock;

@end
