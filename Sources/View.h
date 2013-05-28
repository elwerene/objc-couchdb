//
//  View.h
//  objc-couchdb
//
//  Created by René Rössler on 08.04.13.
//  Copyright (c) 2013 FreshX GbR. All rights reserved.
//

#import "ObjC_CouchDB.h"

@class ViewResult;

typedef void (^ViewQueryFinishedBlock)(ViewResult* result);
typedef void (^ViewQueryErrorBlock)(NSError* error);

@interface View : NSObject {
@private
    Design* _design;
    NSString* _name;
}

@property (nonatomic, readonly) Design* design;
@property (nonatomic, readonly) NSString* name;
@property (nonatomic, retain) NSDictionary* options;

-(id)initWithDesign:(Design*)design name:(NSString*)name;
-(void)queryWithFinishedBlock:(ViewQueryFinishedBlock)finishedBlock errorBlock:(ViewQueryErrorBlock)errorBlock;

@end
