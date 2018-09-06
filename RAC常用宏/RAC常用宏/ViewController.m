//
//  ViewController.m
//  RAC常用宏
//
//  Created by 王帅 on 16/4/18.
//  Copyright © 2016年 Mr.wang. All rights reserved.
//

#import "ViewController.h"
#import "ReactiveObjC.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic, strong) RACSignal *signal;

@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self testTextField];
}

/**
 *  KVO
 *  RACObserveL:快速的监听某个对象的某个属性改变
 *  center:属性
 *  返回的是一个信号,对象的某个属性改变的信号
 */
#pragma mark -------KVO
- (void)testKVO {
    [RACObserve(self.view, center) subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
}
/** 监听textfield输入 */
#pragma mark -------监听textfield输入
- (void)testTextField
{
    RAC(self.label, text) = self.textField.rac_textSignal;
    [RACObserve(self.label, text) subscribeNext:^(id x) {
    }];
    [_textField.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"%@",x);
        NSLog(@"====label的文字变了");
        _label.text = x;
    }];
}

/**
 *  循环引用问题
 */
#pragma mark -------循环引用问题
- (void)test3 {
    @weakify(self)
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        NSLog(@"%@",self.view);
        return nil;
    }];
    _signal = signal;
}

/**
 * 元祖
 * 快速包装一个元组
 * 把包装的类型放在宏的参数里面,就会自动包装
 */
#pragma mark -------元祖
- (void)test4 {
    RACTuple *tuple = RACTuplePack(@1,@2,@4);
    // 宏的参数类型要和元祖中元素类型一致， 右边为要解析的元祖。
    RACTupleUnpack_(NSNumber *num1, NSNumber *num2, NSNumber * num3) = tuple;// 4.元祖
    // 快速包装一个元组
    // 把包装的类型放在宏的参数里面,就会自动包装
    NSLog(@"%@ %@ %@", num1, num2, num3);
    
}

/** UIButton自带block */
// 按钮（点击按钮让灰色view变成红色）
#pragma mark -------UIButton自带block
-(void)testButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.view addSubview:button];
    button.frame = CGRectMake(30, 130, 90, 40);
    [button setTitle:@"点击变红" forState:UIControlStateNormal];
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [button setBackgroundColor:[UIColor redColor]];
    }];
}

#pragma mark ---------通知
-(void)testNSNotificationCenter
{
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardDidShowNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        NSLog(@"%@",x);
    }];
}
#pragma mark ---------代替代理（类似block）
- (void)replaceDelegate{
    /** 父类监听 */
//    [_greenView.btnClickSignal subscribeNext:^(id  _Nullable x) {
//        NSLog(@"%@",x);
//    }];
    /** 子类中初始化 */
//    @property (nonatomic,strong) RACSubject *btnClickSignal;
//    - (RACSubject *)btnClickSignal{
//        if (!_btnClickSignal) {
//            _btnClickSignal = [RACSubject subject];
//        }
//        return _btnClickSignal;
//    }
    /** 发送 */
//    - (IBAction)btnClick:(id)sender{
//        [_btnClickSignal sendNext:@"我可以代替代理哦"];
//    }
}
#pragma mark ---------延迟
- (void)testAfterTime{
    RACSignal *siganl = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"等等我,我还有10s就到了");
        [subscriber sendNext:@"北极"];
        [subscriber sendCompleted];
        return nil;
    }];
    //延迟10s接受next的玻璃球
    [[siganl delay:10] subscribeNext:^(id x) {
        NSLog(@"我到了%@",x);
    }];
}
#pragma mark ---------重放
- (void)testReplay{
    RACSignal *siganl = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"电影");
        [subscriber sendNext:@"电影"];
        [subscriber sendCompleted];
        return nil;
    }];
    //创建该普通信号的重复信号
    RACSignal *replaySiganl = [siganl replay];
    //重复接受信号
    [replaySiganl subscribeNext:^(NSString *x) {
        NSLog(@"小米%@",x);
    }];
    [replaySiganl subscribeNext:^(NSString *x) {
        NSLog(@"小红%@",x);
    }];
}

#pragma mark ---------定时
- (void)testInterval{
    //创建定时器信号.定时8小时
    RACSignal *siganl = [RACSignal interval:60 * 60 * 8 onScheduler:[RACScheduler mainThreadScheduler]];
    //定时器执行代码
    [siganl subscribeNext:^(id x) {
        NSLog(@"吃药");
        
    }];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
