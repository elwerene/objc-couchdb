//
//  ChangeListener.h
//  objc-couchdb
//
//  Created by René Rössler on 08.04.13.
//  Copyright (c) 2013 FreshX GbR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChangesOutputStream.h"

@class Database, Filter, Change, MKNetworkOperation;

@protocol ChangesDelegate <NSObject>
-(void)newChange:(Change*)change;
@end

@interface ChangesListener : NSObject<InternalChangeDelegate> {
    @private
    Database* _database;
    Filter* _filter;
    
    NSMutableSet* _delegates;
    ChangesOutputStream* _stream;
    MKNetworkOperation* _operation;
}

@property (nonatomic, readonly) Database* database;
@property (nonatomic, readonly) Filter* filter;

-(id)initWithDatabase:(Database*)database filter:(Filter*)filter;
-(void)addDelegate:(NSObject<ChangesDelegate>*)delegate;
-(void)removeDelegate:(NSObject<ChangesDelegate>*)delegate;

@end
