/****************************************************************************
 * Modifications to JSONModel by Optimizely, Inc.                           *
 * Copyright 2017, Optimizely, Inc. and contributors                        *
 *                                                                          *
 * Licensed under the Apache License, Version 2.0 (the "License");          *
 * you may not use this file except in compliance with the License.         *
 * You may obtain a copy of the License at                                  *
 *                                                                          *
 *    http://www.apache.org/licenses/LICENSE-2.0                            *
 *                                                                          *
 * Unless required by applicable law or agreed to in writing, software      *
 * distributed under the License is distributed on an "AS IS" BASIS,        *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. *
 * See the License for the specific language governing permissions and      *
 * limitations under the License.                                           *
 ***************************************************************************/
//
//  OPJMKeyMapper.h
//  OPJMModel
//

#import <Foundation/Foundation.h>

typedef NSString *(^OPJMModelKeyMapBlock)(NSString *keyName);

/**
 * **You won't need to create or store instances of this class yourself.** If you want your model
 * to have different property names than the JSON feed keys, look below on how to
 * make your model use a key mapper.
 *
 * For example if you consume JSON from twitter
 * you get back underscore_case style key names. For example:
 *
 * <pre>"profile_sidebar_border_color": "0094C2",
 * "profile_background_tile": false,</pre>
 *
 * To comply with Obj-C accepted camelCase property naming for your classes,
 * you need to provide mapping between JSON keys and ObjC property names.
 *
 * In your model overwrite the + (OPJMKeyMapper *)keyMapper method and provide a OPJMKeyMapper
 * instance to convert the key names for your model.
 *
 * If you need custom mapping it's as easy as:
 * <pre>
 * + (OPJMKeyMapper *)keyMapper {
 * &nbsp; return [[OPJMKeyMapper&nbsp;alloc]&nbsp;initWithDictionary:@{@"crazy_JSON_name":@"myCamelCaseName"}];
 * }
 * </pre>
 * In case you want to handle underscore_case, **use the predefined key mapper**, like so:
 * <pre>
 * + (OPJMKeyMapper *)keyMapper {
 * &nbsp; return [OPJMKeyMapper&nbsp;mapperFromUnderscoreCaseToCamelCase];
 * }
 * </pre>
 */
@interface OPJMKeyMapper : NSObject

// deprecated
@property (readonly, nonatomic) OPJMModelKeyMapBlock JSONToModelKeyBlock DEPRECATED_ATTRIBUTE;
- (NSString *)convertValue:(NSString *)value isImportingToModel:(BOOL)importing DEPRECATED_MSG_ATTRIBUTE("use convertValue:");
- (instancetype)initWithDictionary:(NSDictionary *)map; // DEPRECATED_MSG_ATTRIBUTE("use initWithModelToJSONDictionary:");
- (instancetype)initWithJSONToModelBlock:(OPJMModelKeyMapBlock)toModel modelToJSONBlock:(OPJMModelKeyMapBlock)toJSON DEPRECATED_MSG_ATTRIBUTE("use initWithModelToJSONBlock:");
+ (instancetype)mapper:(OPJMKeyMapper *)baseKeyMapper withExceptions:(NSDictionary *)exceptions DEPRECATED_MSG_ATTRIBUTE("use baseMapper:withModelToJSONExceptions:");
+ (instancetype)mapperFromUnderscoreCaseToCamelCase DEPRECATED_MSG_ATTRIBUTE("use mapperForSnakeCase:");
+ (instancetype)mapperFromUpperCaseToLowerCase DEPRECATED_ATTRIBUTE;

/** @name Name converters */
/** Block, which takes in a property name and converts it to the corresponding JSON key name */
@property (readonly, nonatomic) OPJMModelKeyMapBlock modelToJSONKeyBlock;

/** Combined converter method
 * @param value the source name
 * @return OPJMKeyMapper instance
 */
- (NSString *)convertValue:(NSString *)value;

/** @name Creating a key mapper */

/**
 * Creates a OPJMKeyMapper instance, based on the block you provide this initializer.
 * The parameter takes in a OPJMModelKeyMapBlock block:
 * <pre>NSString *(^OPJMModelKeyMapBlock)(NSString *keyName)</pre>
 * The block takes in a string and returns the transformed (if at all) string.
 * @param toJSON transforms your model property name to a JSON key
 */
- (instancetype)initWithModelToJSONBlock:(OPJMModelKeyMapBlock)toJSON;

/**
 * Creates a OPJMKeyMapper instance, based on the mapping you provide.
 * Use your OPJMModel property names as keys, and the JSON key names as values.
 * @param toJSON map dictionary, in the format: <pre>@{@"myCamelCaseName":@"crazy_JSON_name"}</pre>
 * @return OPJMKeyMapper instance
 */
- (instancetype)initWithModelToJSONDictionary:(NSDictionary *)toJSON;

/**
 * Given a camelCase model property, this mapper finds JSON keys using the snake_case equivalent.
 */
+ (instancetype)mapperForSnakeCase;

/**
 * Given a camelCase model property, this mapper finds JSON keys using the TitleCase equivalent.
 */
+ (instancetype)mapperForTitleCase;

/**
 * Creates a OPJMKeyMapper based on a built-in OPJMKeyMapper, with specific exceptions.
 * Use your OPJMModel property names as keys, and the JSON key names as values.
 */
+ (instancetype)baseMapper:(OPJMKeyMapper *)baseKeyMapper withModelToJSONExceptions:(NSDictionary *)toJSON;

@end
