//
//  RequestViewModel.h
//  ReactiveCocoa
//
//  Created by Mr.Wang on 16/4/20.
//  Copyright © 2016年 yz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReactiveObjC.h"
#import "AFNetworking.h"

@interface RequestViewModel : NSObject{
    NSDictionary *_parametersDic;
}

@property(nonatomic,strong)NSDictionary *parameters;
@property(nonatomic, strong, readonly)RACCommand *requestCommand;/** 为了避免外部修改，可以使用readOnly */

@end
