//
//  OPTLYVariable.h
//  OptimizelySDKCore
//
//  Created by Haley Bash on 10/10/16.
//  Copyright © 2016 Optimizely. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModelLib.h>

/**
 * This class is a representation of an Optimizely live variable.
 */

@protocol OPTLYVariable
@end

@interface OPTLYVariable : JSONModel
    
/// The variable's ID.
@property (nonatomic, strong) NSString *variableId;
/// The variable's Key.
@property (nonatomic, strong) NSString *variableKey;
/// The variable's type.
@property (nonatomic, strong) NSString *type;
/// The variable's default value.
@property (nonatomic, strong) NSString *value;
/// The variable's status.
@property (nonatomic, strong) NSString *status;

@end
