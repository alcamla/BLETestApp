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


#import "bletestViewController.h"
#import "PeripheralCell.h"
#import "ServiceViewController.h"

@implementation bletestViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    connected_peripheral=nil;
    //scanSwitch.on=NO;
    peripherals = [NSMutableArray arrayWithCapacity:1];
}

- (void)viewDidUnload
{
    scanResult = nil;
    managerState = nil;
    scanSwitch = nil;
    scanResult = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    //disconnect peripheral if connected
    if(connected_peripheral!=nil)
        [manager cancelPeripheralConnection:connected_peripheral];
    connected_peripheral=nil;
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}


- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    char * managerStrings[]={
        "Unknown",
        "Resetting",
        "Unsupported",
        "Unauthorized",
        "PoweredOff",
        "PoweredOn"
    };
    
    NSString * newstring=[NSString stringWithFormat:@"Manager State: %s",managerStrings[central.state]];
    managerState.text=newstring;
}

- (IBAction)scannerState:(id)sender {
    if(scanSwitch.on)
    {
        [peripherals removeAllObjects];
        [scanResult reloadData];
        NSArray * services=[NSArray arrayWithObjects:
                            [CBUUID UUIDWithString:@"180D"],
                            [CBUUID UUIDWithString:@"0bd51666-e7cb-469b-8e4d-2742f1ba77cc"],
                            nil
                            ];
        [manager scanForPeripheralsWithServices:services options: [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBCentralManagerScanOptionAllowDuplicatesKey]];
    }else{
        [manager stopScan];
    }
    
}

/**
 Called when scanner finds device
 First checks if it exists, if not then insert new device
 */
- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    BOOL (^test)(id obj, NSUInteger idx, BOOL *stop);
    test = ^ (id obj, NSUInteger idx, BOOL *stop) {
        if([[[obj peripheral] name] compare:peripheral.name] == NSOrderedSame)
            return YES;
        return NO;
    };
    
    PeripheralCell* cell;
    NSUInteger t=[peripherals indexOfObjectPassingTest:test];
    if(t!= NSNotFound)
    {
        // The found peripheral already exists in the peripherals array. Update the related object in the array, and update the table at the given index.
        cell=[peripherals objectAtIndex:t];
        cell.peripheral=peripheral;
        cell.rssi=RSSI;
        [scanResult reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:t inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }else{
        // The found peripheral does not exist yet. Add it to the peripherals array. Add the cell to the  scanResult UITableView.
        cell=[[PeripheralCell alloc] init];
        [peripherals addObject: cell];
        cell.peripheral=peripheral;
        cell.rssi=RSSI;
        [scanResult insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[peripherals count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(peripherals==nil)
        return 0;
    return [peripherals count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"foundDevice";
    
    UITableViewCell *cell = [scanResult dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell.
    PeripheralCell*pcell=[peripherals objectAtIndex: [indexPath row]];
    cell.textLabel.text = [pcell.peripheral name];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"RSSI %d",[pcell.rssi intValue]];
                       //self.colorNames objectAtIndex: [indexPath row]];
    
    return cell;
}

/*
 user selected row
 stop scanner
 connect peripheral for service search
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PeripheralCell* per=[peripherals objectAtIndex:[indexPath row]];
    scanSwitch.on=false;
    // do not search for other peripherals
    [manager stopScan];
    // Connect to the selected peripheral
    [manager connectPeripheral:per.peripheral options:nil];
}

/*
 connected to peripheral
 Show service search view
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    ServiceViewController * hr= [self.storyboard instantiateViewControllerWithIdentifier:@"services"];
    connected_peripheral = peripheral;
    [hr connectPeripheral:peripheral];
    [self.navigationController pushViewController:hr animated:YES];
    
}
@end
