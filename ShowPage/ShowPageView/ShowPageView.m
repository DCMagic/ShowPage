//
//  ShowPageView.m
//  ShowPage
//
//  Created by dongchao on 2021/9/1.
//

#import "ShowPageView.h"
#import "Masonry.h"

static NSInteger COUNTNUM = 3;

@interface ShowPageView()

@property (nonatomic, strong) UIWindow *window; // 用来展示启动图的窗口
@property (nonatomic, assign) NSInteger count;  // 用于倒计时计数
@property (nonatomic, weak) UIButton *countButton; // 跳过按钮
@property (nonatomic, strong) NSTimer *countTimer; // 倒计时

@end

@implementation ShowPageView

// 在load方法中启动监听，可以做到无调用使用
+ (void)load{
    [self shareInstance];
}

// 单例创建启动页面
+ (instancetype)shareInstance{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}



- (instancetype)init
{
    self = [super init];
    if (self) {
        
        //尽量不要在初始化的代码里面做别的事，防止对主线程的卡顿和其他情况
        //应用启动, 首次开屏广告
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            ///要等DidFinished方法结束后才能初始化UIWindow，不然会检测是否有rootViewController
            [self show];
        }];
    }
    return self;
}

- (void)show
{
    // 初始化一个window可以无干扰业务视图
    UIWindow *window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    window.rootViewController = [UIViewController new];
    window.rootViewController.view.backgroundColor = [UIColor clearColor];
    window.rootViewController.view.userInteractionEnabled = NO;
    
    //
    [self setUpSubViews:window];
    
    // 设置启动页的window为最顶层，防止覆盖
    window.windowLevel = UIWindowLevelStatusBar + 1;
    
    //windwo的isHidden默认为YES，当你设置为NO时，这个Window就会显示了
    window.hidden = NO;
    window.alpha = 1;
    //防止释放，显示完后  要手动设置为 nil
    self.window = window;
}

- (void)setUpSubViews:(UIWindow *)window
{
    UIImageView *bgImageView = [[UIImageView alloc]init];
    bgImageView.image = [UIImage imageNamed:@"ShowPage"];
    
    //增加点击事件 点击图片的时候可以实现自己想要的逻辑
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgImageViewClicked)];
    [bgImageView addGestureRecognizer:tap];
        
    [window addSubview:bgImageView];
    
    [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(window);
    }];
    
    // 设置倒计时时间
    self.count = COUNTNUM;
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 1, 1)];
    [btn addTarget:self action:@selector(removeSelf) forControlEvents:UIControlEventTouchUpInside];
    [window addSubview:btn];
    [btn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(window).offset(30 + 20);
        make.right.equalTo(window).offset(-15);
        make.height.equalTo(@40);
    }];
    
    self.countButton = btn;
    [self.countButton setTitle:[NSString stringWithFormat:@"    点击跳过 %ld    ",(long)self.count] forState:UIControlStateNormal];
    NSTimeInterval timeInterval = 1.0;
    self.countTimer = [NSTimer timerWithTimeInterval:timeInterval target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.countTimer forMode:NSRunLoopCommonModes];
    
}

// 点击图片时发生的事件
- (void)bgImageViewClicked
{
    NSLog(@"图片被点击了。。");
    //取出跳转页面之前的controller 注意： 不直接取KeyWindow 是因为当有AlertView 或者有键盘弹出时， 取到的KeyWindow是错误的。
    //UIViewController* rootVC = [[UIApplication sharedApplication].delegate window].rootViewController;
}

- (void)removeSelf
{
//    [UIView animateWithDuration:0.2 animations:^{
//        self.window.alpha = 0;
//    } completion:^(BOOL finished) {
//        [self.window.subviews.copy enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            [obj removeFromSuperview];
//        }];
//        self.window.hidden = YES;
//        self.window = nil;//手动释放
//    }];
}

- (void)updateTime
{
    self.count--;
    [self.countButton setTitle:[NSString stringWithFormat:@"    点击跳过 %ld    ",(long)self.count] forState:UIControlStateNormal];

}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
