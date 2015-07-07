//
//  LyricsURLMap.m
//  Instant Lyrics
//
//  Created by Tom Lai on 6/25/15.
//  Copyright © 2015 Tom. All rights reserved.
//
#import "ILURLEntry.h"
#import "ILURLLog.h"
@interface ILURLLog ()
@property (strong, nonatomic) NSMutableArray *LyricsURLs;
@property (strong, nonatomic) ILURLEntry* lastEntry;

@end
@implementation ILURLLog
@synthesize lastEntry = _lastEntry;
#pragma mark singleton methods
+ (instancetype)sharedLog {
    static ILURLLog *sharedURLLog = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        sharedURLLog = [[self alloc]init];
    });
    return sharedURLLog;
}
#pragma mark init
- (instancetype) init{
    if (self = [super init]) {
        self.LyricsURLs = [[NSMutableArray alloc] init];
    }
    return self;
}
- (NSURL *)URLForArtistTitle:(NSString *) at
{
    ILURLEntry *i  = nil;
    for (i in self.LyricsURLs)
    {
        if ([[i artistTitle] isEqualToString: at])
            break;
    }
    return [i originUrl];
}
- (void)addURL:(nonnull NSURL *)url
        forArtistTitle:(NSString *) at
{
    ILURLEntry * newEntry = [[ILURLEntry alloc]initWithUrl:url
                                             artistTitle:at];
    
    [[self LyricsURLs] addObject:newEntry];
    [self setLastEntry:newEntry];
}
@end
