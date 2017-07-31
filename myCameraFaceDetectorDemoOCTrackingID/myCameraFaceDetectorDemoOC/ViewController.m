//
//  ViewController.m
//  myCameraFaceDetectorDemoOC
//
//  Created by NowOrNever on 18/07/2017.
//  Copyright © 2017 Focus. All rights reserved.
//

#import "ViewController.h"
#import "AVCaptireVideoPicController.h"
@interface ViewController ()

@end

@implementation ViewController


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [self.view addSubview:btn];
    btn.center = self.view.center;
    [btn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)btnAction{
    UIViewController *vc = [[AVCaptireVideoPicController alloc]init];
    [self presentViewController:vc animated:true completion:nil];
}

@end
