//
//  CMTimer.m
//  CMTools
//
//  Created by Jim on 2020/11/22.
//

#import "CMTimer.h"

#define kJimWeakObj(obj) __weak typeof(obj) weak##obj = obj

@interface CMTimer () {
    /** 定时器的标识 */
    NSString *_key;
}

/** 定时器 */
@property (nonatomic, strong) dispatch_source_t source;

@end

@implementation CMTimer

#pragma mark -- life cycle
- (instancetype)init {
    if (self = [super init]) {
        _maxTimeCount = kMaxCountDownTime;
        _interval = 1000;
    }
    return self;
}

#pragma mark -- public
- (void)startTimer {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    self.source = source;
    
    dispatch_source_set_timer(source, dispatch_walltime(NULL, 0), NSEC_PER_MSEC * _interval, 0);
    NSDate *endTime = [NSDate dateWithTimeIntervalSinceNow:self.maxTimeCount];
    NSDate *startTime = [NSDate date];
    dispatch_source_set_event_handler(source, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isRepeat) {
                if (self.changeBlock) {
                    self.changeBlock(-[startTime timeIntervalSinceNow]);
                }
            }else {
                int interval = [endTime timeIntervalSinceNow];
                if (interval <= 0) { // 结束定时器
                    dispatch_source_cancel(source);
                    if (self.endBlock) {
                        self.endBlock();
                    }
                }else { // 倒计时
                    if (self.changeBlock) {
                        self.changeBlock(interval);
                    }
                }
            }
        });
    });
    
    dispatch_resume(source);
}
- (void)cancelTimer {
    dispatch_source_cancel(self.source);
    self.source = nil;
}

#pragma mark -- Getter & Setter
- (void)setKey:(NSString *)key {
    if ([key isKindOfClass:[NSString class]]) {
        _key = key;
    }
}
- (NSString *)key {
    if (!_key) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyyMMddHHmmssSSS";
        _key = [dateFormatter stringFromDate:[NSDate date]];
    }
    return _key;
}

@end



#pragma mark -- CMTimerManager
@interface CMTimerManager ()

/** 保存定时器 key:时间戳, value:CMTimer */
@property (nonatomic, strong) NSMutableDictionary<NSString *, CMTimer *> *timerDic;

@end

@implementation CMTimerManager

static CMTimerManager *__manager;

#pragma mark -- public
+ (instancetype)manager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __manager = [CMTimerManager new];
    });
    
    return __manager;
}

#pragma mark -- block形式的定时器
+ (NSString *)startTimerWithChangeBlock:(CMTimerManagerChangeBlock)changeBlock
                               endBlock:(CMTimerManagerEndBlock)endBlock {
    return [self startTimerWithChangeBlock:changeBlock
                                  endBlock:endBlock
                              maxTimeCount:0];
}
+ (NSString *)startTimerWithChangeBlock:(CMTimerManagerChangeBlock)changeBlock
                               endBlock:(CMTimerManagerEndBlock)endBlock
                           maxTimeCount:(NSUInteger)maxTimeCount {
    CMTimer *timer = [CMTimer new];
    kJimWeakObj(timer);
    timer.changeBlock = ^(int interval) {
        if (changeBlock) {
            changeBlock(weaktimer.key, interval);
        }
    };
    timer.endBlock = ^{
        [self cancelTimerWithKey:weaktimer.key];
        
        if (endBlock) {
            endBlock(weaktimer.key);
        }
    };
    timer.maxTimeCount = maxTimeCount;
    
    return [self startTimerWithTimer:timer];
}
+ (NSString *)startTimerWithTimer:(CMTimer *)timer {
    if (!([timer isKindOfClass:[CMTimer class]] &&
          [timer.key isKindOfClass:[NSString class]])) {
        return nil;
    }
    if ([[CMTimerManager manager].timerDic.allKeys containsObject:timer.key]) {
        return timer.key;
    }
    
    [timer startTimer];
    
    [CMTimerManager manager].timerDic[timer.key] = timer;
    return timer.key;
}

#pragma mark -- 通知形式的定时器
+ (CMTimer *)startNotificationTimerWithKey:(nullable NSString *)key {
    return [self startNotificationTimerWithKey:key maxTimeCount:kMaxCountDownTime];
}
+ (CMTimer *)startNotificationTimerWithKey:(NSString *)key maxTimeCount:(NSUInteger)maxTimeCount {
    CMTimer *timer = nil;
    if ([key isKindOfClass:[NSString class]]) {
        timer = [CMTimerManager manager].timerDic[key];
    }
    if (timer) {
        return timer;
    }
    
    timer = [CMTimer new];
    
    timer.maxTimeCount = maxTimeCount;
    if ([key isKindOfClass:[NSString class]]) {
        timer.key = key;
    }
    [self startNotificationTimerWithTimer:timer];
    
    return timer;
}

+ (NSString *)startNotificationTimerWithTimer:(CMTimer *)timer {
    if (!([timer isKindOfClass:[CMTimer class]] &&
          [timer.key isKindOfClass:[NSString class]])) {
        return nil;
    }
    
    if ([[CMTimerManager manager].timerDic.allKeys containsObject:timer.key]) {
        return timer.key;
    }
    
    kJimWeakObj(timer);
    timer.changeBlock = ^(int interval) {
        CMTimerManagerNotificationModel *model = [CMTimerManagerNotificationModel new];
        model.interval = interval;
        model.key = weaktimer.key;
        [[NSNotificationCenter defaultCenter] postNotificationName:weaktimer.key object:model];
    };
    timer.endBlock = ^{
        [self cancelTimerWithKey:weaktimer.key];
        
        CMTimerManagerNotificationModel *model = [CMTimerManagerNotificationModel new];
        model.interval = 0;
        model.key = weaktimer.key;
        [[NSNotificationCenter defaultCenter] postNotificationName:weaktimer.key object:model];
    };
    
    [timer startTimer];
    
    [CMTimerManager manager].timerDic[timer.key] = timer;
    return timer.key;
}

#pragma mark -- 其它
+ (void)cancelTimerWithKey:(NSString *)key {
    if ([key isKindOfClass:[NSString class]]) {
        CMTimer *timer = [CMTimerManager manager].timerDic[key];
        if (timer) {
            [timer cancelTimer];
            [[CMTimerManager manager].timerDic removeObjectForKey:key];
        }
    }
}

#pragma mark -- Getter & Setter
- (NSMutableDictionary<NSString *, CMTimer *> *)timerDic {
    if (!_timerDic) {
        _timerDic = [[NSMutableDictionary alloc] init];
    }
    return _timerDic;
}

@end


#pragma mark -- CMTimerManagerNotificationModel
@implementation CMTimerManagerNotificationModel

@end
