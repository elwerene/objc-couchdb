//
//  Document.m
//  objc-couchdb
//
//  Created by René Rössler on 08.04.13.
//  Copyright (c) 2013 FreshX GbR. All rights reserved.
//

#import "objc_couchdb.h"

@implementation Document

-(id)initWithDatabase:(Database*)database properties:(NSDictionary*)properties {
    self = [super init];
    if (self) {
        _database = database;
        _properties = properties;
        _identifier = [properties objectForKey:@"_id"];
        _revision = [properties objectForKey:@"_rev"];
        _deleted = [[properties objectForKey:@"deleted"] isEqualToNumber:@YES];
        
        NSDictionary* metaAttachments = [properties objectForKey:@"_attachments"];
        if (metaAttachments == nil || metaAttachments.count == 0) {
            _attachments = @{};
        } else {
            NSMutableDictionary* attachments = [NSMutableDictionary dictionary];
            for (NSString* name in metaAttachments.allKeys) {
                NSDictionary* metaAttachment = [metaAttachments objectForKey:name];
                Attachment* attachment = [[Attachment alloc] initWithDocument:self name:name properties:metaAttachment];
                [attachments setObject:attachment forKey:name];
            }
            _attachments = attachments;
        }
    }
    return self;
}

-(NSString*)description {
    return [NSString stringWithFormat:@"<Document: database=%@ identifier=%@ revision=%@>",self.database,self.identifier,self.revision];
}

#pragma mark - operations

-(void)deleteWithFinishedBlock:(DeleteDocumentFinishedBlock)finishedBlock errorBlock:(DeleteDocumentErrorBlock)errorBlock {
    //TODO
}

-(void)putProperties:(NSDictionary*)properties finishedBlock:(PutPropertiesFinishedBlock)finishedBlock errorBlock:(PutPropertiesErrorBlock)errorBlock {
    //TODO
}

-(void)putAttachmentNamed:(NSString*)name mimetype:(NSString*)mimetype data:(NSData*)data finishedBlock:(PutAttachmentFinishedBlock)finishedBlock errorBlock:(PutAttachmentErrorBlock)errorBlock {
    //TODO
}

@end
