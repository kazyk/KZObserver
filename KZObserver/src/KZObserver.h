//
//  Created by kazuyuki takahashi on 12/04/07.
//


#import <Foundation/Foundation.h>


typedef void (^KZObserverBlock)(NSDictionary *changeDict);
typedef id (^KZObserverTransformBlock)(id value);


@interface KZObserver : NSObject

@property(strong, nonatomic, readonly) id target;
@property(weak, nonatomic, readonly) id destination;

@property(assign, nonatomic) BOOL performsOnMainThread; //default: YES

- (id)initWithTarget:(id)target destination:(id)destination;

- (void)observeValueForKeyPath:(NSString *)srcKeyPath
                       options:(NSKeyValueObservingOptions)options
                         block:(KZObserverBlock)block;

- (void)bindValueFromKeyPath:(NSString *)srcKeyPath
                   toKeyPath:(NSString *)destKeyPath;

- (void)bindValueFromKeyPath:(NSString *)srcKeyPath
                   toKeyPath:(NSString *)destKeyPath
                   withBlock:(KZObserverTransformBlock)block;

- (void)unbind;

@end
