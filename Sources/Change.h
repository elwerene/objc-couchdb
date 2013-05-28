//
//  Change.h
//  objc-couchdb
//
//  Created by René Rössler on 08.04.13.
//  Copyright (c) 2013 FreshX GbR. All rights reserved.
//

#import "ObjC_CouchDB.h"

@interface Change : NSObject {
@private
    NSNumber* _seq;
    NSString* _identifier;
    NSArray* _changes;
    BOOL _deleted;
}

@property (nonatomic, readonly) NSNumber* seq;
@property (nonatomic, readonly) NSString* identifier;
@property (nonatomic, readonly) NSArray* changes;
@property (nonatomic, readonly) BOOL deleted;

-(id)initWithData:(NSDictionary*)data;

@end
