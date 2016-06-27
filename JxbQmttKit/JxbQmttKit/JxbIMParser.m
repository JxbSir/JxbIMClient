
#import "JxbIMParser.h"
#import "JxbIMRuntimeHelper.h"

@implementation JxbIMParser

@synthesize objectId;
static NSString *idPropertyName = @"id";
static NSString *idPropertyNameOnObject = @"objectId";

Class nsDictionaryClass;
Class nsArrayClass;

+ (id)objectFromDictionary:(NSDictionary*)dictionary {
    id item = [[self alloc] initWithDictionary:dictionary];
    return item;
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
	if (!nsDictionaryClass) nsDictionaryClass = [NSDictionary class];
	if (!nsArrayClass) nsArrayClass = [NSArray class];
	
	if ((self = [super init])) {
		for (NSString *key in [JxbIMRuntimeHelper propertyNames:[self class]]) {

			id value = [dictionary valueForKey:key];
			
			if (value == [NSNull null] || value == nil) {
                continue;
            }
            
            if ([JxbIMRuntimeHelper isPropertyReadOnly:[self class] propertyName:key]) {
                continue;
            }
			
			// handle dictionary
			if ([value isKindOfClass:nsDictionaryClass]) {
				Class klass = [JxbIMRuntimeHelper propertyClassForPropertyName:key ofClass:[self class]];
				value = [[klass alloc] initWithDictionary:value];
			}
			// handle array
			else if ([value isKindOfClass:nsArrayClass]) {
				
				NSMutableArray *childObjects = [NSMutableArray arrayWithCapacity:[(NSArray*)value count]];
				
				for (id child in value) {
                    if ([[child class] isSubclassOfClass:nsDictionaryClass]) {
                        SEL sel = NSSelectorFromString([NSString stringWithFormat:@"%@_class", key]);
                        BOOL bImplemented = [[self class] respondsToSelector:sel];
#if DEBUG
                        NSAssert(bImplemented, @"you know, japanese is not a human");
#endif
                        if (!bImplemented) {
                            continue;
                        }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                        Class arrayItemType = [[self class] performSelector:sel];
#pragma clang diagnostic pop
                        if ([arrayItemType isSubclassOfClass:[NSDictionary class]]) {
                            [childObjects addObject:child];
                        } else if ([arrayItemType isSubclassOfClass:[JxbIMParser class]]) {
                            JxbIMParser *childDTO = [[arrayItemType alloc] initWithDictionary:child];
                            [childObjects addObject:childDTO];
                        }
					} else {
						[childObjects addObject:child];
					}
				}
				
				value = childObjects;
			}
            else if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
                //add by peter
                Class des_class = [JxbIMRuntimeHelper propertyClassForPropertyName:key ofClass:[self class]];
                BOOL isSame = [value isKindOfClass:des_class];
                if (!isSame) {
                    if (![des_class isSubclassOfClass:[JxbIMParser class]]) {
                        BOOL bConvertSuccess = NO;
                        if ([value isKindOfClass:[NSNumber class]]) {
                            if (des_class == [NSString class]) {
                                bConvertSuccess = YES;
                                value = [NSString stringWithFormat:@"%@",value];
                            }
                        }
                        else if ([value isKindOfClass:[NSString class]]) {
                            if (des_class == [NSNumber class]) {
                                bConvertSuccess = YES;
                                value = [NSNumber numberWithInteger:((NSString*)value).integerValue];
                            }
                        }
                        
                        //对应类型转换失败
                        if (!bConvertSuccess) {
                            continue;
                        }
                    }
                    else {
                        //value与属性的类型无法匹配
                        continue;
                    }
                }
            }
            
			[self setValue:value forKey:key];
		}
		
		id objectIdValue;
		if ((objectIdValue = [dictionary objectForKey:idPropertyName]) && objectIdValue != [NSNull null]) {
			if (![objectIdValue isKindOfClass:[NSString class]]) {
				objectIdValue = [NSString stringWithFormat:@"%@", objectIdValue];
			}
			[self setValue:objectIdValue forKey:idPropertyNameOnObject];
		}
	}
	return self;	
}

- (void)dealloc {
	self.objectId = nil;
	
//	for (NSString *key in [JxbIMRuntimeHelper propertyNames:[self class]]) {
//		//[self setValue:nil forKey:key];
//	}
	
}

- (void)encodeWithCoder:(NSCoder*)encoder {
	[encoder encodeObject:self.objectId forKey:idPropertyNameOnObject];
	for (NSString *key in [JxbIMRuntimeHelper propertyNames:[self class]]) {
		[encoder encodeObject:[self valueForKey:key] forKey:key];
	}
}

- (id)initWithCoder:(NSCoder *)decoder {
	if ((self = [super init])) {
		[self setValue:[decoder decodeObjectForKey:idPropertyNameOnObject] forKey:idPropertyNameOnObject];
		
		for (NSString *key in [JxbIMRuntimeHelper propertyNames:[self class]]) {
            if ([JxbIMRuntimeHelper isPropertyReadOnly:[self class] propertyName:key]) {
                continue;
            }
			id value = [decoder decodeObjectForKey:key];
			if (value != [NSNull null] && value != nil) {
				[self setValue:value forKey:key];
			}
		}
	}
	return self;
}

- (NSMutableDictionary *)toDictionary {
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (self.objectId) {
        [dic setObject:self.objectId forKey:idPropertyName];
    }
	
	for (NSString *key in [JxbIMRuntimeHelper propertyNames:[self class]]) {
		id value = [self valueForKey:key];
        if (value && [value isKindOfClass:[JxbIMParser class]]) {
            [dic setObject:[value toDictionary] forKey:key];
        } else if (value && [value isKindOfClass:[NSArray class]] && ((NSArray*)value).count > 0) {
            id internalValue = [value objectAtIndex:0];
            if (internalValue && [internalValue isKindOfClass:[JxbIMParser class]]) {
                NSMutableArray *internalItems = [NSMutableArray array];
                for (id item in value) {
                    [internalItems addObject:[item toDictionary]];
                }
                [dic setObject:internalItems forKey:key];
            } else {
                [dic setObject:value forKey:key];
            }
        } else if (value != nil) {
            [dic setObject:value forKey:key];
        }
	}
    return dic;
}

- (NSString *)description {
    NSMutableDictionary *dic = [self toDictionary];
	
	return [NSString stringWithFormat:@"#<%@: id = %@ %@>", [self class], self.objectId, [dic description]];
}

- (BOOL)isEqual:(id)object {
	if (object == nil || ![object isKindOfClass:[JxbIMParser class]]) return NO;
	
	JxbIMParser *model = (JxbIMParser *)object;
	
	return [self.objectId isEqualToString:model.objectId];
}

@end
