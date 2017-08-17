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
//  OPJMModelError.h
//  OPJMModel
//

#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////////////////////////////////////////////
typedef NS_ENUM(int, kOPJMModelErrorTypes)
{
    kOPJMModelErrorInvalidData = 1,
    kOPJMModelErrorBadResponse = 2,
    kOPJMModelErrorBadJSON = 3,
    kOPJMModelErrorModelIsInvalid = 4,
    kOPJMModelErrorNilInput = 5
};

/////////////////////////////////////////////////////////////////////////////////////////////
/** The domain name used for the OPJMModelError instances */
extern NSString *const OPJMModelErrorDomain;

/**
 * If the model JSON input misses keys that are required, check the
 * userInfo dictionary of the OPJMModelError instance you get back -
 * under the kOPJMModelMissingKeys key you will find a list of the
 * names of the missing keys.
 */
extern NSString *const kOPJMModelMissingKeys;

/**
 * If JSON input has a different type than expected by the model, check the
 * userInfo dictionary of the OPJMModelError instance you get back -
 * under the kOPJMModelTypeMismatch key you will find a description
 * of the mismatched types.
 */
extern NSString *const kOPJMModelTypeMismatch;

/**
 * If an error occurs in a nested model, check the userInfo dictionary of
 * the OPJMModelError instance you get back - under the kOPJMModelKeyPath
 * key you will find key-path at which the error occurred.
 */
extern NSString *const kOPJMModelKeyPath;

/////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Custom NSError subclass with shortcut methods for creating
 * the common OPJMModel errors
 */
@interface OPJMModelError : NSError

@property (strong, nonatomic) NSHTTPURLResponse *httpResponse;

@property (strong, nonatomic) NSData *responseData;

/**
 * Creates a OPJMModelError instance with code kOPJMModelErrorInvalidData = 1
 */
+ (id)errorInvalidDataWithMessage:(NSString *)message;

/**
 * Creates a OPJMModelError instance with code kOPJMModelErrorInvalidData = 1
 * @param keys a set of field names that were required, but not found in the input
 */
+ (id)errorInvalidDataWithMissingKeys:(NSSet *)keys;

/**
 * Creates a OPJMModelError instance with code kOPJMModelErrorInvalidData = 1
 * @param mismatchDescription description of the type mismatch that was encountered.
 */
+ (id)errorInvalidDataWithTypeMismatch:(NSString *)mismatchDescription;

/**
 * Creates a OPJMModelError instance with code kOPJMModelErrorBadResponse = 2
 */
+ (id)errorBadResponse;

/**
 * Creates a OPJMModelError instance with code kOPJMModelErrorBadJSON = 3
 */
+ (id)errorBadJSON;

/**
 * Creates a OPJMModelError instance with code kOPJMModelErrorModelIsInvalid = 4
 */
+ (id)errorModelIsInvalid;

/**
 * Creates a OPJMModelError instance with code kOPJMModelErrorNilInput = 5
 */
+ (id)errorInputIsNil;

/**
 * Creates a new OPJMModelError with the same values plus information about the key-path of the error.
 * Properties in the new error object are the same as those from the receiver,
 * except that a new key kOPJMModelKeyPath is added to the userInfo dictionary.
 * This key contains the component string parameter. If the key is already present
 * then the new error object has the component string prepended to the existing value.
 */
- (instancetype)errorByPrependingKeyPathComponent:(NSString *)component;

/////////////////////////////////////////////////////////////////////////////////////////////
@end
