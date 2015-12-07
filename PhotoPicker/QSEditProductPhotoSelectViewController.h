//
//  QSEditProductPhotoSelectViewController.h
//  QuicklyShop
//
//  Created by S on 15/8/18.
//  Copyright (c) 2015年 com. All rights reserved.
//

#import "AbstractViewController.h"

typedef void(^returnSelectImageBlock)(id image, BOOL isFromAlbum);

@interface QSEditProductPhotoSelectViewController : AbstractViewController

@property (nonatomic, strong) QSProduct * production;
@property (nonatomic, assign) BOOL isFromAlbum;
@property (nonatomic, copy) returnSelectImageBlock selectImageBlock;


- (void)returenSelectImage:(returnSelectImageBlock) returnSelectImageBlcok;

@end
