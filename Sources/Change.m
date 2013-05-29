//
//  Change.m
//  objc-couchdb
//
//  Created by René Rössler on 08.04.13.
//  Copyright (c) 2013 FreshX GbR. All rights reserved.
//

#import "ObjC-CouchDB.h"
#import <PathHelper/PathHelper.h>
#import <CocoaLumberjack/DDLog.h>
extern int ddLogLevel;

@implementation Change

-(id)initWithData:(NSDictionary*)data {
    self = [super init];
    if (self) {
        _seq = [data getNumberWithPath:@"seq"];
        _identifier = [data getStringWithPath:@"id"];
        _changes = [data getArrayWithPath:@"changes"];
        _deleted = [[data getNumberWithPath:@"deleted"] isEqualToNumber:@YES];
    }
    return self;
}

-(NSString*)description {
    return [NSString stringWithFormat:@"<Change: seq=%@ identifier=%@%@>",self.seq,self.identifier,self.deleted?@" deleted":@""];
}

@end
