/****************************************************************************
 * Copyright 2018, Optimizely, Inc. and contributors                        *
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Validation)

/**
 * Determines if object is a valid non-empty string type.
 *
 * @returns A NSString if object is valid string type, else return nil.
 **/
- (nullable NSString *)getValidString;

/**
 * Determines if object is a valid non-empty array type.
 *
 * @returns A NSArray if object is valid array type, else return nil.
 **/
- (nullable NSArray *)getValidArray;

/**
 * Determines if object is a valid non-empty dictionary type.
 *
 * @returns A NSDictionary if object is valid dictionary type, else return nil.
 **/
- (nullable NSDictionary *)getValidDictionary;

/**
 * Returns a string value for the object
 *
 * @returns A NSString if object is valid string type, else return empty string.
 **/
- (NSString *)getStringOrEmpty;

/**
 * Determines if object is a valid audience conditions array type.
 *
 * @returns A NSArray of audience conditions if valid, else return nil.
 **/
- (nullable NSArray *)getValidAudienceConditionsArray;

/**
 * Determines if object is a valid conditions array type.
 *
 * @returns A NSArray of conditions if valid, else return nil.
 **/
- (nullable NSArray *)getValidConditionsArray;

/**
 * Returns if object is a valid attribute
 *
 * @returns A Bool whether object is a valid attribute.
 **/
- (BOOL)isValidAttributeValue;

/**
 * Returns if object is a valid boolean attribute
 *
 * @returns A Bool whether object is a valid boolean attribute.
 **/
- (BOOL)isValidBooleanAttributeValue;

/**
 * Returns if object is a valid numeric attribute
 *
 * @returns A Bool whether object is a valid numeric attribute.
 **/
- (BOOL)isValidNumericAttributeValue;

@end

NS_ASSUME_NONNULL_END
