//
//  NSDictionary+Json
//  TouchCode
//


#import <Foundation/Foundation.h>

@interface NSDictionary (JSON)

+ (id)dictionaryWithJSONData:(NSData *)inData error:(NSError **)outError;
+ (id)dictionaryWithJSONString:(NSString *)inJSON error:(NSError **)outError;

- (NSString*)toString;

@end
