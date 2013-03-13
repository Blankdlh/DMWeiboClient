//
//  SelectedImageViewController.m
//  DMWeiboClient
//
//  Created by Blank on 13-1-16.
//  Copyright (c) 2013年 戴 立慧. All rights reserved.
//

#import "SelectedImageViewController.h"

@interface SelectedImageViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation SelectedImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.imageView.image = self.image;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setImageView:nil];
    [super viewDidUnload];
}
- (IBAction)btnDelete:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
    if ([self.delegate respondsToSelector:@selector(didTouchedDeleteButton)]) {
        [self.delegate didTouchedDeleteButton];
    }
}
@end
