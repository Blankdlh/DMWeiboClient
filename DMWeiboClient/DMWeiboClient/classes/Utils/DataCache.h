//
//  DataCache.h
//  ZFSoftForIOS
//
//  Created by j on 12-10-19.
//  Copyright (c) 2012年 zfsoft. All rights reserved.
//


#import <Foundation/Foundation.h>
//本地化存储简单数据
@interface DataCache : NSObject

+ (void)writeCache:(id)data forKey:(NSString *)key;
+ (id)readCacheforKey:(NSString *)key;

//以存档方式缓存对象
+ (BOOL)writeCacheToArchive:(id)data forKey:(NSString*)key;
//读取缓存对象
+ (id)readCacheFromArchiveforKey:(NSString*)key;
//以存档方式缓存对象 区分用户
+ (BOOL)writeCacheToArchive:(id)data forKey:(NSString*)key forUser:(NSString*)user;
//读取缓存对象 区分用户
+ (id)readCacheFromArchiveforKey:(NSString*)key forUser:(NSString*)user;
+ (void)clearCacheFromArchive;

//文件存取（适用数组）
+ (void)writeToFile:(NSArray *)array forKey:(NSString *)key;
+ (NSArray *)readFileFromKey:(NSString *)key;

//字符串xml存储
+ (void)writeToXml:(NSString *)string forKey:(NSString *)key;
+ (NSString *)readXMLFromKey:(NSString *)key;

+ (NSString *)cachePathAppendKey:(NSString *)key;

@end

