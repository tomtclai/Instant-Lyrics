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
//@property (strong, nonatomic) ILURLEntry* lastEntry;

@end
@implementation ILURLLog
//@synthesize lastEntry = _lastEntry;
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
        
        NSString *path = [self itemArchivePath];
        self.LyricsURLs = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        // if the array hadn't been saved previously, create a new empty one
        if (!self.LyricsURLs)
        {
            self.LyricsURLs = [[NSMutableArray alloc] init];
        }
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
}
#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_LyricsURLs forKey:@"LyricsURLs"];
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if (self) {
        self.LyricsURLs = [aDecoder valueForKey:@"LyricsURLs"];
    }
    return self;
}
#pragma mark convenience
- (ILURLEntry *)lastEntry
{
    return [_LyricsURLs lastObject];
}
#pragma mark saving changes
- (NSString *)itemArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [documentDirectories firstObject];
    
    return [documentDirectory stringByAppendingPathExtension:@"ILURLLog.archive"];
}
- (BOOL)saveChanges
{
    NSString *path = [self itemArchivePath];
    
    BOOL result = [NSKeyedArchiver archiveRootObject:self.LyricsURLs
                                              toFile:path];
    
    return result;
    
}
@end
