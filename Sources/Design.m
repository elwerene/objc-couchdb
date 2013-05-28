//
//  Design.m
//  objc-couchdb
//
//  Created by René Rössler on 08.04.13.
//  Copyright (c) 2013 FreshX GbR. All rights reserved.
//

#import "ObjC_CouchDB.h"
#import <CocoaLumberjack/DDLog.h>
extern int ddLogLevel;

@implementation Design

-(id)initWithDatabase:(Database*)database properties:(NSDictionary*)properties {
    self = [super initWithDatabase:database properties:properties];
    if (self) {
        NSDictionary* rawViews = [properties objectForKey:@"views"];
        if (rawViews == nil || rawViews.count == 0) {
            _views = @{};
        } else {
            NSMutableDictionary* views = [NSMutableDictionary dictionary];
            for (NSString* name in rawViews.allKeys) {
                View* view = [[View alloc] initWithDesign:self name:name];
                [views setObject:view forKey:name];
            }
            _views = views;
        }
        
        NSDictionary* rawFilters = [properties objectForKey:@"filters"];
        if (rawFilters == nil || rawFilters.count == 0) {
            _filters = @{};
        } else {
            NSMutableDictionary* filters = [NSMutableDictionary dictionary];
            for (NSString* name in rawFilters.allKeys) {
                Filter* filter = [[Filter alloc] initWithDesign:self name:name];
                [filters setObject:filter forKey:name];
            }
            _filters = filters;
        }
        
        NSDictionary* rawLists = [properties objectForKey:@"lists"];
        if (rawLists == nil || rawLists.count == 0) {
            _lists = @{};
        } else {
            NSMutableDictionary* lists = [NSMutableDictionary dictionary];
            for (NSString* name in rawLists.allKeys) {
                List* list = [[List alloc] initWithDesign:self name:name];
                [lists setObject:list forKey:name];
            }
            _lists = lists;
        }
        
        NSDictionary* rawUpdates = [properties objectForKey:@"updates"];
        if (rawUpdates == nil || rawUpdates.count == 0) {
            _updates = @{};
        } else {
            NSMutableDictionary* updates = [NSMutableDictionary dictionary];
            for (NSString* name in rawUpdates.allKeys) {
                Update* update = [[Update alloc] initWithDesign:self name:name];
                [updates setObject:update forKey:name];
            }
            _updates = updates;
        }
    }
    return self;
}

-(NSString*)description {
    return [NSString stringWithFormat:@"<Design: database=%@ identifier=%@ revision=%@ views:%i filters:%i lists:%i updates:%i>",self.database,self.identifier,self.revision,self.views.count,self.filters.count,self.lists.count,self.updates.count];
}

@end
