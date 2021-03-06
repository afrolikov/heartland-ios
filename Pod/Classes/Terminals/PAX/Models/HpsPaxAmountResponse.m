//  Copyright (c) 2016 Heartland Payment Systems. All rights reserved.

#import "HpsPaxAmountResponse.h"

@implementation HpsPaxAmountResponse
- (id)initWithBinaryReader: (HpsBinaryDataScanner*)br {
    self = [super init];
    if (!self) return nil;
    
    NSString *values = [br readStringUntilDelimiter:HpsControlCodes_FS];
    NSArray *items = [values componentsSeparatedByString:[HpsTerminalEnums controlCodeString:HpsControlCodes_US]];
    
    int i = 0;
    for (NSNumber* value in items) {
        switch (i) {
            case 0:
                self.approvedAmount = [value doubleValue];
                break;
            case 1:
                self.amountDue = [value doubleValue];
                break;
            case 2:
                self.tipAmount = [value doubleValue];
                break;
            case 3:
                self.cashBackAmount = [value doubleValue];
                break;
            case 4:
                self.merchantFee = [value doubleValue];
                break;
            case 5:
                self.taxAmount = [value doubleValue];
                break;
            case 6:
                self.balance1 = [value doubleValue];
                break;
            case 7:
                self.balance2 = [value doubleValue];
                break;
                
            default:
                break;
        }
        i++;
    }
    
    return self;
}

@end
