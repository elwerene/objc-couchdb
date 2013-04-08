//
//  Document.h
//  objc-couchdb
//
//  Created by René Rössler on 08.04.13.
//  Copyright (c) 2013 FreshX GbR. All rights reserved.
//

#import "objc_couchdb.h"

@class Database;

@interface Document : NSObject {
    @private
    Database* _database;
    NSDictionary* _properties;
    
    NSString* _identifier;
    NSString* _revision;
    BOOL _deleted;
    NSDictionary* _attachments;
}

@property (nonatomic, readonly) Database* database;
@property (nonatomic, readonly) NSDictionary* properties;
@property (nonatomic, readonly) NSString* identifier;
@property (nonatomic, readonly) NSString* revision;
@property (nonatomic, readonly) BOOL deleted;
@property (nonatomic, readonly) NSDictionary* attachments;

-(id)initWithDatabase:(Database*)database properties:(NSDictionary*)properties;

/* TODO:
 * 
 * PutProperties
 * Delete
 * PutAttachment
 */

@end
