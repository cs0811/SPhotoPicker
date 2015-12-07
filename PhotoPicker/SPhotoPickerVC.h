//
//  SPhotoPickerVC.h
//  PhotoPicker
//
//  Created by S on 15/11/16.
//  Copyright © 2015年 S. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SelectedImgsBlock)(NSArray *imgsArray);

@interface SPhotoPickerVC : UIViewController

/**
 只选一张图
 */
@property(nonatomic,assign) BOOL oneImageSelect;
@property(nonatomic,strong) SelectedImgsBlock selectedImgsBlock;

@end
