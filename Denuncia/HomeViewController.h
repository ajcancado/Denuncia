//
//  HomeViewController.h
//  Denuncia
//
//  Created by Arthur Junqueira Cançado on 08/10/13.
//  Copyright (c) 2013 Arthur Developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface HomeViewController : UIViewController<CLLocationManagerDelegate>

- (IBAction)denunciarAlcool:(id)sender;

- (IBAction)denunciarDrogas:(id)sender;

- (IBAction)denunciar:(id)sender;


@end
