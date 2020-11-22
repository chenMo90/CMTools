//
//  CMTimer.h
//  CMTools
//
//  Created by Jim on 2020/11/22.
//

#import <Foundation/Foundation.h>

/** 定时器改变,单位秒 */
typedef void (^CMTimerChangeBlock)(int interval);
/** 定时器结束 */
typedef void (^CMTimerEndBlock)(void);

// 倒计时时间，可自定义
static NSUInteger kMaxCountDownTime = 60;

NS_ASSUME_NONNULL_BEGIN

@interface CMTimer : NSObject

/** 定时器最大时间,默认kMaxCountDownTime,单位秒 */
@property (nonatomic, assign) NSUInteger maxTimeCount;
/** 定时器改变 */
@property (nonatomic, copy) CMTimerChangeBlock changeBlock;
/** 定时器结束 */
@property (nonatomic, copy) CMTimerEndBlock endBlock;
/** 是否重复,默认不重复 */
@property (nonatomic, assign) BOOL isRepeat;
/** 默认1000ms 单位ms */
@property (nonatomic, assign) NSUInteger interval;

/** 开始定时器 */
- (void)startTimer;
/** 取消定时器 */
- (void)cancelTimer;

- (void)setKey:(NSString *)key;
- (NSString *)key;

@end


#pragma mark -- CMTimerManager
/** 定时器改变 key:定时器的标识，interval:剩余时间 */
typedef void (^CMTimerManagerChangeBlock)(NSString *key, int interval);
/** 定时器结束 key:定时器的标识 */
typedef void (^CMTimerManagerEndBlock)(NSString *key);

@interface CMTimerManager : NSObject

+ (instancetype)manager;

#pragma mark -- block形式的定时器
/**
 * 开始定时器，默认kMaxCountDownTime
 *
 * @param changeBlock 定时器改变
 * @param endBlock 定时器结束
 * @return 返回唯一标识，用来取消定时器的
 */
+ (NSString *)startTimerWithChangeBlock:(CMTimerManagerChangeBlock)changeBlock
                               endBlock:(CMTimerManagerEndBlock)endBlock;
/**
 * 开始定时器
 *
 * @param changeBlock 定时器改变
 * @param endBlock 定时器结束
 * @param maxTimeCount 定时器最大时间，单位秒
 * @return 返回唯一标识，用来取消定时器的
 */
+ (NSString *)startTimerWithChangeBlock:(CMTimerManagerChangeBlock)changeBlock
                               endBlock:(CMTimerManagerEndBlock)endBlock
                           maxTimeCount:(NSUInteger)maxTimeCount;
/**
 * 开始定时器
 *
 * @param timer 定时器
 * @return 返回唯一标识，用来取消定时器的
 */
+ (NSString *)startTimerWithTimer:(CMTimer *)timer;

#pragma mark -- 通知形式的定时器,需要接收通知请添加对应key的监听
/**
 * 开始定时器，默认kMaxCountDownTime,通知的形式
 *
 * @param key 自定义key
 * @return 返回唯一标识，用来取消定时器的，发送通知也是用这个key
 */
+ (CMTimer *)startNotificationTimerWithKey:(nullable NSString *)key;
/**
 * 开始定时器，通知的形式
 *
 * @param maxTimeCount 定时器最大时间，单位秒
 * @param key 自定义key
 */
+ (CMTimer *)startNotificationTimerWithKey:(nullable NSString *)key maxTimeCount:(NSUInteger)maxTimeCount;

/**
 *  开始定时器，通知的形式
 *
 *  @param timer 定时器,这个会重写changeBlock和endBlock
 *  @return 返回唯一标识，用来取消定时器的
 */
+ (NSString *)startNotificationTimerWithTimer:(CMTimer *)timer;

#pragma mark -- 其它
/** 取消定时器 */
+ (void)cancelTimerWithKey:(NSString *)key;

@end


#pragma mark -- CMTimerManagerNotificationModel
/** 监听返回的对象 */
@interface CMTimerManagerNotificationModel : NSObject

/** 标识 */
@property (nonatomic, copy) NSString *key;
/** 剩余多少时间,等于0表示结束，单位秒 */
@property (nonatomic, assign) NSUInteger interval;

@end

NS_ASSUME_NONNULL_END
