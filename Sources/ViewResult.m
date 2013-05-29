//
//  ViewResult.m
//  objc-couchdb
//
//  Created by René Rössler on 08.04.13.
//  Copyright (c) 2013 FreshX GbR. All rights reserved.
//

#import "ObjC-CouchDB.h"
#import <PathHelper/PathHelper.h>
#import <CocoaLumberjack/DDLog.h>
extern int ddLogLevel;

@implementation ViewResult

-(id)initWithView:(View*)view properties:(NSDictionary*)properties {
    self = [super init];
    if (self) {
        _view = view;
        _totalRows = [properties getNonEmptyNumberWithPath:@"total_rows"];
        _offset = [properties getNonEmptyNumberWithPath:@"offset"];
        
        NSArray* resultRows = [properties getNonEmptyArrayWithPath:@"rows"];
        NSMutableArray* rows = [NSMutableArray array];
        for (NSDictionary* resultRow in resultRows) {
            ViewResultRow* row = [[ViewResultRow alloc] initWithProperties:resultRow];
            [rows addObject:row];
        }
        _rows = rows;
    }
    return self;
}

-(NSString*)description {
    return [NSString stringWithFormat:@"<ViewResult: view=%@ totalRows=%@ revision=%@>",self.view,self.totalRows,self.offset];
}

@end
