//
//  QSEditProductPhotoSelectViewController.m
//  QuicklyShop
//
//  Created by S on 15/8/18.
//  Copyright (c) 2015年 com. All rights reserved.
//

#import "QSEditProductPhotoSelectViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>


#define SYSTEM_WIDTH [UIScreen mainScreen].bounds.size.width

@interface QSEditProductPhotoSelectViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
{
    NSMutableArray * imgsArr;
    NSMutableArray * highDefinitionImgsArr;
    UICollectionView * _showCollection;
    NSUInteger _count;
    BOOL _isBigImage;
    CGRect _currentFrame;
    int _currentSelectNum;
    UIImage *handleImage;
    UIImage * _image;
    UIImageView * _imageView;
    NSMutableArray * _returnImageArr;
}
@end


@implementation QSEditProductPhotoSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /**
     mainPhoto = "主图";
     album = "图库";
     */
    
    self.barMainTitle = _isFromAlbum ? LocalizedStr(@"album") : LocalizedStr(@"mainPhoto");
    
    
    [self loadUI];
    [self loadData];
}

- (void)loadData {
    _currentSelectNum = -1;
    
    _returnImageArr = [NSMutableArray array];
    highDefinitionImgsArr = [NSMutableArray array];
    imgsArr = [NSMutableArray array];
    
    
    if (_isFromAlbum) {
        [self loadImagesFromAlbum];

    }else {
        NSArray * array = [[[_production imgs] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sortKey" ascending:YES]]];
        
        [_returnImageArr addObjectsFromArray:array];
        for (QSImg * img in array) {
            [self getUrl:img.originalImg];
        }
        
    }
}


- (void)getUrl:(NSString *)_imageURL {
    
    _imageView = [[UIImageView alloc] init];
    if ([_imageURL rangeOfString:@"http"].location != NSNotFound) {
        __weak typeof(self) weakSelf = self;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
        [_imageView setImageWithURL:[NSURL URLWithString:[QSTool operationImgURL:_imageURL withImgSize:[UIScreen mainScreen].bounds.size]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
#pragma clang diagnostic pop
            if (!weakSelf) {
                return ;
            }
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (image) {
                
                [strongSelf->imgsArr addObject:image];
                [strongSelf->highDefinitionImgsArr addObject:image];
                [strongSelf->_showCollection reloadData];
            }
        }];
    } else {
        if ([_imageURL  rangeOfString:@"asset"].location != NSNotFound) {
            
            ALAssetsLibrary * assetsLibrary = [[ALAssetsLibrary alloc] init];
            
            [assetsLibrary assetForURL:[NSURL URLWithString:_imageURL] resultBlock:^(ALAsset *asset) {
                if (asset) {
                    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                             (id)kCFBooleanTrue, kCGImageSourceCreateThumbnailWithTransform,
                                             (id)kCFBooleanTrue, kCGImageSourceCreateThumbnailFromImageAlways,
                                             (id)[NSNumber numberWithFloat:320.], kCGImageSourceThumbnailMaxPixelSize,
                                             nil];
                    _image = [UIImage imageWithCGImage:[asset.defaultRepresentation CGImageWithOptions:options] scale:asset.defaultRepresentation.scale orientation:(UIImageOrientation)asset.defaultRepresentation.orientation];
                    //                    self.imageView.image = [UIImage imageWithCGImage:[[asset defaultRepresentation] CGImageWithOptions:options]];
                    
                    [imgsArr addObject:_image];
                    [highDefinitionImgsArr addObject:_image];
                }
                [_showCollection reloadData];
            } failureBlock:NULL];
        } else {
            NSString *pathOfImage = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",_imageURL]];
            _image = [UIImage imageWithContentsOfFile:pathOfImage];
            
            [imgsArr addObject:_image];
            [highDefinitionImgsArr addObject:_image];
            [_showCollection reloadData];
        }
    }
}

- (void)loadUI {
    
    CGFloat space = 20;
    CGFloat width = (self.view.frame.size.width-4*space)/3;
    
    UICollectionViewFlowLayout * collectionFlowLayout = [[UICollectionViewFlowLayout alloc]init];
    [collectionFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    collectionFlowLayout.itemSize = CGSizeMake(width, width);
    collectionFlowLayout.minimumInteritemSpacing = 20;
    collectionFlowLayout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15);
    
    _showCollection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-54-64) collectionViewLayout:collectionFlowLayout];
    _showCollection.delegate = self;
    _showCollection.dataSource = self;
    _showCollection.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
    
    [_showCollection registerClass:[QSSelectPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"QSSelectPhotoCollectionViewCell"];
    
    [self.view addSubview:_showCollection];
    
    
    // bottomView
    UIView * bottomBaseView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-54-64, self.view.frame.size.width, 54)];
    bottomBaseView.userInteractionEnabled = YES;
    bottomBaseView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomBaseView];
    
    UIButton * enSureBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 12, self.view.frame.size.width/2, 30)];
    enSureBtn.center = CGPointMake(self.view.center.x, 12+15);
    enSureBtn.backgroundColor = NAVBAR_COLOR;
    [enSureBtn setTitle:LocalizedStr(@"selectPhoto_enSureBtnTitle") forState:UIControlStateNormal];
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
    
    QSSelectPhotoCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"QSSelectPhotoCollectionViewCell" forIndexPath:indexPath];
    
    cell.selectBtn.tag = 1000+indexPath.row;
    
    [cell loadPhotoWithDataArr:imgsArr row:indexPath.row];
 
    [cell.selectBtn addTarget:self action:@selector(selectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    QSSelectPhotoCollectionViewCell * cell = (QSSelectPhotoCollectionViewCell  *)[_showCollection cellForItemAtIndexPath:indexPath];
    
    CGPoint  point = CGPointMake(cell.center.x-collectionView.contentOffset.x, cell.center.y-collectionView.contentOffset.y);
    [self loadImageDetailWithPosition:point row:indexPath.row];
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
                    UIImage * highDefinitionImage = [UIImage imageWithCGImage:result.defaultRepresentation.fullResolutionImage];
                    
                    [_returnImageArr addObject:highDefinitionImage];
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
    
    CGFloat space = 20;
    CGFloat width = (self.view.frame.size.width-4*space)/3;

    
    UIImage * image = highDefinitionImgsArr[row];
    CGFloat height = SYSTEM_WIDTH*image.size.height/image.size.width;
    
    /**
        修改image区域
     */
    UIGraphicsBeginImageContext(CGSizeMake(SYSTEM_WIDTH, self.view.bounds.size.height));
    [image drawInRect:CGRectMake(0, (self.view.bounds.size.height-height)/2,  SYSTEM_WIDTH , height)];
    UIImage *imgTmp = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView * bigImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
    bigImageView.backgroundColor = [UIColor blackColor];
    bigImageView.center = center;
    bigImageView.image = imgTmp;
    bigImageView.userInteractionEnabled = YES;
    [self.view addSubview:bigImageView];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bigImageTap:)];
    [bigImageView addGestureRecognizer:tap];
    
    _currentFrame = bigImageView.frame;
    
    [UIView animateWithDuration:0.5 animations:^{
        bigImageView.frame = CGRectMake(0, -64, self.view.frame.size.width, self.view.frame.size.height+64);
        self.navigationController.navigationBar.frame = CGRectMake(navigationFrame.origin.x, navigationFrame.origin.y-64, navigationFrame.size.width, navigationFrame.size.height);
    } completion:^(BOOL finished) {
        
    }];
    
    _isBigImage = YES;
}

#pragma mark - bigImageTap 
- (void)bigImageTap:(UITapGestureRecognizer *)tap {
    
    CGRect navigationFrame = self.navigationController.navigationBar.frame;

    if (_isBigImage) {
        [UIView animateWithDuration:0.5 animations:^{
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
    
    for (int a=1000; a<1000+imgsArr.count; a++) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:a-1000 inSection:0];
        QSSelectPhotoCollectionViewCell * cell = (QSSelectPhotoCollectionViewCell *)[_showCollection cellForItemAtIndexPath:indexPath];
        if (cell.selectBtn.tag != sender.tag) {
            [cell.selectBtn setSelected:NO];
        }else {
            [cell.selectBtn setSelected:YES];
        }
    }
}

- (void)returenSelectImage:(returnSelectImageBlock)returnSelectImageBlcok {
    _selectImageBlock = returnSelectImageBlcok;
}


#pragma mark - enSureClick
- (void)enSureClick:(UIButton *)sender {
    
    if (_currentSelectNum == -1) {
        [QSTool showAlert:LocalizedStr(@"photoSelectCannotBeSpace")];
    }else {
        WS(wSelf);
        
        handleImage = imgsArr[_currentSelectNum];
        if (handleImage.size.height > handleImage.size.width && handleImage.size.height > 400){
            handleImage = [UIImage scaleDown:handleImage withSize:CGSizeMake(400*handleImage.size.width/handleImage.size.height, 400)];
        }
        if(handleImage.size.height <= handleImage.size.width && handleImage.size.width > 400){
            handleImage = [UIImage scaleDown:handleImage withSize:CGSizeMake(400, 400*handleImage.size.height/handleImage.size.width)];
        }
        [[NetHttpActivity shareActivity]show:YES];
        [[QSPhotoUpLoader sharedInstance] upLoadFileWithPath:kUpLoadPhoto parameters:@{@"belong":@"PRODUCT"} bodyData:@[UIImageJPEGRepresentation(handleImage,0.5)] completionHandler:^(BOOL *isSucceed, id responseObject) {
            if (!wSelf) {
                return ;
            }
            [[NetHttpActivity shareActivity]hide:YES];
            __strong typeof(wSelf) strongSelf = wSelf;
            if (*isSucceed) {
                NSArray *dataArr = [responseObject objectForKey:@"data"];
                if ([dataArr isKindOfClass:[NSArray class]]) {
                    if (dataArr.count > 0) {
                        NSDictionary *imgDict = [dataArr objectAtIndex:0];
                        NSString *imgeUrl = [imgDict objectForKey:@"id"];
                        id obj = strongSelf->_returnImageArr[strongSelf->_currentSelectNum];
                        if ([obj isKindOfClass:[QSImg class]]) {
                            QSImg *img = (QSImg*)obj;
                            img.imgUrl = imgeUrl;
                            img.originalImg = imgeUrl;
                            img.picture = [NSKeyedArchiver archivedDataWithRootObject:handleImage];
                        }
                        wSelf.selectImageBlock(obj,strongSelf->_isFromAlbum);
                    } else {
                        [QSTool showAlert:LocalizedStr(@"uploadPicture_failure")];
                    }
                } else {
                    [QSTool showAlert:LocalizedStr(@"uploadPicture_failure")];
                }
            }
        } withTag:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
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
