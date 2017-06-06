/****************************************************************************
 * Copyright 2016, Optimizely, Inc. and contributors                        *
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
#ifdef UNIVERSAL
    #import "JSONModelLib.h"
#else
    #import <JSONModel/JSONModelLib.h>
#endif

// Model object for a view.

@protocol OPTLYEventFeature;

@protocol OPTLYEventView
@end

@interface OPTLYEventView : JSONModel

// The ID of the view containing this impression.
@property (nonatomic, strong, nullable) NSString<Optional> *viewId;
// The timestamp when the containing view was activated.
@property (nonatomic, strong, nullable) NSNumber<Optional> *activatedTimestamp;
// Features attached to the view.
@property (nonatomic, strong, nullable) NSArray<OPTLYEventFeature, Optional> *viewFeatures;

@end
