//
//  ViewController.m
//  VIPhotoViewDemo
//
//  Created by Vito on 1/7/15.
//  Copyright (c) 2015 vito. All rights reserved.
//

#import "ViewController.h"
#import "VIPhotoView.h"

@interface ViewController ()

@property (nonatomic, strong) IBOutlet  VIPhotoView *photoView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIImage *image = [UIImage imageNamed:@"test.jpg"];
    self.photoView.layer.borderWidth = 1;
    self.photoView.layer.borderColor = [UIColor blackColor].CGColor;
    self.photoView.contentMode = VIPhotoViewContentModeScaleAspectFit;
    self.photoView.image = image;
    self.photoView.autoresizingMask = (1 << 6) -1;
    
    [self.view addSubview:self.photoView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    NSLog(@"%@", NSStringFromCGRect([[[self.view subviews] lastObject] frame]));
}

- (IBAction)ScaleAspectFit:(id)sender {
    self.photoView.contentMode = VIPhotoViewContentModeScaleAspectFit;
}
- (IBAction)ScaleAspectFill:(id)sender {
    self.photoView.contentMode = VIPhotoViewContentModeScaleAspectFill;
}
- (IBAction)ScaleAspectFillToLeft:(id)sender {
    self.photoView.contentMode = VIPhotoViewContentModeScaleAspectFillToLeft;
}
- (IBAction)ScaleAspectFillToTop:(id)sender {
    self.photoView.contentMode = VIPhotoViewContentModeScaleAspectFillToTop;
}
- (IBAction)ScaleAspectFillToRight:(id)sender {
    self.photoView.contentMode = VIPhotoViewContentModeScaleAspectFillToRight;
}
- (IBAction)ScaleAspectFillToBottom:(id)sender {
    self.photoView.contentMode = VIPhotoViewContentModeScaleAspectFillToBottom;
}
- (IBAction)Center:(id)sender {
    self.photoView.contentMode = VIPhotoViewContentModeCenter;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
