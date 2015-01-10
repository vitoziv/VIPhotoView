# VIPhotoView 

VIPhotoView is a view use to view a photo with simple and basic interactive gesture. Pinch to scale photo, double tap to scale photo, drag to scoll photo. 


## Screenshot
![demo.gif](http://i.imgur.com/7XdCsHb.gif)

## Installation

**Cocoapods**

`pod 'VIPhotoView', '~> 0.1'`

## Usage

Init VIPhotoView with frame and image, than add it to a view.

```Objc
- (void)viewDidLoad {
    [super viewDidLoad];

    UIImage *image = [UIImage imageNamed:@"test.jpg"];
    VIPhotoView *photoView = [[VIPhotoView alloc] initWithFrame:self.view.bounds andImage:image];
    photoView.autoresizingMask = (1 << 6) -1;
    
    [self.view addSubview:photoView];
}
```

##License

VIPhotoView is released under the MIT license.