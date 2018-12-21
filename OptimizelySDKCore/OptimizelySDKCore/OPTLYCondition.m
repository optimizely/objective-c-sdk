/****************************************************************************
 * Copyright 2016,2018, Optimizely, Inc. and contributors                   *
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

#import "OPTLYCondition.h"
#import "OPTLYDatafileKeys.h"
#import "OPTLYBaseCondition.h"
#import "OPTLYAudienceBaseCondition.h"
#import "OPTLYErrorHandlerMessages.h"

@implementation OPTLYCondition

+ (NSArray<OPTLYCondition *><OPTLYCondition> *)deserializeJSONArray:(NSArray *)jsonArray {
    return [OPTLYCondition deserializeJSONArray:jsonArray error:nil];
}

+ (NSArray<OPTLYCondition> *)deserializeAudienceConditionsJSONArray:(NSArray *)jsonArray {
    return [OPTLYCondition deserializeAudienceConditionsJSONArray:jsonArray error:nil];
}

// example jsonArray:
//  [“and", [“or", [“or", {"name": "sample_attribute_key", "type": "custom_attribute", "value": “a”}], [“or", {"name": "sample_attribute_key", "type": "custom_attribute", "value": "b"}], [“or", {"name": "sample_attribute_key", "type": "custom_attribute", "value": "c"}]
+ (NSArray<OPTLYCondition *><OPTLYCondition> *)deserializeJSONArray:(NSArray *)jsonArray
                                            error:(NSError * __autoreleasing *)error {
    
    NSMutableArray *mutableJsonArray = [NSMutableArray new];
    
    // need to check if the jsonArray is actually an array, otherwise, something is wrong with the audience condition
    if (![jsonArray isKindOfClass:[NSArray class]]) {
        if ([jsonArray isKindOfClass:[NSDictionary class]] && [OPTLYBaseCondition isBaseConditionJSON:((NSData *)jsonArray)]) {
            mutableJsonArray = [[NSMutableArray alloc] initWithArray:@[OPTLYDatafileKeysOrCondition,jsonArray]];
        }
        else {
            NSError *err = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                               code:OPTLYErrorTypesDatafileInvalid
                                           userInfo:@{NSLocalizedDescriptionKey : OPTLYErrorHandlerMessagesProjectConfigInvalidAudienceCondition}];
            if (error && err) {
                *error = err;
            }
            return nil;
        }
    }
    else {
        mutableJsonArray = [jsonArray mutableCopy];
    }
    
    if (mutableJsonArray.count < 2) {
        // Should return 'OR' operator in case there is none
        [mutableJsonArray insertObject:OPTLYDatafileKeysOrCondition atIndex:0];
    }
    
    if ([OPTLYBaseCondition isBaseConditionJSON:mutableJsonArray[1]]) { //base case condition
        
        // generate all base conditions
        NSMutableArray<OPTLYCondition> *conditions = (NSMutableArray<OPTLYCondition> *)[[NSMutableArray alloc] initWithCapacity:(mutableJsonArray.count - 1)];
        for (int i = 1; i < mutableJsonArray.count; i++) {
            NSDictionary *info = mutableJsonArray[i];
            NSError *err = nil;
            OPTLYBaseCondition *condition = [[OPTLYBaseCondition alloc] initWithDictionary:info
                                                                                     error:&err];
            if (error && err) {
                *error = err;
            }
            else {
                if (condition != nil) {
                    [conditions addObject:condition];
                }
            }
        }
        
        // return an (And/Or/Not) Condition handling the base conditions
        NSObject<OPTLYCondition> *condition = [OPTLYCondition createConditionInstanceOfClass:mutableJsonArray[0]
                                                                              withConditions:conditions];
        return (NSArray<OPTLYCondition *><OPTLYCondition> *)@[condition];
    }
    else {
        
        // further condition arrays to deserialize
        NSMutableArray<OPTLYCondition> *subConditions = (NSMutableArray<OPTLYCondition> *)[[NSMutableArray alloc] initWithCapacity:(mutableJsonArray.count - 1)];
        for (int i = 1; i < mutableJsonArray.count; i++) {
            NSError *err = nil;
            NSArray *deserializedJsonObject = [OPTLYCondition deserializeJSONArray:mutableJsonArray[i] error:&err];
            
            if (err) {
                *error = err;
                return nil;
            }
            
            if (deserializedJsonObject != nil) {
                [subConditions addObjectsFromArray:deserializedJsonObject];
            }
        }
        NSObject<OPTLYCondition> *condition = [OPTLYCondition createConditionInstanceOfClass:mutableJsonArray[0]
                                                                              withConditions:subConditions];
        return (NSArray<OPTLYCondition *><OPTLYCondition> *)@[condition];
    }
}

// example jsonArray:
//  "[\"and\", [\"or\", \"3468206642\", \"3988293898\"], [\"or\", \"3988293899\", \"3468206646\", \"3468206647\", \"3468206644\", \"3468206643\"]]"
+ (NSArray<OPTLYCondition> *)deserializeAudienceConditionsJSONArray:(NSArray *)jsonArray
                                                              error:(NSError * __autoreleasing *)error {

    // need to check if the jsonArray is actually an array, otherwise, something is wrong with the audience condition
    if (![jsonArray isKindOfClass:[NSArray class]]) {
        NSError *err = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                           code:OPTLYErrorTypesDatafileInvalid
                                       userInfo:@{NSLocalizedDescriptionKey : OPTLYErrorHandlerMessagesProjectConfigInvalidAudienceCondition}];
        if (error && err) {
            *error = err;
        }
        return nil;
    }
    
    if ([OPTLYAudienceBaseCondition isBaseConditionJSON:jsonArray[1]]) { //base case condition
        
        // generate all base conditions
        NSMutableArray<OPTLYCondition> *conditions = (NSMutableArray<OPTLYCondition> *)[[NSMutableArray alloc] initWithCapacity:(jsonArray.count - 1)];
        for (int i = 1; i < jsonArray.count; i++) {
            NSString *audienceId = jsonArray[i];
            OPTLYAudienceBaseCondition *condition = [OPTLYAudienceBaseCondition new];
            condition.audienceId = audienceId;
            [conditions addObject:condition];
        }
        
        // return an (And/Or/Not) Condition handling the base conditions
        NSObject<OPTLYCondition> *condition = [OPTLYCondition createConditionInstanceOfClass:jsonArray[0]
                                                                              withConditions:conditions];
        return (NSArray<OPTLYCondition> *)@[condition];
    }
    else {
        
        // further condition arrays to deserialize
        NSMutableArray<OPTLYCondition> *subConditions = (NSMutableArray<OPTLYCondition> *)[[NSMutableArray alloc] initWithCapacity:(jsonArray.count - 1)];
        for (int i = 1; i < jsonArray.count; i++) {
            NSError *err = nil;
            NSArray *deserializedJsonObject = [OPTLYCondition deserializeAudienceConditionsJSONArray:jsonArray[i] error:&err];
            
            if (err) {
                *error = err;
                return nil;
            }
            
            if (deserializedJsonObject != nil) {
                [subConditions addObjectsFromArray:deserializedJsonObject];
            }
        }
        NSObject<OPTLYCondition> *condition = [OPTLYCondition createConditionInstanceOfClass:jsonArray[0]
                                                                              withConditions:subConditions];
        return (NSArray<OPTLYCondition> *)@[condition];
    }
}

+ (NSObject<OPTLYCondition> *)createConditionInstanceOfClass:(NSString *)conditionClass withConditions:(NSArray<OPTLYCondition> *)conditions {
    if ([conditionClass isEqualToString:OPTLYDatafileKeysAndCondition]) {
        OPTLYAndCondition *andCondition = [[OPTLYAndCondition alloc] init];
        andCondition.subConditions = conditions;
        return andCondition;
    }
    else if ([conditionClass isEqualToString:OPTLYDatafileKeysOrCondition]) {
        OPTLYOrCondition *orCondition = [[OPTLYOrCondition alloc] init];
        orCondition.subConditions = conditions;
        return orCondition;
    }
    else if ([conditionClass isEqualToString:OPTLYDatafileKeysNotCondition]) {
        OPTLYNotCondition *notCondition = [[OPTLYNotCondition alloc] init];
        notCondition.subCondition = conditions[0];
        return notCondition;
    }
    else {
        NSString *exceptionDescription = [NSString stringWithFormat:@"Condition Class `%@` is not a recognized Optimizely Condition Class", conditionClass];
        NSException *exception = [[NSException alloc] initWithName:@"Condition Class Exception"
                                                            reason:@"Unrecognized Condition Class"
                                                          userInfo:@{OPTLYErrorHandlerMessagesDataFileInvalid : exceptionDescription}];
        @throw exception;
    }
    return nil;
}

@end

@implementation OPTLYAndCondition

- (nullable NSNumber *)evaluateConditionsWithAttributes:(NSDictionary<NSString *, NSObject *> *)attributes projectConfig:(nullable OPTLYProjectConfig *)config {
    // According to the matrix:
    // false and true is false
    // false and null is false
    // true and null is null.
    // true and false is false
    // true and true is true
    // null and null is null
    BOOL foundNull = false;
    for (NSObject<OPTLYCondition> *condition in self.subConditions) {
        // if any of our sub conditions are false or null
        NSNumber * result = [NSNumber new];
        result = [condition evaluateConditionsWithAttributes:attributes projectConfig:config];
        
        if (result == NULL) {
            foundNull = true;
        }
        else if ([result boolValue] == false) {
            // short circuit and return false
            return [NSNumber numberWithBool:false];
        }
    }
    //if found null condition, return null
    if (foundNull) {
        return NULL;
    }
    
    // if all sub conditions are true, return true.
    return [NSNumber numberWithBool:true];
}

@end

@implementation OPTLYOrCondition

- (nullable NSNumber *)evaluateConditionsWithAttributes:(NSDictionary<NSString *, NSObject *> *)attributes projectConfig:(nullable OPTLYProjectConfig *)config {
    // According to the matrix:
    // true returns true
    // false or null is null
    // false or false is false
    // null or null is null
    BOOL foundNull = false;
    for (NSObject<OPTLYCondition> *condition in self.subConditions) {
        NSNumber * result = [NSNumber new];
        result = [condition evaluateConditionsWithAttributes:attributes projectConfig:config];
        if (result == NULL) {
            foundNull = true;
        }
        else if ([result boolValue] == true) {
            // if any of our sub conditions are true
            // short circuit and return true
            return [NSNumber numberWithBool:true];
        }
    }
    //if found null condition, return null
    if (foundNull) {
        return NULL;
    }
    
    // if all of the sub conditions are false, return false
    return [NSNumber numberWithBool:false];
}

@end

@implementation OPTLYNotCondition

- (nullable NSNumber *)evaluateConditionsWithAttributes:(NSDictionary<NSString *, NSObject *> *)attributes projectConfig:(nullable OPTLYProjectConfig *)config {
    // return the negative of the subcondition
    NSNumber * result = [NSNumber new];
    result = [self.subCondition evaluateConditionsWithAttributes:attributes projectConfig:config];
    if (result == NULL) {
        return NULL;
    }
    return [NSNumber numberWithBool:![result boolValue]];
}

@end
