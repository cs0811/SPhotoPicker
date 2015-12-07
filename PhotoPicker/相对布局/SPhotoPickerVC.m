//
//  SPhotoPickerVC.m
//  PhotoPicker
//
//  Created by S on 15/11/16.
//  Copyright © 2015年 S. All rights reserved.
//

#import "SPhotoPickerVC.h"
#import "SPhotoPickerCollectionViewCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import "Masonry.h"


@interface SPhotoPickerVC ()<UICollectionViewDataSource,UICollectionViewDelegate>
{
    NSMutableArray * imgsArr;
    NSMutableArray * highDefinitionImgsArr;
    UICollectionView * _showCollection;
    BOOL _isBigImage;
    NSArray * _currentPosition;
    int _currentSelectNum;
}
@end

#define RGB(r, g, b)    [UIColor colorWithRed:(r)/255. green:(g)/255. blue:(b)/255. alpha:1.]
#define NAVBAR_COLOR                RGB(232, 60, 40)
#define LocalizedStr(key)  NSLocalizedString(key, @"")
#define SYSTEM_WIDTH [UIScreen mainScreen].bounds.size.width

@implementation SPhotoPickerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"选取图片";
    
    
    [self loadUI];
    [self loadData];
}

- (void)loadData {
    imgsArr = [NSMutableArray array];
    highDefinitionImgsArr = [NSMutableArray array];
    
    [self loadImagesFromAlbum];
}

- (void)loadUI {
    
    CGFloat space = 20;
    CGFloat width = (self.view.frame.size.width-4*space)/3;
    
    UICollectionViewFlowLayout * collectionFlowLayout = [[UICollectionViewFlowLayout alloc]init];
    [collectionFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    collectionFlowLayout.itemSize = CGSizeMake(width, width);
    collectionFlowLayout.minimumInteritemSpacing = 20;
    collectionFlowLayout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15);
    
    _showCollection = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:collectionFlowLayout];
    _showCollection.delegate = self;
    _showCollection.dataSource = self;
    _showCollection.backgroundColor = RGB(240, 240, 240);
    [_showCollection registerClass:[SPhotoPickerCollectionViewCell class] forCellWithReuseIdentifier:@"SPhotoPickerCollectionViewCell"];
    [self.view addSubview:_showCollection];
    __weak typeof(self)  wself = self;
    [_showCollection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(wself.view);
        make.top.equalTo(wself.view).offset(64);
        make.bottom.equalTo(wself.view).offset(-60);
    }];
    
    
    // bottomView
    UIView * bottomBaseView = [[UIView alloc] init];
    bottomBaseView.userInteractionEnabled = YES;
    bottomBaseView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomBaseView];
    [bottomBaseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(wself.view);
        make.top.equalTo(_showCollection.mas_bottom);
    }];
    
    UIButton * enSureBtn = [[UIButton alloc] init];
    enSureBtn.backgroundColor = NAVBAR_COLOR;
    [enSureBtn setTitle:LocalizedStr(@"选择") forState:UIControlStateNormal];
    [enSureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    enSureBtn.layer.cornerRadius = 5;
    enSureBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [enSureBtn addTarget:self action:@selector(enSureClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomBaseView addSubview:enSureBtn];
    [enSureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(bottomBaseView);
        make.width.equalTo(bottomBaseView).multipliedBy(0.4);
        make.height.equalTo(bottomBaseView).multipliedBy(0.6);
    }];
    
}

#pragma mark - collectionDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return imgsArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SPhotoPickerCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SPhotoPickerCollectionViewCell" forIndexPath:indexPath];
    
    cell.selectBtn.tag = 1000+indexPath.row;
    
    [cell loadPhotoWithDataArr:imgsArr row:indexPath.row];
    
    [cell.selectBtn addTarget:self action:@selector(selectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    SPhotoPickerCollectionViewCell * cell = (SPhotoPickerCollectionViewCell  *)[_showCollection cellForItemAtIndexPath:indexPath];
    [self loadImageDetailWithPosition:@[cell.mas_centerX,cell.mas_centerY,cell.mas_width,cell.mas_height] row:indexPath.row];
}

#pragma mark - loadPhotoFromAlbum
- (void)loadImagesFromAlbum {
    
    ALAssetsLibrary * assetsLibrary;
    assetsLibrary = [[ALAssetsLibrary alloc] init];
    
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
                    UIImage * image = [UIImage imageWithCGImage:result.thumbnail];
                    UIImage * highDefinitionImage = [UIImage imageWithCGImage:result.defaultRepresentation.fullScreenImage];
                    
                    [imgsArr addObject:image];
                    [highDefinitionImgsArr addObject:highDefinitionImage];
                }
            }];
            [_showCollection reloadData];
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"Group not found!\n");
    }];
    
}

- (void)loadImageDetailWithPosition:(NSArray *)position row:(NSInteger)row {
    
    _showCollection.userInteractionEnabled = NO;

    UIImage * image = highDefinitionImgsArr[row];
    CGFloat height = SYSTEM_WIDTH*image.size.height/image.size.width;
    
    /**
     修改image区域
     */
    UIImageView * bigImageView = [[UIImageView alloc] init];
    bigImageView.backgroundColor = [UIColor blackColor];
    bigImageView.userInteractionEnabled = YES;
    [self.view addSubview:bigImageView];
    [bigImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(position[0]);
        make.centerY.equalTo(position[1]);
        make.width.equalTo(position[2]);
        make.height.equalTo(position[3]);
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIGraphicsBeginImageContext(CGSizeMake(SYSTEM_WIDTH, self.view.bounds.size.height));
        [image drawInRect:CGRectMake(0, (self.view.bounds.size.height-height)/2,  SYSTEM_WIDTH , height)];
        UIImage *imgTmp = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
           bigImageView.image = imgTmp;
        });
    });
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bigImageTap:)];
    [bigImageView addGestureRecognizer:tap];
    
    __weak typeof(self)  wsel = self;
    [bigImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.centerY.centerX.equalTo(wsel.view);
    }];
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark - bigImageTap
- (void)bigImageTap:(UITapGestureRecognizer *)tap {
    
    self.navigationController.navigationBarHidden = NO;
    [tap.view removeFromSuperview];
    _showCollection.userInteractionEnabled = YES;
}

#pragma mark - selectBtnClick
- (void)selectBtnClick:(UIButton *)sender {
    
    _currentSelectNum = (int)(sender.tag-1000);
    
    for (int a=1000; a<1000+imgsArr.count; a++) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:a-1000 inSection:0];
        SPhotoPickerCollectionViewCell * cell = (SPhotoPickerCollectionViewCell *)[_showCollection cellForItemAtIndexPath:indexPath];
        if (cell.selectBtn.tag != sender.tag) {
            [cell.selectBtn setSelected:NO];
        }else {
            [cell.selectBtn setSelected:YES];
        }
    }
}

#pragma mark - enSureClick
- (void)enSureClick:(UIButton *)sender {
    NSLog(@"选择结束");
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
