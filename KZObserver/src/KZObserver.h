//
//  Created by kazuyuki takahashi on 12/04/07.
//


#import <Foundation/Foundation.h>


@interface KZObserver : NSObject

@property(strong, nonatomic, readonly) id target;
@property(weak, nonatomic, readonly) id destination;

- (id)initWithTarget:(id)target destination:(id)destination;

- (void)bindValueFromKeyPath:(NSString *)srcKeyPath toKeyPath:(NSString *)destKeyPath;

- (void)unbind;

@end
