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


#import "ServiceViewController.h"
#import "HeartRateViewController.h"
#import "CRViewController.h"

@implementation ServiceViewController
@synthesize peripheral = _peripheral;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _peripheral=nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    serviceList = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/**
 Indicates the connected peripheral, this connection was stablished in the presenting view controller, which holds the central manager. This method start the search for the given services.
*/
- (void)connectPeripheral:(CBPeripheral *)per
{
    _peripheral=per;
    
    NSArray *keys = [NSArray arrayWithObjects:
                     [CBUUID UUIDWithString:@"0bd51666-e7cb-469b-8e4d-2742f1ba77cc"], 
                     [CBUUID UUIDWithString:@"180D"], 
                     nil];
    NSArray *objects = [NSArray arrayWithObjects:
                        @"BG Cable Replacement",
                        @"Heart Rate", 
                        nil];
    
    serviceNames = [NSDictionary dictionaryWithObjects:objects forKeys:keys];

    [_peripheral setDelegate:self];
    [_peripheral discoverServices:[serviceNames allKeys]];
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_peripheral==nil)
        return 0;
    return [_peripheral.services count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"foundService";
    
    UITableViewCell *cell = [serviceList dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell.
    CBService*pcell=[_peripheral.services objectAtIndex: [indexPath row]];
    // Get human readable description of uuid
    cell.textLabel.text = [self serviceToString :pcell.UUID ];
    
    return cell;
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    [serviceList reloadData];

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBService* ser=[_peripheral.services objectAtIndex:[indexPath row]];
    if([ser.UUID isEqual:[CBUUID UUIDWithString:@"0bd51666-e7cb-469b-8e4d-2742f1ba77cc"]])
    {
        CRViewController * cr=[self.storyboard instantiateViewControllerWithIdentifier:@"cablerep"];
        [cr connectService:ser];
        [self.navigationController pushViewController:cr animated:YES];

    }else{
        HeartRateViewController * hr= [self.storyboard instantiateViewControllerWithIdentifier:@"heartrate"];
        [hr connectService:ser];
        [self.navigationController pushViewController:hr animated:YES];

    }
}

- (NSString*) serviceToString: (CBUUID*) uuid
{
    NSString *rv=[serviceNames objectForKey:uuid];

    //no text found, return hex string
    if (rv == nil)
        return [uuid.data description];
    
    return rv;
}

@end
