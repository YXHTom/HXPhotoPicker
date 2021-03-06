//
//  Demo13ViewController.m
//  照片选择器
//
//  Created by 洪欣 on 2018/10/9.
//  Copyright © 2018年 洪欣. All rights reserved.
//

#import "Demo13ViewController.h"
#import "HXPhotoPicker.h"
#import "LFPhotoEditingController.h"
#import "LFVideoEditingController.h"

static const CGFloat kPhotoViewMargin = 12.0;
@interface Demo13ViewController ()<LFPhotoEditingControllerDelegate, LFVideoEditingControllerDelegate>
@property (strong, nonatomic) HXPhotoManager *manager;
@property (strong, nonatomic) HXPhotoView *photoView;
@property (strong, nonatomic) HXPhotoModel *beforePhotoModel;
@property (strong, nonatomic) HXPhotoModel *beforeVideoModel;
@property (assign, nonatomic) BOOL isOutside;
@property (strong, nonatomic) HXDatePhotoToolManager *toolManager;
@end

@implementation Demo13ViewController
- (HXDatePhotoToolManager *)toolManager {
    if (!_toolManager) {
        _toolManager = [[HXDatePhotoToolManager alloc] init];
    }
    return _toolManager;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    HXPhotoView *photoView = [HXPhotoView photoManager:self.manager];
    photoView.frame = CGRectMake(kPhotoViewMargin, hxNavigationBarHeight + kPhotoViewMargin, self.view.hx_w - kPhotoViewMargin * 2, 0);
    
    
    photoView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:photoView];
    self.photoView = photoView;
}
- (HXPhotoManager *)manager {
    if (!_manager) {
        _manager = [[HXPhotoManager alloc] initWithType:HXPhotoManagerSelectedTypePhotoAndVideo];
        _manager.configuration.albumShowMode = HXPhotoAlbumShowModePopup;
        _manager.configuration.openCamera = YES;
        _manager.configuration.photoMaxNum = 9;
        _manager.configuration.videoMaxNum = 9;
        _manager.configuration.maxNum = 18;
        _manager.configuration.requestImageAfterFinishingSelection = NO;
        
        _manager.configuration.photoCanEdit = YES;
        _manager.configuration.videoCanEdit = YES;
        _manager.configuration.replacePhotoEditViewController = YES;
        _manager.configuration.replaceVideoEditViewController = YES;
        
        HXWeakSelf
        _manager.configuration.shouldUseEditAsset = ^(UIViewController *viewController, BOOL isOutside, HXPhotoManager *manager, HXPhotoModel *beforeModel) {
            weakSelf.isOutside = isOutside;
            if (beforeModel.subType == HXPhotoModelMediaSubTypePhoto) {
                weakSelf.beforePhotoModel = beforeModel;
                if (beforeModel.type == HXPhotoModelMediaTypeCameraPhoto) {
                    LFPhotoEditingController *lfPhotoEditVC = [[LFPhotoEditingController alloc] init];
                    lfPhotoEditVC.oKButtonTitleColorNormal = weakSelf.manager.configuration.themeColor;
                    lfPhotoEditVC.cancelButtonTitleColorNormal = weakSelf.manager.configuration.themeColor;
                    
                    lfPhotoEditVC.delegate = weakSelf;
                    if ([beforeModel.tempAsset isKindOfClass:[LFPhotoEdit class]]) {
                        lfPhotoEditVC.photoEdit = beforeModel.tempAsset;
                    }else {
                        lfPhotoEditVC.editImage = beforeModel.previewPhoto;
                    }
                    if (!weakSelf.isOutside) {
                        [viewController.navigationController setNavigationBarHidden:YES];
                        [viewController.navigationController pushViewController:lfPhotoEditVC animated:NO];
                    }else {
                        HXCustomNavigationController *nav = [[HXCustomNavigationController alloc] initWithRootViewController:lfPhotoEditVC];
                        nav.supportRotation = NO;
                        [nav setNavigationBarHidden:YES];
                        [viewController presentViewController:nav animated:NO completion:nil];
                    }
                }else {
                    [viewController.view showLoadingHUDText:nil];
                    [HXPhotoTools getImageData:beforeModel.asset startRequestIcloud:^(PHImageRequestID cloudRequestId) {
                        
                    } progressHandler:^(double progress) {
                        
                    } completion:^(NSData *imageData, UIImageOrientation orientation) {
                        [viewController.view handleLoading];
                        UIImage *image = [UIImage imageWithData:imageData];
                        if (image.imageOrientation != UIImageOrientationUp) {
                            image = [image normalizedImage];
                        }
                        LFPhotoEditingController *lfPhotoEditVC = [[LFPhotoEditingController alloc] init];
                        lfPhotoEditVC.oKButtonTitleColorNormal = weakSelf.manager.configuration.themeColor;
                        lfPhotoEditVC.cancelButtonTitleColorNormal = weakSelf.manager.configuration.themeColor;
                        
                        lfPhotoEditVC.delegate = weakSelf;
                        if ([beforeModel.tempAsset isKindOfClass:[LFPhotoEdit class]]) {
                            lfPhotoEditVC.photoEdit = beforeModel.tempAsset;
                        }else {
                            lfPhotoEditVC.editImage = image;
                        }
                        if (!weakSelf.isOutside) {
                            [viewController.navigationController setNavigationBarHidden:YES];
                            [viewController.navigationController pushViewController:lfPhotoEditVC animated:NO];
                        }else {
                            HXCustomNavigationController *nav = [[HXCustomNavigationController alloc] initWithRootViewController:lfPhotoEditVC];
                            nav.supportRotation = NO;
                            [nav setNavigationBarHidden:YES];
                            [viewController presentViewController:nav animated:NO completion:nil];
                        }
                    } failed:^(NSDictionary *info) {
                        [viewController.view handleLoading];
                        [viewController.view showImageHUDText:@"资源获取失败!"];
                    }];
                }
            }else {
                weakSelf.beforeVideoModel = beforeModel;
                if (beforeModel.type == HXPhotoModelMediaTypeCameraVideo) {
                    LFVideoEditingController *lfVideoEditVC = [[LFVideoEditingController alloc] init];
                    lfVideoEditVC.delegate = weakSelf;
                    lfVideoEditVC.minClippingDuration = 3.f;
                    if ([beforeModel.tempAsset isKindOfClass:[LFVideoEdit class]]) {
                        lfVideoEditVC.videoEdit = beforeModel.tempAsset;
                    } else {
                        [lfVideoEditVC setVideoURL:beforeModel.videoURL placeholderImage:beforeModel.tempImage];
                    }
                    if (!weakSelf.isOutside) {
                        [viewController.navigationController setNavigationBarHidden:YES];
                        [viewController.navigationController pushViewController:lfVideoEditVC animated:NO];
                    }else {
                        HXCustomNavigationController *nav = [[HXCustomNavigationController alloc] initWithRootViewController:lfVideoEditVC];
                        nav.supportRotation = NO;
                        [nav setNavigationBarHidden:YES];
                        [viewController presentViewController:nav animated:NO completion:nil];
                    }
                }else {
                    [viewController.view showLoadingHUDText:nil];
                    [HXPhotoTools getAVAssetWithPHAsset:beforeModel.asset startRequestIcloud:^(PHImageRequestID cloudRequestId) {
                        
                    } progressHandler:^(double progress) {
                        
                    } completion:^(AVAsset *asset) {
                        [viewController.view handleLoading];
                        if ([asset isKindOfClass:[AVURLAsset class]]) {
                            NSURL *video = [(AVURLAsset *)asset URL];
                            
                            LFVideoEditingController *lfVideoEditVC = [[LFVideoEditingController alloc] init];
                            lfVideoEditVC.delegate = weakSelf;
                            lfVideoEditVC.minClippingDuration = 5.f;
                            if ([beforeModel.tempAsset isKindOfClass:[LFVideoEdit class]]) {
                                lfVideoEditVC.videoEdit = beforeModel.tempAsset;
                            } else {
                                [lfVideoEditVC setVideoURL:video placeholderImage:[HXPhotoTools thumbnailImageForVideo:video atTime:0.1f]];
                            }
                            if (!weakSelf.isOutside) {
                                [viewController.navigationController setNavigationBarHidden:YES];
                                [viewController.navigationController pushViewController:lfVideoEditVC animated:NO];
                            }else {
                                HXCustomNavigationController *nav = [[HXCustomNavigationController alloc] initWithRootViewController:lfVideoEditVC];
                                nav.supportRotation = NO;
                                [nav setNavigationBarHidden:YES];
                                [viewController presentViewController:nav animated:NO completion:nil];
                            }
                        }else {
                            [weakSelf.toolManager writeSelectModelListToTempPathWithList:@[beforeModel] requestType:1 success:^(NSArray<NSURL *> *allURL, NSArray<NSURL *> *photoURL, NSArray<NSURL *> *videoURL) {
                                [viewController.view handleLoading];
                                NSURL *video = videoURL.firstObject;
                                
                                LFVideoEditingController *lfVideoEditVC = [[LFVideoEditingController alloc] init];
                                lfVideoEditVC.delegate = weakSelf;
                                lfVideoEditVC.minClippingDuration = 5.f;
                                if ([beforeModel.tempAsset isKindOfClass:[LFVideoEdit class]]) {
                                    lfVideoEditVC.videoEdit = beforeModel.tempAsset;
                                } else {
                                    [lfVideoEditVC setVideoURL:video placeholderImage:[HXPhotoTools thumbnailImageForVideo:video atTime:0.1f]];
                                }
                                if (!weakSelf.isOutside) {
                                    [viewController.navigationController setNavigationBarHidden:YES];
                                    [viewController.navigationController pushViewController:lfVideoEditVC animated:NO];
                                }else {
                                    HXCustomNavigationController *nav = [[HXCustomNavigationController alloc] initWithRootViewController:lfVideoEditVC];
                                    nav.supportRotation = NO;
                                    [nav setNavigationBarHidden:YES];
                                    [viewController presentViewController:nav animated:NO completion:nil];
                                }
                            } failed:^{
                                [viewController.view handleLoading];
                                [viewController.view showImageHUDText:@"资源获取失败!"];
                            }];
                        }
                    } failed:^(NSDictionary *info) {
                        [viewController.view handleLoading];
                        [viewController.view showImageHUDText:@"资源获取失败!"];
                    }];
                }
            }
        };
    }
    return _manager;
}
- (void)lf_PhotoEditingController:(LFPhotoEditingController *)photoEditingVC didFinishPhotoEdit:(LFPhotoEdit *)photoEdit {
    [photoEditingVC.navigationController setNavigationBarHidden:NO];
    
    HXPhotoModel *model = [HXPhotoModel photoModelWithImage:photoEdit.editPreviewImage];
    model.tempAsset = photoEdit;
    if (photoEditingVC.navigationController.viewControllers.count > 1) {
        [photoEditingVC.navigationController popViewControllerAnimated:NO];
    }else {
        [photoEditingVC dismissViewControllerAnimated:NO completion:nil];
    }
    
    self.manager.configuration.usePhotoEditComplete(self.beforePhotoModel, model);
}

- (void)lf_PhotoEditingController:(LFPhotoEditingController *)photoEditingVC didCancelPhotoEdit:(LFPhotoEdit *)photoEdit {
    [photoEditingVC.navigationController setNavigationBarHidden:NO];
    
    if (photoEditingVC.navigationController.viewControllers.count > 1) {
        [photoEditingVC.navigationController popViewControllerAnimated:NO];
    }else {
        [photoEditingVC dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)lf_VideoEditingController:(LFVideoEditingController *)videoEditingVC didCancelPhotoEdit:(LFVideoEdit *)videoEdit {
    [videoEditingVC.navigationController setNavigationBarHidden:NO];
    
    if (videoEditingVC.navigationController.viewControllers.count > 1) {
        [videoEditingVC.navigationController popViewControllerAnimated:NO];
    }else {
        [videoEditingVC dismissViewControllerAnimated:NO completion:nil];
    }
}
- (void)lf_VideoEditingController:(LFVideoEditingController *)videoEditingVC didFinishPhotoEdit:(LFVideoEdit *)videoEdit {
    [videoEditingVC.navigationController setNavigationBarHidden:NO];
    
    HXPhotoModel *model = [HXPhotoModel photoModelWithVideoURL:videoEdit.editFinalURL];
    model.tempAsset = videoEdit;
    
    if (videoEditingVC.navigationController.viewControllers.count > 1) {
        [videoEditingVC.navigationController popViewControllerAnimated:NO];
    }else {
        [videoEditingVC dismissViewControllerAnimated:NO completion:nil];
    }
    
    self.manager.configuration.useVideoEditComplete(self.beforeVideoModel, model);
}
- (void)dealloc {
    NSSLog(@"dealloc");
}

@end
