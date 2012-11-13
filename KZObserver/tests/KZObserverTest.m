//
//  Created by kazuyuki takahashi on 12/04/07.
//


#import "KZObserverTest.h"
#import "KZObserver.h"

@interface Target : NSObject
@property(strong, nonatomic) NSString *src1;
@property(strong, nonatomic) NSNumber *src2;
@end

@implementation Target
@synthesize src1, src2;
@end

@interface Destination : NSObject
@property(strong, nonatomic) NSString *dest1;
@property(strong, nonatomic) NSNumber *dest2;
@end

@implementation Destination
@synthesize dest1, dest2;
@end


@implementation KZObserverTest {
    Target *target;
    Destination *destination;
    KZObserver *observer;
}

- (void)setUp {
    target = [[Target alloc] init];
    destination = [[Destination alloc] init];
    observer = [[KZObserver alloc] initWithTarget:target destination:destination];
}

- (void)test {
    STAssertEquals([observer target], target, @"");
    STAssertEquals([observer destination], destination, @"");
}

- (void)testBind1 {
    [observer bindValueFromKeyPath:@"src1" toKeyPath:@"dest1"];
    STAssertNil([destination dest1], @"");
    [target setSrc1:@"hoge"];
    STAssertEqualObjects([destination dest1], @"hoge", @"");
}

- (void)testBind2 {
    [observer bindValueFromKeyPath:@"src1" toKeyPath:@"dest1"];
    [observer bindValueFromKeyPath:@"src2" toKeyPath:@"dest2"];
    [target setSrc1:@"val"];
    [target setSrc2:[NSNumber numberWithInt:4]];
    STAssertEqualObjects([destination dest1], @"val", @"");
    STAssertEqualObjects([destination dest2], [NSNumber numberWithInt:4], @"");
}

- (void)testSetCurrentValue {
    [target setSrc1:@"src"];
    [destination setDest1:@"dest"];
    [observer bindValueFromKeyPath:@"src1" toKeyPath:@"dest1"];
    STAssertEqualObjects([destination dest1], @"src", @"");
}

- (void)testBindWithBlock {
    [target setSrc1:@"before"];
    [destination setDest1:@"dest"];
    [observer bindValueFromKeyPath:@"src1" toKeyPath:@"dest1" withBlock:^(id value) {
        return [value uppercaseString];
    }];
    STAssertEqualObjects([destination dest1], @"BEFORE", @"");
    [target setSrc1:@"after"];
    STAssertEqualObjects([destination dest1], @"AFTER", @"");
}

- (void)testFromBackgroundThread {
    [observer bindValueFromKeyPath:@"src1" toKeyPath:@"dest1"];
    [target performSelectorInBackground:@selector(setSrc1:) withObject:@"value"];
    
    STAssertFalse([[destination dest1] isEqual:@"value"], @"");
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    STAssertEqualObjects([destination dest1], @"value", @"");
}

- (void)testUnbind {
    [observer bindValueFromKeyPath:@"src1" toKeyPath:@"dest1"];
    [observer unbind];

    [target setSrc1:@"hoge"];
    STAssertNil([destination dest1], @"");
}

- (void)testUnbindOnDealloc {
    {
        KZObserver *obs = [[KZObserver alloc] initWithTarget:target destination:destination];
        [obs bindValueFromKeyPath:@"src1" toKeyPath:@"dest1"];
        [target setSrc1:@"value1"];
        STAssertEqualObjects([destination dest1], @"value1", @"");
    }

    [target setSrc1:@"value2"];
    STAssertEqualObjects([destination dest1], @"value1", @"");
}

@end
