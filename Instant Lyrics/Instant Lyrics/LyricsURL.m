//
//  LyricsURL.m
//  Instant Lyrics
//
//  Created by Tom Lai on 6/25/15.
//  Copyright © 2015 Tom. All rights reserved.
//

#import "LyricsURL.h"
@interface LyricsURL ()

@end
@implementation LyricsURL
@synthesize artistTitle=_artistTitle, url=_url;

- (instancetype)initWithUrl:(NSURL *)url
                     artistTitle:(NSString *) at
{
    self = [super init];
    [self setUrl:url];
    [self setArtistTitle:at];
    return self;
}
@end
