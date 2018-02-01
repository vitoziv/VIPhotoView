//
//  VIPhotoView.h
//  VIPhotoViewDemo
//
//  Created by Vito on 1/7/15.
//  Copyright (c) 2015 vito. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    VIPhotoViewContentModeScaleAspectFit            = UIViewContentModeScaleAspectFit,
    VIPhotoViewContentModeScaleAspectFill           = UIViewContentModeScaleAspectFill,
    VIPhotoViewContentModeScaleAspectFillToLeft     = 1 << 10,
    VIPhotoViewContentModeScaleAspectFillToTop      = 1 << 11,
    VIPhotoViewContentModeScaleAspectFillToRight    = 1 << 12,
    VIPhotoViewContentModeScaleAspectFillToBottom   = 1 << 13,
    VIPhotoViewContentModeCenter                    = UIViewContentModeCenter
    
} VIPhotoViewContentMode;

@interface VIPhotoView : UIScrollView

@property (nonatomic, strong, readonly) UITapGestureRecognizer *doubleTapGestureRecognizer;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) VIPhotoViewContentMode contentMode;

- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image;
- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image contentMode:(VIPhotoViewContentMode)contentMode;

@end
