//
// Bluegiga’s Bluetooth Smart Demo Application SW for iPhone 4S
// This SW is showing how to iPhone 4S can interact with Bluegiga Bluetooth
// Smart components like BLE112.
// Contact: support@bluegiga.com.
//
// This is free software distributed under the terms of the MIT license reproduced below.
//
// Copyright (c) 2012, Bluegiga Technologies
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
//


#include <string.h>
#import "CRViewController.h"
#import <QuartzCore/CAAnimation.h>
#import <QuartzCore/CAMediaTimingFunction.h>

#define ARROWDURATION 0.4

@implementation CRViewController
@synthesize peripheral = _peripheral;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
- (void)viewDidUnload
{
    textRx = nil;
    arrowTx = nil;
    arrowRx = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)connectService:(CBService *)ser
{
    _peripheral=ser.peripheral;
    cr_characteristic=nil;
    [_peripheral setDelegate:self];
    
    [_peripheral discoverCharacteristics:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"e7add780-b042-4876-aae1-112855353cc1"]] forService:ser];
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if(error != nil)
    {
        //TODO: handle error
        return;
    }
    
    NSEnumerator *e = [service.characteristics objectEnumerator];
    
    if ( (cr_characteristic = [e nextObject]) ) {
        [peripheral setNotifyValue:YES forCharacteristic: cr_characteristic];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if(error != nil)
    {
        //TODO: handle error
        return;
    }
    
    NSEnumerator *e = [_peripheral.services objectEnumerator];
    CBService * service;
    
    while ( (service = [e nextObject]) ) {
        [_peripheral discoverCharacteristics:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"0bd51666-e7cb-469b-8e4d-2742f1ba77cc"]] forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(error != nil)
        return;
    
    
    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    
    pulseAnimation.toValue = [NSNumber numberWithInt:-157];
    pulseAnimation.fromValue = [NSNumber numberWithInt:0];
    
    pulseAnimation.duration = ARROWDURATION;
    pulseAnimation.repeatCount = 1;
    pulseAnimation.autoreverses = NO;
    pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    [[arrowRx layer] addAnimation:pulseAnimation forKey:nil];

    
    
    
    
    char buffer[32];
    int len=(int)characteristic.value.length;
    memcpy(buffer,[characteristic.value bytes],len);
    buffer[len]=0;
    textRx.text=[textRx.text stringByAppendingString:[NSString stringWithUTF8String:buffer]];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(error)
    {
        //handle error
        cr_characteristic=nil;
    }
    //[_peripheral readValueForCharacteristic:characteristic];
}

- (IBAction)textTx:(id)sender {
    //start animation on tx
    
    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    
    pulseAnimation.toValue = [NSNumber numberWithInt:157];
    pulseAnimation.fromValue = [NSNumber numberWithInt:0];
    
    pulseAnimation.duration = ARROWDURATION;
    pulseAnimation.repeatCount = 1;
    pulseAnimation.autoreverses = NO;
    pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    [[arrowTx layer] addAnimation:pulseAnimation forKey:nil];

    
    
    
    UITextField *tf=sender;
    const char *s=[tf.text UTF8String];
    NSData * data=[NSData dataWithBytes:s length:strlen(s)];
    [_peripheral writeValue:data forCharacteristic:cr_characteristic type:CBCharacteristicWriteWithResponse];
}

@end
