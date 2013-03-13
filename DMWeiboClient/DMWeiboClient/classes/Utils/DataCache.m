//
//  DataCache.m
//  ZFSoftForIOS
//
//  Created by j on 12-10-19.
//  Copyright (c) 2012年 zfsoft. All rights reserved.
//
#define DATAARCHIVEFOLDER @"archive"

#import "DataCache.h"

@implementation DataCache

+ (void)writeCache:(id)data forKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
}

+ (id)readCacheforKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+(id)readCacheFromArchiveforKey:(NSString *)key forUser:(NSString *)user
{
    id object = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    path = [path stringByAppendingPathComponent:DATAARCHIVEFOLDER];
    if (user) {//用户文件
        path = [path stringByAppendingPathComponent:user];
    }
    else{//公用文件
        path = [path stringByAppendingPathComponent:@"public"];
    }
    path = [path stringByAppendingPathComponent:key];
    if ([fileManager fileExistsAtPath:path]) {//判断文件是否存在
        object = [NSKeyedUnarchiver unarchiveObjectWithFile:path];//读取缓存文件
    }
    return object;
}

+(BOOL)writeCacheToArchive:(id)data forKey:(NSString *)key forUser:(NSString *)user
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    path = [path stringByAppendingPathComponent:DATAARCHIVEFOLDER];
    if (user) {//用户文件
        path = [path stringByAppendingPathComponent:user];
    }
    else{//公用文件
        path = [path stringByAppendingPathComponent:@"public"];
    }
    BOOL isDir;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        NSError *error;
        BOOL created = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];//创建目录
        if (!created && error) {
            DebugLog(@"%@",error);
            return false;
        }
        
    }
    path = [path stringByAppendingPathComponent:key];
    BOOL success = [NSKeyedArchiver archiveRootObject:data toFile:path];//保存对象
    return success;

}

+(id)readCacheFromArchiveforKey:(NSString *)key
{
    return [self readCacheFromArchiveforKey:key forUser:nil];
}

+(BOOL)writeCacheToArchive:(id)data forKey:(NSString *)key
{
    return [self writeCacheToArchive:data forKey:key forUser:nil];

}

+ (void)clearCacheFromArchive
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    path = [path stringByAppendingPathComponent:DATAARCHIVEFOLDER];
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error;
        BOOL success=[fileManager removeItemAtPath:path error:&error];
        if (!success&&error) {
//            NSLog(@"%@",error.userInfo);
        }
    }
    
    NSString *cachePath = [DataCache cachePathAppendKey:nil];
    if ([fileManager fileExistsAtPath:cachePath]) {
       [fileManager removeItemAtPath:cachePath error:nil];
    }
}

//数组存储
+ (void)writeToFile:(NSArray *)array forKey:(NSString *)key
{
    NSString *path = [DataCache cachePathAppendKey:key];
    if ([array writeToFile: path atomically: YES]) {
		DebugLog(@"___ File was writed successfully!");  // File was writed successfully!
	}
}

+ (NSArray *)readFileFromKey:(NSString *)key
{
    NSString *path = [DataCache cachePathAppendKey:key];
    return [NSArray arrayWithContentsOfFile: path];
}


//字符串xml存储
+ (void)writeToXml:(NSString *)string forKey:(NSString *)key
{
    NSString *path = [DataCache cachePathAppendKey:key];
    if ([string writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil]) {
        DebugLog(@"___ File was writed successfully!");  // File was writed successfully!
    }
}

+ (NSString *)readXMLFromKey:(NSString *)key
{
    NSString *path = [DataCache cachePathAppendKey:key];
    NSString *instring = [NSString stringWithContentsOfFile: path
                                                   encoding: NSUTF8StringEncoding error: nil];
    return instring;
}

+ (NSString *)cachePathAppendKey:(NSString *)key
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //NSString *path = [NSHomeDirectory() stringByAppendingPathComponent: @"Documents"];
    if (key) {
        path = [path stringByAppendingPathComponent:key];
    }
    return path;
}

@end
