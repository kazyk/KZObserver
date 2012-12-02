//
//  Created by kazuyuki takahashi on 12/04/07.
//


#import "KZObserver.h"

static NSString *const kSourceKeyPathKey = @"Source";
static NSString *const kDestinationKeyPathKey = @"Dest";
static NSString *const kBlockKey = @"Block";


@implementation KZObserver {
    NSMutableDictionary *_bindings;
    NSInteger _context;
}

@synthesize target = _target;
@synthesize destination = _destination;
@synthesize performsOnMainThread = _performsOnMainThread;

- (id)initWithTarget:(id)target destination:(id)destination
{
    NSParameterAssert(target);
    NSParameterAssert(destination);
    self = [super init];
    if (self) {
        _target = target;
        _destination = destination;
        _bindings = [[NSMutableDictionary alloc] init];
        _performsOnMainThread = YES;
    }
    return self;
}

- (id)init
{
    NSAssert(NO, @"invalid initializer");
    return nil;
}

- (void)unbind
{
    for (id context in _bindings) {
        NSString *keyPath = [[_bindings objectForKey:context] objectForKey:kSourceKeyPathKey];
        [_target removeObserver:self forKeyPath:keyPath];
    }
    [_bindings removeAllObjects];
}

- (void)dealloc
{
    [self unbind];
}

- (void)observeValueForKeyPath:(NSString *)srcKeyPath block:(KZObserverBlock)block
{
    NSParameterAssert([srcKeyPath length] > 0);
    NSParameterAssert(block);

    ++_context;
    NSNumber *context = [NSNumber numberWithInteger:_context];

    NSDictionary *infoDict = @{
            kSourceKeyPathKey: srcKeyPath,
            kBlockKey: block
    };
    [_bindings setObject:infoDict forKey:context];

    [_target addObserver:self
              forKeyPath:srcKeyPath
                 options:(NSKeyValueObservingOptions)0
                 context:(__bridge void*)context];
}

- (void)bindValueFromKeyPath:(NSString *)srcKeyPath toKeyPath:(NSString *)destKeyPath
{
    [self bindValueFromKeyPath:srcKeyPath toKeyPath:destKeyPath withBlock:nil];
}

- (void)bindValueFromKeyPath:(NSString *)srcKeyPath toKeyPath:(NSString *)destKeyPath withBlock:(KZObserverTransformBlock)block
{
    NSParameterAssert([srcKeyPath length] > 0);
    NSParameterAssert([destKeyPath length] > 0);

    ++_context;
    NSNumber *context = [NSNumber numberWithInteger:_context];

    NSDictionary *infoDict = nil;
    if (block) {
        infoDict = @{
            kSourceKeyPathKey: srcKeyPath,
            kDestinationKeyPathKey: destKeyPath,
            kBlockKey: block
        };
    } else {
        infoDict = @{
            kSourceKeyPathKey: srcKeyPath,
            kDestinationKeyPathKey: destKeyPath
        };
    }
    [_bindings setObject:infoDict forKey:context];

    //set current value
    id currentValue = [[self target] valueForKeyPath:srcKeyPath];
    if (block) {
        currentValue = block(currentValue);
    }
    [[self destination] setValue:currentValue forKeyPath:destKeyPath];

    [_target addObserver:self
              forKeyPath:srcKeyPath
                 options:(NSKeyValueObservingOptions)0
                 context:(__bridge void*)context];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    NSDictionary *infoDict = [_bindings objectForKey:(__bridge id)context];
    NSString *destKeyPath = [infoDict objectForKey:kDestinationKeyPathKey];
    if (destKeyPath) {
        id value = [object valueForKeyPath:keyPath];
        KZObserverTransformBlock block = [infoDict objectForKey:kBlockKey];
        if (block) {
            value = block(value);
        }
        
        if ([self performsOnMainThread] && ![NSThread isMainThread]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_destination setValue:value forKeyPath:destKeyPath];
            });
        } else {
            [_destination setValue:value forKeyPath:destKeyPath];
        }
    } else {
        id value = [object valueForKeyPath:keyPath];
        KZObserverBlock block = [infoDict objectForKey:kBlockKey];
        if (block) {
            if ([self performsOnMainThread] && ![NSThread isMainThread]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(value);
                });
            } else{
                block(value);
            }
        }
    }
}

@end
