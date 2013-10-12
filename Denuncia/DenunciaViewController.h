//
//  DenunciaViewController.h
//  Denuncia
//
//  Created by Arthur Junqueira Cançado on 09/10/13.
//  Copyright (c) 2013 Arthur Developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fileUploadEngine.h"

@interface DenunciaViewController : UIViewController <UIActionSheetDelegate, UINavigationControllerDelegate , UIImagePickerControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) fileUploadEngine *flUploadEngine;

@property (strong, nonatomic) MKNetworkOperation *flOperation;

@property (weak, nonatomic) IBOutlet UIButton *botaoFoto;

@property (weak, nonatomic) IBOutlet UITextField *tiposDeDrogaTextField;

@property (weak, nonatomic) IBOutlet UITextField *tiposDeDenunciaTextField;

- (IBAction)selecionarFoto:(id)sender;

@end
