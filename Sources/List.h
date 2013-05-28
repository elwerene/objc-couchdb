//
//  List.h
//  objc-couchdb
//
//  Created by René Rössler on 09.04.13.
//  Copyright (c) 2013 FreshX GbR. All rights reserved.
//

#import "ObjC_CouchDB.h"

@class View;

typedef void (^ListQueryFinishedBlock)(MKNetworkOperation* completedOperation);
typedef void (^ListQueryErrorBlock)(NSError* error);

@interface List : NSObject {
@private
    Design* _design;
    NSString* _name;
}

@property (nonatomic, readonly) Design* design;
@property (nonatomic, readonly) NSString* name;
@property (nonatomic, retain) View* view;

-(id)initWithDesign:(Design*)design name:(NSString*)name;
-(void)queryWithFinishedBlock:(ListQueryFinishedBlock)finishedBlock errorBlock:(ListQueryErrorBlock)errorBlock;

@end
