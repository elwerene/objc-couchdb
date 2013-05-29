//
//  ViewResultRow.h
//  objc-couchdb
//
//  Created by René Rössler on 08.04.13.
//  Copyright (c) 2013 FreshX GbR. All rights reserved.
//

#import "ObjC-CouchDB.h"

@interface ViewResultRow : NSObject {
    @private
    NSString* _identifier;
    id _key;
    id _value;
}

@property (nonatomic, readonly) NSString* identifier;
@property (nonatomic, readonly) id key;
@property (nonatomic, readonly) id value;

-(id)initWithProperties:(NSDictionary*)properties;

@end
