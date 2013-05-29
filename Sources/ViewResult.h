//
//  ViewResult.h
//  objc-couchdb
//
//  Created by René Rössler on 08.04.13.
//  Copyright (c) 2013 FreshX GbR. All rights reserved.
//

#import "ObjC-CouchDB.h"

@interface ViewResult : NSObject {
    @private
    View* _view;
    NSNumber* _totalRows;
    NSNumber* _offset;
    NSArray* _rows;
}

@property (nonatomic, readonly) View* view;
@property (nonatomic, readonly) NSNumber* totalRows;
@property (nonatomic, readonly) NSNumber* offset;
@property (nonatomic, readonly) NSArray* rows;

-(id)initWithView:(View*)view properties:(NSDictionary*)properties;

@end
