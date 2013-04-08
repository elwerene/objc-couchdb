//
//  Document.h
//  objc-couchdb
//
//  Created by René Rössler on 08.04.13.
//  Copyright (c) 2013 FreshX GbR. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Database;

@interface Document : NSObject {
    @private
    Database* _database;
    NSString* _identifier;
}

@property (nonatomic, readonly) Database* database;
@property (nonatomic, readonly) NSString* identifier;

@end
