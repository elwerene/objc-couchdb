//
//  Update.h
//  objc-couchdb
//
//  Created by René Rössler on 09.04.13.
//  Copyright (c) 2013 FreshX GbR. All rights reserved.
//

#import "objc_couchdb.h"

typedef void (^UpdateDocumentFinishedBlock)(Document* document);
typedef void (^UpdateDocumentErrorBlock)(NSError* error);

@interface Update : NSObject {
@private
    Design* _design;
    NSString* _name;
}

@property (nonatomic, readonly) Design* design;
@property (nonatomic, readonly) NSString* name;

-(id)initWithDesign:(Design*)design name:(NSString*)name;
-(void)updateDocument:(Document*)document withProperties:(NSDictionary*)properties finishedBlock:(DeleteDocumentFinishedBlock)finishedBlock errorBlock:(DeleteDocumentErrorBlock)errorBlock;

@end
