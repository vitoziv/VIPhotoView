//
//  VIPhotoView.m
//  VIPhotoViewDemo
//
//  Created by Vito on 1/7/15.
//  Copyright (c) 2015 vito. All rights reserved.
//

#import "VIPhotoView.h"

@interface UIImage (VIUtil)

- (CGSize)sizeThatFits:(CGSize)size;
- (CGSize)sizeThatFills:(CGSize)size;

@end

@implementation UIImage (VIUtil)

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize imageSize = CGSizeMake(self.size.width / self.scale,
                                  self.size.height / self.scale);
    
    CGFloat widthRatio = imageSize.width / size.width;
    CGFloat heightRatio = imageSize.height / size.height;
    
    if (widthRatio > heightRatio) {
        imageSize = CGSizeMake(imageSize.width / widthRatio, imageSize.height / widthRatio);
    } else {
        imageSize = CGSizeMake(imageSize.width / heightRatio, imageSize.height / heightRatio);
    }
    
    return imageSize;
}

- (CGSize)sizeThatFills:(CGSize)size {
    CGSize imageSize = CGSizeMake(self.size.width / self.scale,
                                  self.size.height / self.scale);
    
    CGFloat widthRatio = imageSize.width / size.width;
    CGFloat heightRatio = imageSize.height / size.height;
    
    if (widthRatio < heightRatio) {
        imageSize = CGSizeMake(size.width, imageSize.height / widthRatio);
    }else{
        imageSize = CGSizeMake(imageSize.width / heightRatio, size.height);
    }
    return imageSize;
}

@end

@interface VIPhotoView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapGestureRecognizer;

@property (nonatomic) BOOL rotating;
@property (nonatomic) BOOL needLayout;
@property (nonatomic) CGSize minSize;

@end

@implementation VIPhotoView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setupWithImage:nil contentMode:VIPhotoViewContentModeScaleAspectFit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [self initWithFrame:frame image:nil contentMode:VIPhotoViewContentModeScaleAspectFit]) {
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image
{
    if (self = [self initWithFrame:frame image:image contentMode:VIPhotoViewContentModeScaleAspectFit]) {
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image contentMode:(VIPhotoViewContentMode)contentMode {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupWithImage:image contentMode:contentMode];
    }
    
    return self;
}

- (void)setupWithImage:(UIImage *)image contentMode:(VIPhotoViewContentMode)contentMode {
    self.delegate = self;
    self.bouncesZoom = YES;
    
    // Add container view
    UIView *containerView = [[UIView alloc] initWithFrame:self.bounds];
    containerView.backgroundColor = [UIColor clearColor];
    [self addSubview:containerView];
    self.containerView = containerView;
    
    // Add image view
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = containerView.bounds;
    [containerView addSubview:imageView];
    self.imageView = imageView;
    
    // Setup display mode
    self.contentMode = contentMode;
    
    // Setup other events
    [self setupGestureRecognizer];
    [self setupRotationNotification];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.rotating || self.needLayout) {
        self.rotating = NO;
        self.needLayout = NO;
        
        // update container size
        [self setMaxMinZoomScale];
        [self updateDisplayMode];
        
        if (self.minSize.width == 0) {
            return;
        }
        
        // update container view frame
        CGSize containerSize = self.containerView.frame.size;
        BOOL containerSmallerThanSelf = (containerSize.width < CGRectGetWidth(self.bounds)) && (containerSize.height < CGRectGetHeight(self.bounds));
        
        CGSize imageSize = [self.imageView.image sizeThatFits:self.bounds.size];
        CGFloat minZoomScale = imageSize.width / self.minSize.width;
        self.minimumZoomScale = minZoomScale;
        if (containerSmallerThanSelf || self.zoomScale == self.minimumZoomScale) { // 宽度或高度 都小于 self 的宽度和高度
            self.zoomScale = minZoomScale;
        }
        
        [self updateContentInset];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Getter Setter

- (UIImage *)image {
    return _imageView.image;
}

- (void)setImage:(UIImage *)image {
    _imageView.image = image;
    _needLayout = YES;
    
    [self setNeedsLayout];
}

- (void)setContentMode:(VIPhotoViewContentMode)contentMode {
    _contentMode = contentMode;
    _needLayout = YES;
    
    [self setNeedsLayout];
}

#pragma mark - Setup

- (void)setupRotationNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
}

- (void)setupGestureRecognizer
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    tapGestureRecognizer.numberOfTapsRequired = 2;
    [self.containerView addGestureRecognizer:tapGestureRecognizer];
    self.doubleTapGestureRecognizer = tapGestureRecognizer;
}

#pragma mark - Update Content Mode

- (void)updateDisplayMode
{
    // If don't have image, do nothing.
    if (self.bounds.size.width == 0 || self.bounds.size.height == 0 ||
        self.image.size.width == 0 || self.image.size.height == 0) {
        return;
    }
    
    CGFloat widthRatio = self.image.size.width / self.bounds.size.width;
    CGFloat heightRatio = self.image.size.height / self.bounds.size.height;
    
    switch (self.contentMode) {
        case VIPhotoViewContentModeScaleAspectFit:
            [self updateViewToAspectFit];
            break;
        
        case VIPhotoViewContentModeScaleAspectFill:
            [self updateViewToAspectFill];
            break;
        
        case VIPhotoViewContentModeScaleAspectFillToTop:
            if (widthRatio < heightRatio) {
                [self updateViewToAspectFillToTop];
            } else {
                [self updateViewToAspectFill];
            }
            break;
            
        case VIPhotoViewContentModeScaleAspectFillToLeft:
            if (heightRatio < widthRatio) {
                [self updateViewToAspectFillToLeft];
            } else {
                [self updateViewToAspectFill];
            }
            break;
            
        case VIPhotoViewContentModeScaleAspectFillToRight:
            if (heightRatio < widthRatio) {
                [self updateViewToAspectFillToRight];
            } else {
                [self updateViewToAspectFill];
            }
            break;
            
        case VIPhotoViewContentModeScaleAspectFillToBottom:
            if (widthRatio < heightRatio) {
                [self updateViewToAspectFillToBottom];
            } else {
                [self updateViewToAspectFill];
            }
            break;
            
        case VIPhotoViewContentModeCenter:
            [self updateViewToCenter];
            break;
        
        default:
            [self updateViewToAspectFit];
            break;
    }
}

- (void)updateViewToAspectFit {
    CGSize imageSize = [self.imageView.image sizeThatFits:self.bounds.size];
    [self resetContainerSize:imageSize];
}

- (void)updateViewToAspectFill {
    CGSize imageSize = [self.imageView.image sizeThatFills:self.bounds.size];
    [self resetContainerSize:imageSize];
    self.contentOffset = CGPointMake((imageSize.width - self.bounds.size.width) / 2, (imageSize.height - self.bounds.size.height) / 2);
}

- (void)updateViewToAspectFillToTop {
    CGSize imageSize = [self.imageView.image sizeThatFills:self.bounds.size];
    [self resetContainerSize:imageSize];
    self.contentOffset = CGPointMake(imageSize.width - self.bounds.size.width, 0);
}

- (void)updateViewToAspectFillToLeft {
    CGSize imageSize = [self.imageView.image sizeThatFills:self.bounds.size];
    [self resetContainerSize:imageSize];
    self.contentOffset = CGPointMake(0, (imageSize.height - self.bounds.size.height) / 2);
}

- (void)updateViewToAspectFillToRight {
    CGSize imageSize = [self.imageView.image sizeThatFills:self.bounds.size];
    [self resetContainerSize:imageSize];
    self.contentOffset = CGPointMake(imageSize.width - self.bounds.size.width, (imageSize.height - self.bounds.size.height) / 2);
}

- (void)updateViewToAspectFillToBottom {
    CGSize imageSize = [self.imageView.image sizeThatFills:self.bounds.size];
    [self resetContainerSize:imageSize];
    self.contentOffset = CGPointMake(0, imageSize.height - self.bounds.size.height);
}

- (void)updateViewToCenter {
    CGSize imageSize = self.imageView.image.size;
    [self resetContainerSize:imageSize];
    self.contentOffset = CGPointMake((imageSize.width - self.bounds.size.width) / 2, (imageSize.height - self.bounds.size.height) / 2);
}

- (void)resetContainerSize:(CGSize)size {
    self.containerView.frame = CGRectMake(0, 0, size.width, size.height);
    self.imageView.bounds = CGRectMake(0, 0, size.width, size.height);
    self.imageView.center = CGPointMake(size.width / 2, size.height / 2);
    
    self.contentSize = size;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.containerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self updateContentInset];
}

#pragma mark - GestureRecognizer

- (void)tapHandler:(UITapGestureRecognizer *)recognizer
{
    if (self.zoomScale > self.minimumZoomScale) {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    } else if (self.zoomScale < self.maximumZoomScale) {
        CGPoint location = [recognizer locationInView:recognizer.view];
        CGRect zoomToRect = CGRectMake(0, 0, 50, 50);
        zoomToRect.origin = CGPointMake(location.x - CGRectGetWidth(zoomToRect)/2, location.y - CGRectGetHeight(zoomToRect)/2);
        [self zoomToRect:zoomToRect animated:YES];
    }
}

#pragma mark - Notification

- (void)orientationChanged:(NSNotification *)notification
{
    self.rotating = YES;
}

#pragma mark - Helper

- (void)setMaxMinZoomScale
{
    CGSize imageSize = self.imageView.image.size;
    CGSize imagePresentationSize = [self.imageView.image sizeThatFits:self.bounds.size];
    CGFloat maxScale = MAX(imageSize.height / imagePresentationSize.height, imageSize.width / imagePresentationSize.width);
    self.maximumZoomScale = MAX(1, maxScale); // Should not less than 1
    self.minimumZoomScale = 1.0;
    self.minSize = imagePresentationSize;   // Controls minimum size
}

- (void)updateContentInset
{
    if (self.contentMode == VIPhotoViewContentModeScaleAspectFit) {
        CGRect frame = self.containerView.frame;
        
        CGFloat top = 0, left = 0;
        if (self.contentSize.width < self.bounds.size.width) {
            left = (self.bounds.size.width - self.contentSize.width) * 0.5f;
        }
        if (self.contentSize.height < self.bounds.size.height) {
            top = (self.bounds.size.height - self.contentSize.height) * 0.5f;
        }
        
        top -= frame.origin.y;
        left -= frame.origin.x;
        
        self.contentInset = UIEdgeInsetsMake(top, left, top, left);
    }else{
        // container is fill
        self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
}

@end
