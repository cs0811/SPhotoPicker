//
//  SPhotoPickerCollectionViewCell.m
//  PhotoPicker
//
//  Created by S on 15/11/16.
//  Copyright © 2015年 S. All rights reserved.
//

#import "SPhotoPickerCollectionViewCell.h"

#define SYSTEM_WIDTH [UIScreen mainScreen].bounds.size.width

@implementation SPhotoPickerCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        CGFloat space = 20;
        CGFloat width = (SYSTEM_WIDTH-4*space)/3;
        
        _iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
        _iconImage.layer.cornerRadius = 5;
        _iconImage.clipsToBounds = YES;
        [self addSubview:_iconImage];
        
        
        _selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(width-25, 5, 20, 20)];
        [_selectBtn setImage:[UIImage imageNamed:@"unSelectPhoto"] forState:UIControlStateNormal];
        [_selectBtn setImage:[UIImage imageNamed:@"singleSelect"] forState:UIControlStateSelected];
        
        [self addSubview:_selectBtn];
        
    }
    return self;
}

- (void)loadPhotoWithDataArr:(NSArray *)dataArr row:(NSInteger)row {
    
    _iconImage.image = dataArr[row];
}

@end
