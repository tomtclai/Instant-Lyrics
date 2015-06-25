//
//  LyricsURLMap.m
//  Instant Lyrics
//
//  Created by Tom Lai on 6/25/15.
//  Copyright © 2015 Tom. All rights reserved.
//
#import "LyricsURL.h"
#import "ILURLMap.h"
@interface ILURLMap ()
@property (strong, nonatomic) NSMutableArray *LyricsURLs;
@property (strong, nonatomic) LyricsURL* lastEntry;

@end
@implementation ILURLMap
@synthesize lastEntry = _lastEntry;
#pragma init
- (instancetype) init{
    self = [super init];
    self.LyricsURLs = [[NSMutableArray alloc] init];
    return self;
}
- (NSURL *)URLForArtistTitle:(NSString *) at
{
    LyricsURL *i  = nil;
    for (i in self.LyricsURLs)
    {
        if ([[i artistTitle] isEqualToString: at])
            break;
    }
    return [i url];
}
- (void)addURL:(nonnull NSURL *)url
        forArtistTitle:(NSString *) at
{
    LyricsURL * newEntry = [[LyricsURL alloc]initWithUrl:url
                                             artistTitle:at];
    
    [[self LyricsURLs] addObject:newEntry];
    [self setLastEntry:newEntry];
}
@end
