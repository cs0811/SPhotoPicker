# SPhotoPicker
图片选择器,支持只选一张和选取多张

##接入
    SPhotoPickerVC * photo = [[SPhotoPickerVC alloc] init];
    // 只选一张图
    //    photo.oneImageSelect = YES;
    
    photo.selectedImgsBlock = ^(NSArray *imgsArray) {
        NSLog(@"%@",imgsArray);
        
        [self loadAlert:imgsArray];
    };
    
    [self.navigationController pushViewController:photo animated:YES];

![image](https://github.com/cs0811/SPhotoPicker/blob/master/SPhotoPickerGif.gif) 
