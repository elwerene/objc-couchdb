//
//  Design.m
//  objc-couchdb
//
//  Created by René Rössler on 08.04.13.
//  Copyright (c) 2013 FreshX GbR. All rights reserved.
//

#import "ObjC-CouchDB.h"
#import <PathHelper/PathHelper.h>
#import <CocoaLumberjack/DDLog.h>
extern int ddLogLevel;

@implementation Design

-(id)initWithDatabase:(Database*)database properties:(NSDictionary*)properties {
    self = [super initWithDatabase:database properties:properties];
    if (self) {
        NSDictionary* rawViews = [properties getNonEmptyDictionaryWithPath:@"views"];
        NSMutableDictionary* views = [NSMutableDictionary dictionary];
        for (NSString* name in rawViews.allKeys) {
            View* view = [[View alloc] initWithDesign:self name:name];
            [views setObject:view forKey:name];
        }
        _views = views;
        
        NSDictionary* rawFilters = [properties getNonEmptyDictionaryWithPath:@"filters"];
        NSMutableDictionary* filters = [NSMutableDictionary dictionary];
        for (NSString* name in rawFilters.allKeys) {
            Filter* filter = [[Filter alloc] initWithDesign:self name:name];
            [filters setObject:filter forKey:name];
        }
        _filters = filters;
        
        NSDictionary* rawLists = [properties getNonEmptyDictionaryWithPath:@"lists"];
        NSMutableDictionary* lists = [NSMutableDictionary dictionary];
        for (NSString* name in rawLists.allKeys) {
            List* list = [[List alloc] initWithDesign:self name:name];
            [lists setObject:list forKey:name];
        }
        _lists = lists;
        
        NSDictionary* rawUpdates = [properties getNonEmptyDictionaryWithPath:@"updates"];
        NSMutableDictionary* updates = [NSMutableDictionary dictionary];
        for (NSString* name in rawUpdates.allKeys) {
            Update* update = [[Update alloc] initWithDesign:self name:name];
            [updates setObject:update forKey:name];
        }
        _updates = updates;
    }
    return self;
}

-(NSString*)description {
    return [NSString stringWithFormat:@"<Design: database=%@ identifier=%@ revision=%@ views:%i filters:%i lists:%i updates:%i>",self.database,self.identifier,self.revision,self.views.count,self.filters.count,self.lists.count,self.updates.count];
}

@end
