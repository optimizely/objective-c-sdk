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
//  OPJMModelError.m
//  OPJMModel
//

#import "OPJMModelError.h"

NSString* const OPJMModelErrorDomain = @"OPJMModelErrorDomain";
NSString* const kOPJMModelMissingKeys = @"kOPJMModelMissingKeys";
NSString* const kOPJMModelTypeMismatch = @"kOPJMModelTypeMismatch";
NSString* const kOPJMModelKeyPath = @"kOPJMModelKeyPath";

@implementation OPJMModelError

+(id)errorInvalidDataWithMessage:(NSString*)message
{
    message = [NSString stringWithFormat:@"Invalid JSON data: %@", message];
    return [OPJMModelError errorWithDomain:OPJMModelErrorDomain
                                      code:kOPJMModelErrorInvalidData
                                  userInfo:@{NSLocalizedDescriptionKey:message}];
}

+(id)errorInvalidDataWithMissingKeys:(NSSet *)keys
{
    return [OPJMModelError errorWithDomain:OPJMModelErrorDomain
                                      code:kOPJMModelErrorInvalidData
                                  userInfo:@{NSLocalizedDescriptionKey:@"Invalid JSON data. Required JSON keys are missing from the input. Check the error user information.",kOPJMModelMissingKeys:[keys allObjects]}];
}

+(id)errorInvalidDataWithTypeMismatch:(NSString*)mismatchDescription
{
    return [OPJMModelError errorWithDomain:OPJMModelErrorDomain
                                      code:kOPJMModelErrorInvalidData
                                  userInfo:@{NSLocalizedDescriptionKey:@"Invalid JSON data. The JSON type mismatches the expected type. Check the error user information.",kOPJMModelTypeMismatch:mismatchDescription}];
}

+(id)errorBadResponse
{
    return [OPJMModelError errorWithDomain:OPJMModelErrorDomain
                                      code:kOPJMModelErrorBadResponse
                                  userInfo:@{NSLocalizedDescriptionKey:@"Bad network response. Probably the JSON URL is unreachable."}];
}

+(id)errorBadJSON
{
    return [OPJMModelError errorWithDomain:OPJMModelErrorDomain
                                      code:kOPJMModelErrorBadJSON
                                  userInfo:@{NSLocalizedDescriptionKey:@"Malformed JSON. Check the OPJMModel data input."}];
}

+(id)errorModelIsInvalid
{
    return [OPJMModelError errorWithDomain:OPJMModelErrorDomain
                                      code:kOPJMModelErrorModelIsInvalid
                                  userInfo:@{NSLocalizedDescriptionKey:@"Model does not validate. The custom validation for the input data failed."}];
}

+(id)errorInputIsNil
{
    return [OPJMModelError errorWithDomain:OPJMModelErrorDomain
                                      code:kOPJMModelErrorNilInput
                                  userInfo:@{NSLocalizedDescriptionKey:@"Initializing model with nil input object."}];
}

- (instancetype)errorByPrependingKeyPathComponent:(NSString*)component
{
    // Create a mutable  copy of the user info so that we can add to it and update it
    NSMutableDictionary* userInfo = [self.userInfo mutableCopy];

    // Create or update the key-path
    NSString* existingPath = userInfo[kOPJMModelKeyPath];
    NSString* separator = [existingPath hasPrefix:@"["] ? @"" : @".";
    NSString* updatedPath = (existingPath == nil) ? component : [component stringByAppendingFormat:@"%@%@", separator, existingPath];
    userInfo[kOPJMModelKeyPath] = updatedPath;

    // Create the new error
    return [OPJMModelError errorWithDomain:self.domain
                                      code:self.code
                                  userInfo:[NSDictionary dictionaryWithDictionary:userInfo]];
}

@end
