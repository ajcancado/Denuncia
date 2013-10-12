//
//  DenunciaViewController.m
//  Denuncia
//
//  Created by Arthur Junqueira Cançado on 09/10/13.
//  Copyright (c) 2013 Arthur Developer. All rights reserved.
//

#import "SBJson.h"
#import "DenunciaViewController.h"

@interface DenunciaViewController (){
    
    NSArray * tiposDeDroga;
    NSArray * tiposDeDenuncia;
    
    NSData * imagemDaDenuncia;
    
}

@end

@implementation DenunciaViewController

@synthesize flUploadEngine, flOperation;

@synthesize botaoFoto,tiposDeDrogaTextField,tiposDeDenunciaTextField;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        
        tiposDeDroga = [NSArray arrayWithObjects:@"Álcool", @"Cigarro" ,@"Drogas", nil];
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    UIBarButtonItem *voltar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(voltar)];
    
    
    self.navigationItem.leftBarButtonItem = voltar;
    
    UIBarButtonItem *config = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(enviarDenuncia)];
    
    self.navigationItem.rightBarButtonItem = config;
    
    self.navigationItem.title = @"Denúncia";
    
    UIPickerView *pickerTiposDroga = [[UIPickerView alloc] init];
    
    pickerTiposDroga.showsSelectionIndicator = YES;
    
    pickerTiposDroga.dataSource = self;
    pickerTiposDroga.delegate = self;
    
    pickerTiposDroga.tag = 111;
    
    [tiposDeDrogaTextField setInputView:pickerTiposDroga];
    
    UIPickerView *pickerTiposDenuncia = [[UIPickerView alloc] init];
    
    pickerTiposDenuncia.showsSelectionIndicator = YES;
    
    pickerTiposDenuncia.dataSource = self;
    pickerTiposDenuncia.delegate = self;
    
    pickerTiposDenuncia.tag = 222;
    
    [tiposDeDenunciaTextField setInputView:pickerTiposDenuncia];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)voltar{
    
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction)selecionarFoto:(id)sender{

    UIActionSheet *photoSourcePicker = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancelar" destructiveButtonTitle:nil otherButtonTitles:@"Tirar Foto", @"Escolher Existente",nil];
    
    [photoSourcePicker showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)modalView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
                imagePicker.delegate = self;
                imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
                imagePicker.allowsEditing = NO;
                [self presentViewController:imagePicker animated:YES completion:nil];
            }
            else {
                [[[UIAlertView alloc] initWithTitle:@"Erro" message:@"Este dispositivo não possui uma câmera." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }
            break;
        }
        case 1:
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
                imagePicker.delegate = self;
                imagePicker.allowsEditing = NO;
                [self presentViewController:imagePicker animated:YES completion:nil];
            }
            else {
                [[[UIAlertView alloc] initWithTitle:@"Erro" message:@"Este app não possui permissão de acesso a sua biblioteca de fotos." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }            
            break;
        }
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *imagemSelecionada = [info valueForKey:UIImagePickerControllerOriginalImage];
    [botaoFoto setBackgroundImage:imagemSelecionada forState: UIControlStateNormal];
    [botaoFoto setTitle:@"" forState:UIControlStateNormal];
    
    imagemDaDenuncia = UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerOriginalImage], 0.1);
    
}

-(void)enviarDenuncia{
    
    NSData *image = imagemDaDenuncia;
    
    self.flUploadEngine = [[fileUploadEngine alloc] initWithHostName:@"arthurdeveloper.com.br" customHeaderFields:nil];
    
    NSMutableDictionary *postParams = [[NSMutableDictionary alloc] init];
	[postParams setObject:@"John" forKey:@"testApp"];
	
    self.flOperation = [self.flUploadEngine postDataToServer:postParams path:@"/app_denuncia/acesso/controle.php?tipo=upload"];
    [self.flOperation addData:image forKey:@"imagem" mimeType:@"image/jpeg" fileName:@"upload.jpg"];
    
    [self.flOperation addCompletionHandler:^(MKNetworkOperation* operation) {
        //This is where you handle a successful 200 response
        
        NSLog(@"%@", [operation responseString]);
        
        SBJsonParser *jsonParser = [SBJsonParser new];
        NSDictionary *jsonData = (NSDictionary *) [jsonParser objectWithString:[operation responseString] error:nil];
        NSLog(@"%@",jsonData);
        NSInteger success = [(NSNumber *) [jsonData objectForKey:@"success"] integerValue];
        NSLog(@"%ld",(long)success);
        
        if(success == 1)
            [[[UIAlertView alloc] initWithTitle:@"Obrigado" message:@"Sua denúncia foi efetuada com sucesso." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        
    }
    errorHandler:^(MKNetworkOperation *errorOp, NSError* error) {
        NSLog(@"%@", error);

        [[[UIAlertView alloc] initWithTitle:@"Erro" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }];

    [self.flUploadEngine enqueueOperation:self.flOperation ];
}

#pragma mark - PickerView metodos

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    if (pickerView.tag == 111) {
        return [tiposDeDroga count];
    }
    
    if(pickerView.tag == 222)
        return [tiposDeDenuncia count];
    
    return 0;
    
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
    UILabel* lab;
    
    if (view)
        lab = (UILabel*)view; // reuse it
    else
        lab = [UILabel new];
    
    if (pickerView.tag == 111)
        lab.text = tiposDeDroga[row];
    if (pickerView.tag == 222)
        lab.text = tiposDeDenuncia[row];
    
    
    [lab setFont:[UIFont fontWithName:@"ArialRoundedMTBold" size:20.0f]];
    lab.backgroundColor = [UIColor clearColor];
    [lab sizeToFit];
    return lab;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView.tag == 111){
        self.tiposDeDrogaTextField.text = tiposDeDroga[row];
        
        [self.tiposDeDenunciaTextField reloadInputViews];
        
        self.tiposDeDenunciaTextField.text = @"";
        
        if([tiposDeDroga[row] isEqualToString:@"Álcool"])
             tiposDeDenuncia = [NSArray arrayWithObjects:@"Venda para menor", @"Arruaça", nil];
        
        if([tiposDeDroga[row] isEqualToString:@"Cigarro"])
            tiposDeDenuncia = [NSArray arrayWithObjects:@"Venda para menor", nil];
        
        if([tiposDeDroga[row] isEqualToString:@"Drogas"])
            tiposDeDenuncia = [NSArray arrayWithObjects:@"Ponto de venda", @"Ponto de consumo", nil];
       
    }
    
    if(pickerView.tag == 222){
        
        self.tiposDeDenunciaTextField.text = tiposDeDenuncia[row];
        
    }
}

@end
