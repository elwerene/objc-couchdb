//
//  ChangesOutputStream.m
//  restyTest
//
//  Created by René Rössler on 08.04.13.
//  Copyright (c) 2013 FreshX GbR. All rights reserved.
//

#import "ObjC_CouchDB.h"
#import <CocoaLumberjack/DDLog.h>
extern int ddLogLevel;

@interface ChangesOutputStream()
@property (nonatomic) NSMutableData* buffer;
@property (nonatomic) NSObject<InternalChangeDelegate>* delegate;
@end

@implementation ChangesOutputStream

-(id)initWithDelegate:(NSObject<InternalChangeDelegate>*)delegate {
    self = [super init];
    if (self) {
        _buffer = [NSMutableData data];
        _delegate = delegate;
    }
    return self;
}

#pragma mark - implemented abstract methods

-(BOOL)hasSpaceAvailable {
    return YES;
}

-(NSInteger)write:(const uint8_t *)chunk maxLength:(NSUInteger)len {
    [self.buffer appendBytes:chunk length:len];
    [self parseChanges];
    
    return len;
}

#pragma mark - ignored abstract methods

-(void)open {}
-(void)close {}
-(void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode {}
-(void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode {}

#pragma mark - changes parsing

-(void)parseChanges {
    const char* buf = [self.buffer bytes];
    
    int eol = -1;
    for (int i = 0; i<self.buffer.length; i++) {
        if (buf[i] == '\n') {
            int length = i-eol-1;
            
            if (length > 0) {
                NSData* line = [NSData dataWithBytes:buf+eol+1 length:length];
                
                NSError* error = nil;
                NSDictionary* change = [NSJSONSerialization JSONObjectWithData:line options:0 error:&error];
                
                if(error) {
                    DDLogError(@"[ChangesOutputStream] JSON Parsing Error: %@", error);
                } else if (change) {
                    [self.delegate newChange:change];
                }
            }
            
            eol = i;
        }
    }
    
    if (eol != -1) {
        NSRange newRange = NSMakeRange(eol, self.buffer.length-eol);
        [self.buffer setData:[self.buffer subdataWithRange:newRange]];
    }
}

@end
