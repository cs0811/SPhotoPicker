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


@interface SPhotoPickerVC ()<UICollectionViewDataSource,UICollectionViewDelegate,UIAlertViewDelegate>
{
    NSMutableArray * imgsArr;
    NSMutableArray * highDefinitionImgsArr;
    NSMutableArray * returnArr;
    UICollectionView * _showCollection;
    NSUInteger _count;
    BOOL _isBigImage;
    CGRect _currentFrame;
    int _currentSelectNum;
    SPhotoPickerCollectionViewCell * lastCell;
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
    self.automaticallyAdjustsScrollViewInsets = false;
    self.view.backgroundColor = RGB(240, 240, 240);
    self.navigationItem.title = @"选取图片";
    
    
    [self loadUI];
    [self loadData];
}

- (void)loadData {
    
    NSString *tipTextWhenNoPhotosAuthorization; // 提示语
    // 获取当前应用对照片的访问授权状态
    ALAuthorizationStatus authorizationStatus = [ALAssetsLibrary authorizationStatus];
    // 如果没有获取访问授权，或者访问授权状态已经被明确禁止，则显示提示语，引导用户开启授权
    if (authorizationStatus == ALAuthorizationStatusRestricted || authorizationStatus == ALAuthorizationStatusDenied) {
        NSDictionary *mainInfoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *appName = [mainInfoDictionary objectForKey:@"CFBundleName"];
        tipTextWhenNoPhotosAuthorization = [NSString stringWithFormat:@"请在设备的\"设置-隐私-照片\"选项中，允许%@访问你的手机相册", appName];
        // 展示提示语
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:tipTextWhenNoPhotosAuthorization delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    }
    
    imgsArr = [NSMutableArray array];
    highDefinitionImgsArr = [NSMutableArray array];
    returnArr = [NSMutableArray array];
    
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
    
    _showCollection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-60-64) collectionViewLayout:collectionFlowLayout];
    _showCollection.delegate = self;
    _showCollection.dataSource = self;
    _showCollection.backgroundColor = RGB(240, 240, 240);
    
    [_showCollection registerClass:[SPhotoPickerCollectionViewCell class] forCellWithReuseIdentifier:@"SPhotoPickerCollectionViewCell"];
    
    [self.view addSubview:_showCollection];
    
    
    // bottomView
    UIView * bottomBaseView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-60, self.view.frame.size.width, 60)];
    bottomBaseView.userInteractionEnabled = YES;
    bottomBaseView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomBaseView];
    
    UIButton * enSureBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 15, self.view.frame.size.width/2, 30)];
    enSureBtn.center = CGPointMake(self.view.center.x, 12+15);
    enSureBtn.backgroundColor = NAVBAR_COLOR;
    [enSureBtn setTitle:LocalizedStr(@"选择") forState:UIControlStateNormal];
    [enSureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    enSureBtn.layer.cornerRadius = 15;
    enSureBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    
    [enSureBtn addTarget:self action:@selector(enSureClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [bottomBaseView addSubview:enSureBtn];
    
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
    
    CGPoint  point = CGPointMake(cell.center.x-collectionView.contentOffset.x, cell.center.y-collectionView.contentOffset.y+64);
    [self loadImageDetailWithPosition:point row:indexPath.row];
}

#pragma mark - AlertDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"prefs:root=Privacy"]];
        if([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
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

- (void)loadImageDetailWithPosition:(CGPoint)center row:(NSInteger)row {
    
    CGRect navigationFrame = self.navigationController.navigationBar.frame;
    _showCollection.userInteractionEnabled = NO;
    
    
    UIImageView * bigImageView = [self addFullScreenImageWithCenter:center Row:row];
    _currentFrame = bigImageView.frame;
    
    [UIView animateWithDuration:0.25 animations:^{
        bigImageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        self.navigationController.navigationBar.frame = CGRectMake(navigationFrame.origin.x, navigationFrame.origin.y-64, navigationFrame.size.width, navigationFrame.size.height);
    } completion:^(BOOL finished) {
        
    }];
    
    _isBigImage = YES;
}

- (UIImageView *)addFullScreenImageWithCenter:(CGPoint)center Row:(NSInteger)row {
    
    CGFloat space = 20;
    CGFloat width = (self.view.frame.size.width-4*space)/3;
    
    
    UIImage * image = highDefinitionImgsArr[row];
    CGFloat height = SYSTEM_WIDTH*image.size.height/image.size.width;
    
    /**
     修改image区域
     */
    UIImageView * bigImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
    bigImageView.backgroundColor = [UIColor blackColor];
    bigImageView.center = center;
    bigImageView.userInteractionEnabled = YES;
    [self.view addSubview:bigImageView];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(SYSTEM_WIDTH, self.view.bounds.size.height), NO, [UIScreen mainScreen].scale);
        [image drawInRect:CGRectMake(0, (self.view.bounds.size.height-height)/2,  SYSTEM_WIDTH , height)];
        UIImage *imgTmp = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
            bigImageView.image = imgTmp;
        });
    });
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bigImageTap:)];
    [bigImageView addGestureRecognizer:tap];
    
    return bigImageView;
}

#pragma mark - bigImageTap
- (void)bigImageTap:(UITapGestureRecognizer *)tap {
    
    CGRect navigationFrame = self.navigationController.navigationBar.frame;
    
    if (_isBigImage) {
        [UIView animateWithDuration:0.25 animations:^{
            tap.view.frame = _currentFrame;
            self.navigationController.navigationBar.frame = CGRectMake(navigationFrame.origin.x, navigationFrame.origin.y+64, navigationFrame.size.width, navigationFrame.size.height);
        } completion:^(BOOL finished) {
            [tap.view removeFromSuperview];
            self.navigationController.navigationBarHidden = NO;
            _showCollection.userInteractionEnabled = YES;
        }];
    }
}

#pragma mark - selectBtnClick
- (void)selectBtnClick:(UIButton *)sender {
    
    _currentSelectNum = (int)(sender.tag-1000);
    
    if (self.oneImageSelect) {
        [self selectOneImage:sender];
    }else {
        [self selectMoreImage:sender];
    }
    
}

- (void)selectOneImage:(UIButton *)sender {
    
    [lastCell.selectBtn setSelected:NO];
    sender.selected = YES;
    if (lastCell) {
        if ([returnArr containsObject:highDefinitionImgsArr[lastCell.selectBtn.tag-1000]]) {
            [returnArr removeObject:highDefinitionImgsArr[lastCell.selectBtn.tag-1000]];
        }
        
        if (![returnArr containsObject:highDefinitionImgsArr[_currentSelectNum]]) {
            [returnArr addObject:highDefinitionImgsArr[_currentSelectNum]];
        }
    }else {
        if (![returnArr containsObject:highDefinitionImgsArr[_currentSelectNum]]) {
            [returnArr addObject:highDefinitionImgsArr[_currentSelectNum]];
        }
    }
    
    lastCell = (SPhotoPickerCollectionViewCell *)sender.superview;
}

- (void)selectMoreImage:(UIButton *)sender {
    if (sender.selected) {
        if ([returnArr containsObject:highDefinitionImgsArr[_currentSelectNum]]) {
            [returnArr removeObject:highDefinitionImgsArr[_currentSelectNum]];
        }
    }else {
        if (![returnArr containsObject:highDefinitionImgsArr[_currentSelectNum]]) {
            [returnArr addObject:highDefinitionImgsArr[_currentSelectNum]];
        }
    }
    
    sender.selected = !sender.selected;
}

#pragma mark - enSureClick
- (void)enSureClick:(UIButton *)sender {
    // 回传选中的image
    self.selectedImgsBlock(returnArr);
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    _showCollection.delegate = nil;
    _showCollection.dataSource = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
