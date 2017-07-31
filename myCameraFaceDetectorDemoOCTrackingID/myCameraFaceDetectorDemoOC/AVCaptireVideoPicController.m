//
//  AVCaptireVideoPicController.m
//  myCameraFaceDetectorDemoOC
//
//  Created by NowOrNever on 19/07/2017.
//  Copyright © 2017 Focus. All rights reserved.
//

#import "AVCaptireVideoPicController.h"
#import <AVFoundation/AVFoundation.h>
@interface AVCaptireVideoPicController ()<AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDevice *captureDevice;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, assign) BOOL isStart;

@property (nonatomic, strong) CIDetector *detector;

//@property (nonatomic, strong) UIImageView *testImageView;
@end

@implementation AVCaptireVideoPicController

#pragma mark: lazyLoad
- (CIDetector *)detector{
    if (!_detector) {
        _detector = [CIDetector  detectorOfType:CIDetectorTypeFace context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh,CIDetectorMinFeatureSize:[[NSNumber alloc]initWithFloat:0.2],CIDetectorTracking:[NSNumber numberWithBool:YES]}];
    }
    return _detector;
}

- (AVCaptureSession *)captureSession{
    if (!_captureSession) {
        _captureSession = [[AVCaptureSession alloc] init];
    }
    return _captureSession;
}

- (UIView *)maskView{
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _maskView.backgroundColor = [UIColor clearColor];
    }
    return _maskView;
}

#pragma mark:viewDidLoad and setup
//- (UIImageView *)testImageView{
//    if (!_testImageView) {
//        _testImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 360, 480)];
//    }
//    return _testImageView;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI{
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    NSArray<AVCaptureDevice *> *devices = [AVCaptureDevice devices];
    for (AVCaptureDevice *device in devices) {
        if ([device hasMediaType:AVMediaTypeVideo]) {
            if (device.position == AVCaptureDevicePositionFront) {
                self.captureDevice = device;
                NSLog(@"Device found");
                [self beginSession];
            }
        }
    }
    
    
    [self.view addSubview:self.maskView];
//    [self.view addSubview:self.testImageView];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(start) userInfo:nil repeats:false];
}

- (void)beginSession{
    NSLog(@"beginSession");
    NSError *error;
    AVCaptureDeviceInput *deviceInput = [[AVCaptureDeviceInput alloc]initWithDevice:self.captureDevice error:&error];
    if ([self.captureSession canAddInput:deviceInput]) {
        [self.captureSession addInput:deviceInput];
    }else{
        NSLog(@"add input error");
    }
    
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    dispatch_queue_t cameraQueue = dispatch_queue_create("cameraQueue", DISPATCH_QUEUE_SERIAL);
    [output setSampleBufferDelegate:self queue:cameraQueue];
    //    output.videoSettings = @{(__bridge NSString *)kCVPixelBufferPixelFormatTypeKey : [NSString stringWithFormat:@"%u",(unsigned int)kCVPixelFormatType_32BGRA]};
    output.videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithUnsignedInteger:kCVPixelFormatType_32BGRA],
                            kCVPixelBufferPixelFormatTypeKey,
                            nil];
//  @{(__bridge NSString *)kCVPixelBufferPixelFormatTypeKey:[NSNumber numberWithUnsignedInteger:kCVPixelFormatType_32BGRA]};
    [self.captureSession addOutput:output];
    
    if (error) {
        NSLog(@"error:%@",error.description);
    }
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    self.previewLayer.videoGravity = @"AVLayerVideoGravityResizeAspect";
    self.previewLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.previewLayer];
    [self.captureSession startRunning];
}

- (void)start{
    self.isStart = true;
}

#pragma mark: AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    if (self.isStart) {
        UIImage *resultImage = [self sampleBufferToImage:sampleBuffer];
        resultImage = [self fixOrientation:resultImage];
                
        CGFloat scale = [UIScreen mainScreen].bounds.size.width / resultImage.size.width;
        CGFloat topMargin = ([UIScreen mainScreen].bounds.size.height - resultImage.size.height * scale) * 0.5;
        

        
        CIImage *ciImage = [[CIImage alloc] initWithImage:resultImage];
        NSArray<CIFaceFeature *> *results = (NSArray<CIFaceFeature *> *) [self.detector featuresInImage:ciImage options:@{CIDetectorImageOrientation:[[NSNumber alloc]initWithInt:1]}];
        
//        NSArray<CIFaceFeature *> *results = (NSArray<CIFaceFeature *> *) [detector featuresInImage:ciImage];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.testImageView.image = resultImage;
//        });
        
        for (CIFaceFeature *face in results) {
            NSLog(@"face.trackingID = %d",face.trackingID);
            NSLog(@"face.trackingFrameCount = %d",face.trackingFrameCount);
        
            
//            CALayer *smallfaceLayer = [self getRedLayer];
//            //            faceLayer.frame = face.bounds;
//
//            //          testView
//            smallfaceLayer.frame = CGRectMake(face.bounds.origin.x,self.testImageView.bounds.size.height - face.bounds.origin.y - face.bounds.size.height, face.bounds.size.width, face.bounds.size.height);
//            CALayer *smallMouthLayer = [self getRedLayer];
//            smallMouthLayer.frame = CGRectMake(face.mouthPosition.x - 5,self.testImageView.bounds.size.height - (face.mouthPosition.y - 5), 10, 10);
//            CALayer *samllLeftEyesLayer = [self getRedLayer];
//            samllLeftEyesLayer.frame = CGRectMake(face.leftEyePosition.x - 5, self.testImageView.bounds.size.height - (face.leftEyePosition.y - 5), 10, 10);
//
            
            
            
            CALayer *faceLayer = [self getRedLayer];
            faceLayer.frame = CGRectMake(face.bounds.origin.x * scale,topMargin + resultImage.size.height * scale - face.bounds.origin.y * scale - face.bounds.size.height * scale, face.bounds.size.width * scale, face.bounds.size.height * scale);
            
            CGFloat halfWidth = 5;
            CALayer *mouthLayer = [self getRedLayer];
            mouthLayer.frame = CGRectMake(face.mouthPosition.x * scale - halfWidth, topMargin + (resultImage.size.height - face.mouthPosition.y) * scale - halfWidth, halfWidth * 2, halfWidth * 2);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (self.maskView.layer.sublayers.count > 0) {
                    for (int i = (int)self.maskView.layer.sublayers.count; i > 0; i--) {
                        [self.maskView.layer.sublayers[i-1] removeFromSuperlayer];
                    }
                }
//                if (self.testImageView.layer.sublayers.count > 0) {
//                    for (int i = (int)self.testImageView.layer.sublayers.count; i > 0; i--) {
//                        [self.testImageView.layer.sublayers[i - 1] removeFromSuperlayer];
//                    }
//                }
                
//                [self.testImageView.layer addSublayer:smallfaceLayer];
//                [self.testImageView.layer addSublayer:smallMouthLayer];
//                [self.testImageView.layer addSublayer:samllLeftEyesLayer];
                [self.maskView.layer addSublayer:faceLayer];
                [self.maskView.layer addSublayer:mouthLayer];
            });
        }
        
        
    }
}

- (CALayer *)getRedLayer{
    CALayer *redLayer = [[CALayer alloc] init];
    redLayer.borderWidth = 2;
    redLayer.borderColor = [UIColor redColor].CGColor;
    return redLayer;
}


- (UIImage *)sampleBufferToImage:(CMSampleBufferRef)sampleBuffer{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext createCGImage:ciImage fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(imageBuffer), CVPixelBufferGetHeight(imageBuffer))];
    UIImage *result = [[UIImage alloc] initWithCGImage:videoImage scale:1.0 orientation:UIImageOrientationLeftMirrored];
    CGImageRelease(videoImage);    
    return result;
}


- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    [self.captureSession stopRunning];
}

@end
