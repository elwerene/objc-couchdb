//
//  Design.h
//  objc-couchdb
//
//  Created by René Rössler on 08.04.13.
//  Copyright (c) 2013 FreshX GbR. All rights reserved.
//

#import "Document.h"

@interface Design : Document {
@private
    NSDictionary* _views;
    NSDictionary* _filters;
    NSDictionary* _lists;
    NSDictionary* _updates;
}

@property (nonatomic, readonly) NSDictionary* views;
@property (nonatomic, readonly) NSDictionary* filters;
@property (nonatomic, readonly) NSDictionary* lists;
@property (nonatomic, readonly) NSDictionary* updates;

@end
