//
//  ChangesOutputStream.h
//  restyTest
//
//  Created by René Rössler on 08.04.13.
//  Copyright (c) 2013 FreshX GbR. All rights reserved.
//

#import "ObjC-CouchDB.h"

@protocol InternalChangeDelegate<NSObject>
-(void)newChange:(NSDictionary*)changeDict;
@end

@interface ChangesOutputStream : NSOutputStream {
    @private
    NSMutableData* _buffer;
    NSObject<InternalChangeDelegate>* _delegate;
}

-(id)initWithDelegate:(NSObject<InternalChangeDelegate>*)delegate;

@end
