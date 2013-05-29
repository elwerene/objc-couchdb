//
//  ViewResultRow.m
//  objc-couchdb
//
//  Created by René Rössler on 08.04.13.
//  Copyright (c) 2013 FreshX GbR. All rights reserved.
//

#import "ObjC-CouchDB.h"
#import <CocoaLumberjack/DDLog.h>
extern int ddLogLevel;

@implementation ViewResultRow

-(id)initWithProperties:(NSDictionary*)properties {
    self = [super init];
    if (self) {
        _identifier = [properties objectForKey:@"id"];
        _key = [properties objectForKey:@"key"];
        _value = [properties objectForKey:@"value"];
    }
    return self;
}

-(NSString*)description {
    return [NSString stringWithFormat:@"<ViewResultRow: identifier=%@ key=%@ value=%@>",self.identifier,self.key,self.value];
}

@end
