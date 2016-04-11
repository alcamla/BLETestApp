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

#import <QuartzCore/QuartzCore.h>
#import "HeartRateViewController.h"

@implementation HeartRateViewController
@synthesize peripheral = _peripheral;
@synthesize pulseTimer;

#define PULSESCALE 1.2
#define PULSEDURATION 0.2
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    hrvalue = nil;
    heartView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)connectService:(CBService *)service
{
    _bpm=0;
    _peripheral=service.peripheral;
    hr_characteristic=nil;
    [_peripheral setDelegate:self];
    [_peripheral discoverCharacteristics:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"2A37"]] forService:service];

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
    
    if ( (hr_characteristic = [e nextObject]) ) {
        [peripheral setNotifyValue:YES forCharacteristic: hr_characteristic];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(error != nil)
        return;
    
    const uint8_t *reportData = [characteristic.value bytes];
    uint16_t bpm = 0;
    
    if ((reportData[0] & 0x01) == 0) 
    {
        /* uint8 bpm */
        bpm = reportData[1];
    } 
    else 
    {
        /* uint16 bpm */
        bpm = CFSwapInt16LittleToHost(*(uint16_t *)(&reportData[1]));
    }
    uint16_t oldBpm=_bpm;
    _bpm=bpm;
    hrvalue.text=[NSString stringWithFormat:@"%d",_bpm];
    if (oldBpm == 0) 
    {
        [self pulse];
        self.pulseTimer = [NSTimer scheduledTimerWithTimeInterval:(60. / _bpm) target:self selector:@selector(pulse) userInfo:nil repeats:NO];
    }
}
/*
 Update pulse UI
 */
- (void) pulse 
{
    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    
    pulseAnimation.toValue = [NSNumber numberWithFloat:PULSESCALE];
    pulseAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    
    pulseAnimation.duration = PULSEDURATION;
    pulseAnimation.repeatCount = 1;
    pulseAnimation.autoreverses = YES;
    pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    [[heartView layer] addAnimation:pulseAnimation forKey:@"scale"];
    
    self.pulseTimer = [NSTimer scheduledTimerWithTimeInterval:(60. / _bpm) target:self selector:@selector(pulse) userInfo:nil repeats:NO];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(error)
    {
        //handle error
        hr_characteristic=nil;
    }
    //[_peripheral readValueForCharacteristic:characteristic];
}
@end
