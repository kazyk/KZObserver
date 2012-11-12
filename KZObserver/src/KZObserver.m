//
//  Created by kazuyuki takahashi on 12/04/07.
//


#import "KZObserver.h"

static NSString *const kSourceKeyPathKey = @"Source";
static NSString *const kDestinationKeyPathKey = @"Dest";


@implementation KZObserver {
    NSMutableDictionary *_bindings;
    NSInteger _context;
}

@synthesize target = _target;
@synthesize destination = _destination;

- (id)initWithTarget:(id)target destination:(id)destination
{
    NSParameterAssert(target);
    NSParameterAssert(destination);
    self = [super init];
    if (self) {
        _target = target;
        _destination = destination;
        _bindings = [[NSMutableDictionary alloc] init];
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

- (void)bindValueFromKeyPath:(NSString *)srcKeyPath toKeyPath:(NSString *)destKeyPath
{
    ++_context;
    NSAssert(_context > 0, @"");
    NSNumber *context = [NSNumber numberWithInteger:_context];
    NSDictionary *infodic = [NSDictionary dictionaryWithObjectsAndKeys:
            srcKeyPath, kSourceKeyPathKey,
            destKeyPath, kDestinationKeyPathKey, nil];
    [_bindings setObject:infodic forKey:context];
    
    //set current value
    [[self destination] setValue:[[self target] valueForKeyPath:srcKeyPath] forKeyPath:destKeyPath];

    [_target addObserver:self
              forKeyPath:srcKeyPath
                 options:NSKeyValueObservingOptionNew
                 context:(__bridge void*)context];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    NSDictionary *infodic = [_bindings objectForKey:(__bridge id)context];
    NSString *destKeyPath = [infodic objectForKey:kDestinationKeyPathKey];
    if (destKeyPath) {
        [_destination setValue:[object valueForKeyPath:keyPath]
                    forKeyPath:destKeyPath];
    }
}

@end
