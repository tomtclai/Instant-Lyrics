//
//  LyricsURL.m
//  Instant Lyrics
//
//  Created by Tom Lai on 6/25/15.
//  Copyright © 2015 Tom. All rights reserved.
//

#import "LyricsURL.h"
@interface LyricsURL ()
@property (strong, nonatomic) NSURL* originUrl;
@end
@implementation LyricsURL
@synthesize artistTitle=_artistTitle, destUrl = _destUrl, originUrl =_originUrl;
- (instancetype)initWithUrl:(NSURL *)url
                     artistTitle:(NSString *) at
{
    self = [super init];
    [self setOriginUrl: url];
    [self setDestUrl:url];
    [self setArtistTitle:at];
    return self;
}
@end
