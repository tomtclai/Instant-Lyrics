//
//  LyricsURL.m
//  Instant Lyrics
//
//  Created by Tom Lai on 6/25/15.
//  Copyright © 2015 Tom. All rights reserved.
//

#import "ILURLEntry.h"
@interface ILURLEntry ()
@property (strong, nonatomic) NSURL* originUrl;
@end
@implementation ILURLEntry
@synthesize artistTitle=_artistTitle, destUrl = _destUrl, originUrl =_originUrl;
- (instancetype)initWithUrl:(NSURL *)url
                     artistTitle:(NSString *) at
{
    self = [super init];
    if (self)
    {
        [self setOriginUrl: url];
        [self setDestUrl:url];
        [self setArtistTitle:at];
    }
    return self;
}

#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.artistTitle forKey:@"artistTitle"];
    [aCoder encodeObject:self.destUrl forKey:@"destUrl"];
    [aCoder encodeObject:self.originUrl forKey:@"originUrl"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.artistTitle = [aDecoder valueForKey:@"artistTitle"];
        self.destUrl = [aDecoder valueForKey:@"destUrl"];
        self.originUrl = [aDecoder valueForKey:@"originUrl"];
    }
    return self;
}
@end
