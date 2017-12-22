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

#define StringOrEmpty(A)  ({ __typeof__(A) __a = (A); __a ? __a : @""; })

#define isEmptyString(A)  ({ !(A && [A respondsToSelector:@selector(isEqualToString:)] && ![(NSString *)A isEqualToString:@""]); })

#define isEmptyArray(A)  ({ !(A && [A respondsToSelector:@selector(count)] && [(NSArray *)A count] > 0); })
