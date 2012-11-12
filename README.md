KZObserver
==========

ObjC KVO support utils


example
----------

```objc
id dataObject = [[SomeDataObject alloc] init];
id viewObject = [[SomeViewObject alloc] init];

{
    KZObserver *observer = [[KZObserver alloc] initWithTarget:dataObject destination:viewObject];
    [observer bindValueFromKeyPath:@"property1" toKeyPath:@"property2"];
    
    [dataObject setProperty1:@"value"];
    STAssertEquals([viewObject property2], @"value", @"");
}

//KVO is removed when observer is deallocated
```