	//  Copyright (c) 2017 Heartland Payment Systems. All rights reserved.

#import "HpsHeartSipDevice.h"
#import "HpsTerminalUtilities.h"
#import "HpsTerminalEnums.h"
#import "HpsHeartSipTcpInterface.h"
#define RESET_REQUEST @"<SIP><Version>1.0</Version><ECRId>1004</ECRId><Request>Reset</Request></SIP>"
#define REBOOT_REQUEST @"<SIP><Version>1.0</Version><ECRId>1004</ECRId><Request>Reboot</Request></SIP>"
#define CLOSELANE_REQUEST @"<SIP><Version>1.0</Version><ECRId>1004</ECRId><Request>LaneClose</Request></SIP>"
#define OPENLANE_REQUEST @"<SIP><Version>1.0</Version><ECRId>1004</ECRId><Request>LaneOpen</Request></SIP>"
#define BATCHCLOSE_REQUEST @"<SIP><Version>1.0</Version><ECRId>1004</ECRId><Request>CloseBatch</Request></SIP>"
	//#define DISABLE_HOST_RESPONSE_BEEP @""
#define INITIALIZE_REQUEST @"<SIP><Version>1.0</Version><ECRId>1004</ECRId><Request>GetAppInfoReport</Request></SIP>"

#import "NSObject+ObjectMap.h"

@implementation HpsHeartSipDevice
{

}
- (instancetype) initWithConfig:(HpsConnectionConfig*)config
{
	if((self = [super init]))
		{
		self.config = config;
		errorDomain = [HpsCommon sharedInstance].hpsErrorDomain;
		switch ((int)self.config.connectionMode) {

			case HpsConnectionModes_TCP_IP:
			{
			self.interface = [[HpsHeartSipTcpInterface alloc] initWithConfig:config];
			format = HeartSIP;
			break;
			}
			case HpsConnectionModes_HTTP:
			{
			format = Visa2nd;
			@throw [NSException exceptionWithName:@"HpsHeartSipException" reason:@"Connection Method not available for HeartSIP devices" userInfo:nil];
			break;
			}
			default:
			{
			format = Visa2nd;
			@throw [NSException exceptionWithName:@"HpsHeartSipException" reason:@"Connection Method not available for HeartSIP devices" userInfo:nil];
			}
				break;
		}

		}
	return self;
}

	//  Admin

- (void) cancel:(void(^)(id<IHPSDeviceResponse> payload))responseBlock{
	[self reset:^(id<IHPSDeviceResponse> payload, NSError *error)
	 {
		if (error)
			{
			responseBlock(nil);
			}else {
				responseBlock(payload);
			}
	 }];
}

- (void) disableHostResponseBeep:(void(^)(id <IInitializeResponse>, NSError*))responseBlock{
}

- (void) initialize:(void(^)(id <IInitializeResponse>, NSError*))responseBlock{
	id<IHPSDeviceMessage> request	= [HpsTerminalUtilities	BuildRequest:INITIALIZE_REQUEST withFormat:format];
	NSLog(@"Step 2");
	[self.interface send:request andResponseBlock:^(NSData *data, NSError *error) {
		if (error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				NSLog(@"Step 4 with Error");

				responseBlock(nil, error);
			});
		}else{
			NSLog(@"Step 4 without Error");

				//done
			NSString *dataview = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
			NSLog(@"response xml = \n  : %@", dataview);
			HpsHeartSipInitializeResponse *response;
			@try {
					//parse data

				response = [[HpsHeartSipInitializeResponse alloc]initWithHeartSipInitializeResponse:data withParameters:nil];
				dispatch_async(dispatch_get_main_queue(), ^{
					responseBlock(response, nil);
				});
			} @catch (NSException *exception) {
				NSLog(@"anurag exception =%@",exception);
				NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [exception description]};
				NSError *error = [NSError errorWithDomain:self->errorDomain
													 code:CocoaError
												 userInfo:userInfo];

				dispatch_async(dispatch_get_main_queue(), ^{
					responseBlock(nil, error);
				});
			}
		}
	}];
}

- (void) openLane:(void(^)(id <IHPSDeviceResponse>, NSError*))responseBlock{
	id<IHPSDeviceMessage> request	= [HpsTerminalUtilities	BuildRequest:OPENLANE_REQUEST withFormat:format  ];
	[self.interface send:request andResponseBlock:^(NSData *data, NSError *error) {
		if (error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				responseBlock(nil, error);
			});
		}else{
				//done
			NSString *dataview = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
			NSLog(@"response xml = \n  : %@", dataview);
			HpsHeartSipDeviceResponse *response;
			@try {
					//parse data

				response = [[HpsHeartSipDeviceResponse alloc]initWithHeartSipDeviceResponse:data withParameters:nil];
					//response = [[HpsHpsHeartSipDeviceResponse alloc] initWithMessageID:A27_RSP_REBOOT andBuffer:data];
				dispatch_async(dispatch_get_main_queue(), ^{
					responseBlock(response, nil);
				});
			} @catch (NSException *exception) {
				NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [exception description]};
				NSError *error = [NSError errorWithDomain:self->errorDomain
													 code:CocoaError
												 userInfo:userInfo];

				dispatch_async(dispatch_get_main_queue(), ^{
					responseBlock(nil, error);
				});
			}
		}
	}];
}

- (void) closeLane:(void(^)(id <IHPSDeviceResponse>, NSError*))responseBlock{
	id<IHPSDeviceMessage> request	= [HpsTerminalUtilities	BuildRequest:CLOSELANE_REQUEST withFormat:format  ];
	[self.interface send:request andResponseBlock:^(NSData *data, NSError *error) {
		if (error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				responseBlock(nil, error);
			});
		}else{
				//done
			NSString *dataview = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
			NSLog(@"response xml = \n  : %@", dataview);
			HpsHeartSipDeviceResponse *response;
			@try {
					//parse data

				response = [[HpsHeartSipDeviceResponse alloc]initWithHeartSipDeviceResponse:data withParameters:nil];

				dispatch_async(dispatch_get_main_queue(), ^{
					responseBlock(response, nil);
				});
			} @catch (NSException *exception) {
				NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [exception description]};
				NSError *error = [NSError errorWithDomain:self->errorDomain
													 code:CocoaError
												 userInfo:userInfo];

				dispatch_async(dispatch_get_main_queue(), ^{
					responseBlock(nil, error);
				});
			}
		}
	}];
}

- (void) reboot:(void(^)(id <IHPSDeviceResponse>, NSError*))responseBlock{
	id<IHPSDeviceMessage> request	= [HpsTerminalUtilities	BuildRequest:REBOOT_REQUEST withFormat:format];

	[self.interface send:request andResponseBlock:^(NSData *data, NSError *error) {
		if (error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				responseBlock(nil, error);
			});
		}else{
				//done
			NSString *dataview = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
			NSLog(@"response xml = \n  : %@", dataview);
			HpsHeartSipDeviceResponse *response;
			@try {
					//parse data

				response = [[HpsHeartSipDeviceResponse alloc]initWithHeartSipDeviceResponse:data withParameters:nil];

				dispatch_async(dispatch_get_main_queue(), ^{
					responseBlock(response, nil);
				});
			} @catch (NSException *exception) {
				NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [exception description]};
				NSError *error = [NSError errorWithDomain:self->errorDomain
													 code:CocoaError
												 userInfo:userInfo];

				dispatch_async(dispatch_get_main_queue(), ^{
					responseBlock(nil, error);
				});
			}
		}
	}];

}

- (void) reset:(void(^)(id <IHPSDeviceResponse>, NSError*))responseBlock{
	id<IHPSDeviceMessage> request	= [HpsTerminalUtilities	BuildRequest:RESET_REQUEST withFormat:format];

	[self.interface send:request andResponseBlock:^(NSData *data, NSError *error) {
		if (error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				responseBlock(nil, error);
			});
		}else{
				//done
			NSString *dataview = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
			NSLog(@"response xml = \n  : %@", dataview);
			HpsHeartSipDeviceResponse *response;
			@try {
					//parse data
				response = [[HpsHeartSipDeviceResponse alloc]initWithHeartSipDeviceResponse:data withParameters:nil];

				dispatch_async(dispatch_get_main_queue(), ^{
					responseBlock(response, nil);
				});
			} @catch (NSException *exception) {
				NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [exception description]};
				NSError *error = [NSError errorWithDomain:self->errorDomain
													 code:CocoaError
												 userInfo:userInfo];

				dispatch_async(dispatch_get_main_queue(), ^{
					responseBlock(nil, error);
				});
			}
		}
	}];

}

- (void) batchClose:(void(^)(id <IBatchCloseResponse> , NSError*))responseBlock{

	id<IHPSDeviceMessage> request	= [HpsTerminalUtilities	BuildRequest:BATCHCLOSE_REQUEST withFormat:format];

	[self.interface send:request andResponseBlock:^(NSData *data, NSError *error) {
		if (error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				responseBlock(nil, error);
			});
		}else{
				//done
				//NSString *dataview = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
				//NSLog(@"response xml = \n  : %@", dataview);
			HpsHeartSipBatchResponse *response;
			@try {
					//parse data

				response = [[HpsHeartSipBatchResponse alloc]initWithHeartSipBatchResponse:data withParameters:nil];
				dispatch_async(dispatch_get_main_queue(), ^{
					responseBlock(response, nil);
				});
			} @catch (NSException *exception) {
				NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [exception description]};
				NSError *error = [NSError errorWithDomain:self->errorDomain
													 code:CocoaError
												 userInfo:userInfo];

				dispatch_async(dispatch_get_main_queue(), ^{
					responseBlock(nil, error);
				});
			}
		}
	}];
}

#pragma mark -
#pragma mark Transactions

-(void)processTransactionWithRequest:(HpsHeartSipRequest*)HpsHeartSipRequest withResponseBlock:(void(^)(id <IHPSDeviceResponse>, NSError*))responseBlock
{
	id<IHPSDeviceMessage> request	= [HpsTerminalUtilities	BuildRequest:HpsHeartSipRequest.XMLString withFormat:format];

	[self.interface send:request andResponseBlock:^(NSData *data, NSError *error) {
		if (error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				responseBlock(nil, error);
			});
		}else{
				//done
			NSString *dataview = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
			NSLog(@"response xml = \n  : %@", dataview);
			HpsHeartSipDeviceResponse *response;
			@try {
					//parse data

				response = [[HpsHeartSipDeviceResponse alloc]initWithHeartSipDeviceResponse:data withParameters:nil];

				dispatch_async(dispatch_get_main_queue(), ^{
					responseBlock(response, nil);
				});
			} @catch (NSException *exception) {
				NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [exception description]};
				NSError *error = [NSError errorWithDomain:self->errorDomain
													 code:CocoaError
												 userInfo:userInfo];

				dispatch_async(dispatch_get_main_queue(), ^{
					responseBlock(nil, error);
				});
			}
		}
	}];
}

#pragma mark -
#pragma mark Private Methods

-(id)getValueOfObject:(id)value{

	return value == NULL?(id)@"":value;
}

-(void)printRecipt:(HpsTerminalResponse*)response
{
	NSMutableString *recipt = [[NSMutableString alloc]init];

	[recipt appendString:[NSString stringWithFormat:@"x_trans_type=%@",[self getValueOfObject:response.transactionType]]] ;
	[recipt appendString:[NSString stringWithFormat:@"&x_application_label=%@",[self getValueOfObject:response.applicationName]]];
	if (response.maskedCardNumber)[recipt appendString:[NSString stringWithFormat: @"&x_masked_card=************%@",response.maskedCardNumber]];
	else [recipt appendString:[NSString stringWithFormat: @"&x_masked_card="]];
	[recipt appendString:[NSString stringWithFormat:@"&x_application_id=%@",[self getValueOfObject:response.applicationId]]];

	switch (response.applicationCryptogramType)
	{
		case TC:
		[recipt appendString:[NSString stringWithFormat:@"&x_cryptogram_type=TC"]];
		break;
		case ARQC:
		[recipt appendString:[NSString stringWithFormat:@"&x_cryptogram_type=ARQC"]];
		break;
		default:
		[recipt appendString:[NSString stringWithFormat:@"&x_cryptogram_type="]];
		break;
	}

	[recipt appendString:[NSString stringWithFormat:@"&x_application_cryptogram=%@",[self getValueOfObject:response.applicationCrytptogram]]];
	[recipt appendString:[NSString stringWithFormat:@"&x_expiration_date=%@",[self getValueOfObject:response.expirationDate]]];
	[recipt appendString:[NSString stringWithFormat:@"&x_entry_method=%@",[HpsTerminalEnums entryModeToString:response.entryMode]]];
	[recipt appendString:[NSString stringWithFormat:@"&x_approval=%@",[self getValueOfObject:response.approvalCode]]];
	[recipt appendString:[NSString stringWithFormat:@"&x_transaction_amount=%@",response.transactionAmount]];
	[recipt appendString:[NSString stringWithFormat:@"&x_amount_due=%@",[self getValueOfObject:response.amountDue]]];
	[recipt appendString:[NSString stringWithFormat:@"&x_customer_verification_method=%@",[self getValueOfObject:response.cardHolderVerificationMethod]]];
	[recipt appendString:[NSString stringWithFormat:@"&x_signature_status=%@",[self getValueOfObject:response.signatureStatus]]];
	[recipt appendString:[NSString stringWithFormat:@"&x_response_text=%@",[self getValueOfObject:response.responseText]]];
	
	NSLog(@"Recipt = %@", recipt);
}


@end
