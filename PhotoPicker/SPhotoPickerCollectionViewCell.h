//
//  SPhotoPickerCollectionViewCell.h
//  PhotoPicker
//
//  Created by S on 15/11/16.
//  Copyright © 2015年 S. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPhotoPickerCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView * iconImage;
@property (nonatomic, strong) UIButton *    selectBtn;


- (void)loadPhotoWithDataArr:(NSArray *)dataArr row:(NSInteger)row;

@end
