//
//  Change.m
//  objc-couchdb
//
//  Created by René Rössler on 08.04.13.
//  Copyright (c) 2013 FreshX GbR. All rights reserved.
//

#import "objc_couchdb.h"

@implementation Change

-(id)initWithData:(NSDictionary*)data {
    self = [super init];
    if (self) {
        _seq = [data objectForKey:@"seq"];
        _identifier = [data objectForKey:@"id"];
        _changes = [data objectForKey:@"changes"];
        _deleted = [[data objectForKey:@"deleted"] isEqualToNumber:@YES];
    }
    return self;
}

-(NSString*)description {
    return [NSString stringWithFormat:@"<Change: seq=%@ identifier=%@%@>",self.seq,self.identifier,self.deleted?@" deleted":@""];
}

@end
