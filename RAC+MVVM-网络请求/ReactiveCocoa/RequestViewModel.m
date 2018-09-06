//
//  RequestViewModel.m
//  ReactiveCocoa
//
//  Created by Mr.Wang on 16/4/20.
//  Copyright © 2016年 yz. All rights reserved.
//

#import "RequestViewModel.h"

@implementation RequestViewModel

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

-(void)setParameters:(NSDictionary *)parameters
{
    _parametersDic = parameters;
}

/** 通过RACCommand的类来处理 */
- (void)setup {
    _requestCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        /** 执行命令 */
        /** 发送请求 */
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            /** 创建信号 把发送请求的代码包装到信号里面。 */
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            [manager GET:@"https://api.douban.com/v2/book/search" parameters:_parametersDic progress:^(NSProgress * _Nonnull downloadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [responseObject writeToFile:@"/Users/wang/Desktop/plist/sg.plist" atomically:YES];
                /** 请求成功的时候调用 */
                NSArray *dictArr = responseObject[@"books"];
                /** 遍历books字典数组，将其映射为模型数组 */
                NSArray *modelArr = [[dictArr.rac_sequence map:^id(id value) {
                    return [[NSObject alloc] init];
                }] array];
                [subscriber sendNext:modelArr];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                /** 请求失败的时候调用 */
                [subscriber sendNext:@"404"];
            }];
            return nil;
        }];        
        return signal;  /** 模型数组 */
    }];
}
@end
