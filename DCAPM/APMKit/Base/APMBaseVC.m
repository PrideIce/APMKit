//
//  APMBaseVC.m
//  APM
//
//  Created by 陈逸辰 on 2020/3/12.
//

#import "APMBaseVC.h"

@interface APMBaseVC ()

@end

@implementation APMBaseVC

+ (instancetype)instanceFromXib
{
    id vc = [[self alloc] initWithNibName:NSStringFromClass(self.class) bundle:[NSBundle bundleForClass:self.class]];
    return vc;
}

+ (instancetype)instanceFromStoryBoard
{
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"APM" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    id instance = [[UIStoryboard storyboardWithName:@"APM" bundle:bundle] instantiateViewControllerWithIdentifier:NSStringFromClass(self.class)];
    return instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
}


@end
