//
//  ViewController.m
//  coregraphicspractice
//
//  Created by 鑫容 郭 on 11-12-20.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "CustomView.h"

@implementation ViewController

@synthesize customView = _customView;
@synthesize xslider = _xslider;
@synthesize yslider = _yslider;
@synthesize zslider = _zslider;
@synthesize xlabel = _xlabel;
@synthesize ylabel = _ylabel;
@synthesize zlabel = _zlabel;
@synthesize anglelabel = _anglelabel;
@synthesize angleslider = _angleslider;

@synthesize imageView = _imageView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    shouldMoveCustomView = NO;
    
    _imageView.userInteractionEnabled = YES;
    
    
    _xslider.maximumValue = _yslider.maximumValue = _zslider.maximumValue = 2*M_PI;//5;
    _xslider.minimumValue = _yslider.minimumValue = _zslider.minimumValue = 0;//-5;
    _angleslider.maximumValue = 2;
    _angleslider.minimumValue = -2;
    
    _xslider.value = _yslider.value = _zslider.value = _angleslider.value = 0;
    
    _customView = [[CustomView alloc] initWithFrame:CGRectMake(100, 100, 200, 200)];
    //_customView.center = CGPointMake(179, 47);
    [_imageView addSubview:_customView];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerHandler:)];
    [_imageView addGestureRecognizer:panGesture];
    [panGesture release];
    

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)sliderChanged:(id)sender {
    /*_xlabel.text = [NSString stringWithFormat:@"%f", _xslider.value];
    _ylabel.text = [NSString stringWithFormat:@"%f", _yslider.value];
    _zlabel.text = [NSString stringWithFormat:@"%f", _zslider.value];
    
    _anglelabel.text = [NSString stringWithFormat:@"%fPI", _angleslider.value];*/
    
    [_customView make3DRotationAngle:_angleslider.value * M_PI x:_xslider.value y:_yslider.value z:_zslider.value];
    
    _xlabel.text = [NSString stringWithFormat:@"%f", _xslider.value];
    _ylabel.text = [NSString stringWithFormat:@"%f", _yslider.value];
    _zlabel.text = [NSString stringWithFormat:@"%f", _zslider.value];
    
    _anglelabel.text = [NSString stringWithFormat:@"%fPI", _angleslider.value];
    
    [_customView treedrorateX:_xslider.value Y:_yslider.value Z:_zslider.value];

    
}

- (void)panGestureRecognizerHandler:(UIPanGestureRecognizer *)panGestureRecognizer {
    if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        if ([[self.view hitTest:[panGestureRecognizer locationInView:self.view] withEvent:UIEventTypeTouches] isKindOfClass:[CustomView class]]) {
            _customView.center = [panGestureRecognizer locationInView:self.view];
        }
    }
    
}


@end
