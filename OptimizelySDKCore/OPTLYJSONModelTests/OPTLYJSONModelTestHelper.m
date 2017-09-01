/****************************************************************************
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

#import "OPTLYJSONModelTestHelper.h"

@implementation OPTLYJSONModelTestHelper
+ (NSData *)dataForResource:(NSString *)name ofType:(NSString *)ext {
    NSString *filePath =[[NSBundle bundleForClass:[self class]] pathForResource:name ofType:ext];
    NSError *error;
    NSData *answer = [NSData dataWithContentsOfFile:filePath options:0 error:&error];
    if (error) {
        NSLog(@"Error reading file: %@", error.localizedDescription);
    }
    return answer;
}
+ (NSString *)stringForResource:(NSString *)name ofType:(NSString *)ext {
    NSString *filePath =[[NSBundle bundleForClass:[self class]] pathForResource:name ofType:ext];
    NSError *error;
    NSString *answer = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"Error reading file: %@", error.localizedDescription);
    }
    return answer;
}
@end
