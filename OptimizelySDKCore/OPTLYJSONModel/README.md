# OPTLYJSONModel - Magical Data Modeling Framework for JSON

OPTLYJSONModel allows rapid creation of smart data models. You can use it in your
iOS, macOS, watchOS and tvOS apps. Automatic introspection of your model classes
and JSON input drastically reduces the amount of code you have to write.

OPTLYJSONModel is a modified copy of the original JSONModel covered by the "LICENSE"
file mentioned at the end of this document.

## Basic Usage

Consider you have JSON like this:

```json
{ "id": 10, "country": "Germany", "dialCode": 49, "isInEurope": true }
```

- create a OPTLYJSONModel subclass for your data model
- declare properties in your header file with the name of the JSON keys:

```objc
@interface CountryModel : OPTLYJSONModel
@property (nonatomic) NSInteger id;
@property (nonatomic) NSString *country;
@property (nonatomic) NSString *dialCode;
@property (nonatomic) BOOL isInEurope;
@end
```

There's no need to do anything in the implementation (`.m`) file.

- initialize your model with data:

```objc
NSError *error;
CountryModel *country = [[CountryModel alloc] initWithString:myJson error:&error];
```

If the validation of the JSON passes. you have all the corresponding properties
in your model populated from the JSON. OPTLYJSONModel will also try to convert as
much data to the types you expect. In the example above it will:

- convert `id` from string (in the JSON) to an `int` for your class
- copy the `country` value
- convert `dialCode` from a number (in the JSON) to an `NSString` value
- copy the `isInEurope` value

All you have to do is define the properties and their expected types.

## Examples

### Automatic name based mapping

```json
{
	"id": 123,
	"name": "Product name",
	"price": 12.95
}
```

```objc
@interface ProductModel : OPTLYJSONModel
@property (nonatomic) NSInteger id;
@property (nonatomic) NSString *name;
@property (nonatomic) float price;
@end
```

### Model cascading (models including other models)

```json
{
	"orderId": 104,
	"totalPrice": 13.45,
	"product": {
		"id": 123,
		"name": "Product name",
		"price": 12.95
	}
}
```

```objc
@interface ProductModel : OPTLYJSONModel
@property (nonatomic) NSInteger id;
@property (nonatomic) NSString *name;
@property (nonatomic) float price;
@end

@interface OrderModel : OPTLYJSONModel
@property (nonatomic) NSInteger orderId;
@property (nonatomic) float totalPrice;
@property (nonatomic) ProductModel *product;
@end
```

### Model collections

```json
{
	"orderId": 104,
	"totalPrice": 103.45,
	"products": [
		{
			"id": 123,
			"name": "Product #1",
			"price": 12.95
		},
		{
			"id": 137,
			"name": "Product #2",
			"price": 82.95
		}
	]
}
```

```objc
@protocol ProductModel;

@interface ProductModel : OPTLYJSONModel
@property (nonatomic) NSInteger id;
@property (nonatomic) NSString *name;
@property (nonatomic) float price;
@end

@interface OrderModel : OPTLYJSONModel
@property (nonatomic) NSInteger orderId;
@property (nonatomic) float totalPrice;
@property (nonatomic) NSArray <ProductModel> *products;
@end
```

Note: the angle brackets after `NSArray` contain a protocol. This is not the
same as the Objective-C generics system. They are not mutually exclusive, but
for OPTLYJSONModel to work, the protocol must be in place.

### Nested key mapping

```json
{
	"orderId": 104,
	"orderDetails": {
		"name": "Product #1",
		"price": {
			"usd": 12.95
		}
	}
}
```

```objc
@interface OrderModel : OPTLYJSONModel
@property (nonatomic) NSInteger id;
@property (nonatomic) NSString *productName;
@property (nonatomic) float price;
@end

@implementation OrderModel

+ (OPTLYJSONKeyMapper *)keyMapper
{
	return [[OPTLYJSONKeyMapper alloc] initWithModelToJSONDictionary:@{
		@"id": @"orderId",
		@"productName": @"orderDetails.name",
		@"price": @"orderDetails.price.usd"
	}];
}

@end
```

### Map automatically to snake_case

```json
{
	"order_id": 104,
	"order_product": "Product #1",
	"order_price": 12.95
}
```

```objc
@interface OrderModel : OPTLYJSONModel
@property (nonatomic) NSInteger orderId;
@property (nonatomic) NSString *orderProduct;
@property (nonatomic) float orderPrice;
@end

@implementation OrderModel

+ (OPTLYJSONKeyMapper *)keyMapper
{
	return [OPTLYJSONKeyMapper mapperForSnakeCase];
}

@end
```

### Optional properties (i.e. can be missing or null)

```json
{
	"id": 123,
	"name": null,
	"price": 12.95
}
```

```objc
@interface ProductModel : OPTLYJSONModel
@property (nonatomic) NSInteger id;
@property (nonatomic) NSString <OPTLYOptional> *name;
@property (nonatomic) float price;
@property (nonatomic) NSNumber <OPTLYOptional> *uuid;
@end
```

### Ignored properties (i.e. OPTLYJSONModel completely ignores them)

```json
{
	"id": 123,
	"name": null
}
```

```objc
@interface ProductModel : OPTLYJSONModel
@property (nonatomic) NSInteger id;
@property (nonatomic) NSString <Ignore> *customProperty;
@end
```

### Making scalar types optional

```json
{
	"id": null
}
```

```objc
@interface ProductModel : OPTLYJSONModel
@property (nonatomic) NSInteger id;
@end

@implementation ProductModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
	if ([propertyName isEqualToString:@"id"])
		return YES;

	return NO;
}

@end
```

### Export model to `NSDictionary` or JSON

```objc
ProductModel *pm = [ProductModel new];
pm.name = @"Some Name";

// convert to dictionary
NSDictionary *dict = [pm toDictionary];

// convert to json
NSString *string = [pm toJSONString];
```

### Custom data transformers

```objc
@interface OPTLYJSONValueTransformer (CustomNSDate)
@end

@implementation OPTLYJSONValueTransformer (CustomTransformer)

- (NSDate *)NSDateFromNSString:(NSString *)string
{
	NSDateFormatter *formatter = [NSDateFormatter new];
	formatter.dateFormat = APIDateFormat;
	return [formatter dateFromString:string];
}

- (NSString *)JSONObjectFromNSDate:(NSDate *)date
{
	NSDateFormatter *formatter = [NSDateFormatter new];
	formatter.dateFormat = APIDateFormat;
	return [formatter stringFromDate:date];
}

@end
```

### Custom getters/setters

```objc
@interface ProductModel : OPTLYJSONModel
@property (nonatomic) NSInteger id;
@property (nonatomic) NSString *name;
@property (nonatomic) float price;
@property (nonatomic) NSLocale *locale;
@end

@implementation ProductModel

- (void)setLocaleWithNSString:(NSString *)string
{
	self.locale = [NSLocale localeWithLocaleIdentifier:string];
}

- (void)setLocaleWithNSDictionary:(NSDictionary *)dictionary
{
	self.locale = [NSLocale localeWithLocaleIdentifier:dictionary[@"identifier"]];
}

- (NSString *)JSONObjectForLocale
{
	return self.locale.localeIdentifier;
}

@end
```

### Custom JSON validation

```objc

@interface ProductModel : OPTLYJSONModel
@property (nonatomic) NSInteger id;
@property (nonatomic) NSString *name;
@property (nonatomic) float price;
@property (nonatomic) NSLocale *locale;
@property (nonatomic) NSNumber <Ignore> *minNameLength;
@end

@implementation ProductModel

- (BOOL)validate:(NSError * __autoreleasing *)error
{
	if (![super validate:error])
		return NO;

	if (self.name.length < self.minNameLength.integerValue)
	{
		*error = [NSError errorWithDomain:@"me.mycompany.com" code:1 userInfo:nil];
		return NO;
	}

	return YES;
}

@end
```

## License

MIT licensed - see [LICENSE](LICENSE) file.

## Modifications to JSONModel by Optimizely, Inc.

Copyright 2017, Optimizely, Inc. and contributors

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.  
