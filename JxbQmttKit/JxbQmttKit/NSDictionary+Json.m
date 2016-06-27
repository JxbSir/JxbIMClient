//
//  NSDictionary+Json
//

#import "NSDictionary+Json.h"


@implementation NSDictionary (JSON)

+ (id)dictionaryWithJSONData:(NSData *)inData error:(NSError **)outError {
    return [NSJSONSerialization JSONObjectWithData:inData options:0 error:outError];
}

+ (id)dictionaryWithJSONString:(NSString *)inJSON error:(NSError **)outError {
    NSData *theData = [inJSON dataUsingEncoding:NSUTF8StringEncoding];
    return([self dictionaryWithJSONData:theData error:outError]);
}

- (NSString*)toString {
    if (!self)
        return nil;
    NSData* data = [NSJSONSerialization dataWithJSONObject:self options:0 error:nil];
    if (!data)
        return nil;
    NSString* result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return result;
}



@end
