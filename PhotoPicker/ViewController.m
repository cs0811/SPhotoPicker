//
//  ViewController.m
//  PhotoPicker
//
//  Created by S on 15/12/7.
//  Copyright © 2015年 S. All rights reserved.
//

#import "ViewController.h"
#import "SPhotoPickerVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self loadUI];
}

- (void)loadUI {
    UIButton * photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    photoBtn.frame = CGRectMake(0, 0, 150, 40);
    photoBtn.center = self.view.center;
    photoBtn.backgroundColor = [UIColor lightGrayColor];
    [photoBtn setTitle:@"PhotoSelect" forState:UIControlStateNormal];
    [photoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [photoBtn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:photoBtn];
}

- (void)btnClick {
    SPhotoPickerVC * photo = [[SPhotoPickerVC alloc] init];
    // 只选一张图
//    photo.oneImageSelect = YES;
    
    photo.selectedImgsBlock = ^(NSArray *imgsArray) {
        NSLog(@"%@",imgsArray);
        
        [self loadAlert:imgsArray];
    };
    
    [self.navigationController pushViewController:photo animated:YES];
}

- (void)loadAlert:(NSArray *)dataArr {
    NSString * str = [NSString stringWithFormat:@"已经选择%lu张图",(unsigned long)dataArr.count];
    
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Imgs" message:str delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
    [alert show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
