//
//  HomeViewController.m
//  Denuncia
//
//  Created by Arthur Junqueira Cançado on 08/10/13.
//  Copyright (c) 2013 Arthur Developer. All rights reserved.
//

#import "SBJson.h"
#import "Reachability.h"
#import "HomeViewController.h"
#import "DenunciaViewController.h"


@interface HomeViewController (){
    
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    
    NSString * endereco;
    double latitudeAtual, longitudeAtual;
    
}

@end

@implementation HomeViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    UIBarButtonItem *config = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:nil];
    
    self.navigationItem.rightBarButtonItem = config;

    geocoder = [[CLGeocoder alloc] init];
    locationManager = [[CLLocationManager alloc] init];

    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    //[locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)denunciarAlcool:(id)sender {
    
    //[self verificaConexao];
    
    
    NSString *post = [[NSString alloc] initWithFormat:@"tipoDeDenuncia=Alcool&endereco=%@&latitude=%.8f&longitude=%.8f",endereco,latitudeAtual,longitudeAtual];
    
    NSURL *url = [NSURL URLWithString:@"http://arthurdeveloper.com.br/app_denuncia/acesso/controle.php?tipo=anonima"];
    
    int envio = [self enviaPOST:post paraURL:url];
    
    if (envio)
        [[[UIAlertView alloc] initWithTitle:@"Obrigado" message:@"Dênuncia efetuada com sucesso." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show ];
    else
        [[[UIAlertView alloc] initWithTitle:@"Obrigado" message:@"Dênuncia nao efetuada." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show ];
    
}

- (IBAction)denunciarDrogas:(id)sender {
    
    NSString *post = [[NSString alloc] initWithFormat:@"tipoDeDenuncia=Drogas&endereco=%@&latitude=%.8f&longitude=%.8f",endereco,latitudeAtual,longitudeAtual];
    
    NSURL *url = [NSURL URLWithString:@"http://arthurdeveloper.com.br/app_denuncia/acesso/controle.php?tipo=anonima"];
    
    int envio = [self enviaPOST:post paraURL:url];
    
    if (envio)
        [[[UIAlertView alloc] initWithTitle:@"Obrigado" message:@"Dênuncia efetuada com sucesso." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    else
        [[[UIAlertView alloc] initWithTitle:@"Obrigado" message:@"Dênuncia nao efetuada." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

- (IBAction)denunciar:(id)sender {
    
    DenunciaViewController *denuncia = [[DenunciaViewController alloc] init];
    
    denuncia.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:denuncia];
    
    [self presentViewController:nav animated:YES completion:nil];
    
    
}

#pragma mark - Verifica conexão

-(NSString *)verificaConexao{
    
    NetworkStatus networkStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    
    if (networkStatus == NotReachable) {

        NSLog(@"desconectado");
        return @"desconectado";
        
        
    }
    
    NSLog(@"conectado");
    return @"conectado";
    
}

#pragma mark - Envio de Formulário

-(int)enviaPOST:(NSString *) post paraURL:(NSURL *) url{
    
    NSLog(@"PostData: %@",post);
    
    NSLog(@"Url: %@",url);
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *response = nil;
    NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSLog(@"Response code: %ld", (long)[response statusCode]);
    
    if ([response statusCode] >=200 && [response statusCode] <300)
    {
        NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
        NSLog(@"Response ==> %@", responseData);
        
        SBJsonParser *jsonParser = [SBJsonParser new];
        NSDictionary *jsonData = (NSDictionary *) [jsonParser objectWithString:responseData error:nil];
        NSLog(@"%@",jsonData);
        NSInteger success = [(NSNumber *) [jsonData objectForKey:@"success"] integerValue];
        NSLog(@"%ld",(long)success);
        
        if(success == 1)
            return 1;
        else
            return 0;
        
        
    } else {
        
        if (error) NSLog(@"Error: %@", error);
        
        return 0;
        
    }

}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show ];

}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        latitudeAtual = currentLocation.coordinate.latitude;
        longitudeAtual = currentLocation.coordinate.longitude;
    }
    
    // Reverse Geocoding
    NSLog(@"Resolving the Address");
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            endereco = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
                                 placemark.subThoroughfare, placemark.thoroughfare,
                                 placemark.postalCode, placemark.locality,
                                 placemark.administrativeArea,
                                 placemark.country];
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
    
}

@end
