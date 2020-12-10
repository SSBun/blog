---
title: UIViewController 的 Push,Pop 和 Present,Dismiss 转场动画
date: 2016-08-29 14:11:54
tags:
- Animation
categories:
- iOS
---

转场动画涉及到的包括导航控制器的 `Push` 动画和 `Pop` 动画，以及普通控制器的 `Present` 和 `Dismiss` 动画，主要就是通过控制器遵守 `UIViewControllerTransitioningDelegate`，并实现对应的方法，返回一个遵守 `UIViewControllerAnimatedTransitioning` 协议的对象，而主要的动画实现就是写在这个对象当中

* 如果是 Push 和 Pop 动画需要再 push 控制器和 pop 时的控制器里同时实现导航控制器的代理以实现 Push 和 Pop 的动画，而 Present 和 Dismiss 动画只需要在 Presnent 的时候设置代理，并实现 present 和 dismiss 的协议方法就OK了
* 为了方便使用，一般会封装代理返回的动画协议对象`UIViewControllerAnimatedTransitioning`，通过之类来进一步处理各种各样的转场动画

```objc
//
//  ViewController.m
//  transitionDemo
//  Copyright © 2016年 SSBun. All rights reserved.
//

#import "ViewController.h"
#import "TwoViewController.h"
#import "PushAnimator.h"
#import "PresentAnimator.h"
#import "DismissAnimator.h"

@interface ViewController ()<UIViewControllerTransitioningDelegate,UINavigationControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.delegate = self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    TwoViewController *twoVc = [[TwoViewController alloc] init];
    // Present
    twoVc.transitioningDelegate  = self;
    twoVc.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:twoVc
                       animated:YES
                     completion:^{
                     }];
    // Push
    // [self.navigationController pushViewController:twoVc animated:YES];
}

#pragma mark - 动画代理
- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC{
    
    if ([toVC isKindOfClass:[TwoViewController class]]) {
        
        PushAnimator *transition = [[PushAnimator alloc] init];
        return transition;
        
    }else{
        
        return nil;
    }
}

#pragma mark - 定制转场动画 (Present 与 Dismiss动画代理)
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    
    // 推出控制器的动画
    return [PresentAnimator new];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    
    DismissAnimator *dismissAnimator   = [DismissAnimator new];
    dismissAnimator.transitionDuration = 1.f;
    
    // 退出控制器动画
    return dismissAnimator;
}

@end
```

可以看出协议方法主要时返回了一个遵守 `<UIViewControllerAnimatedTransitioning>` 协议的对象，所以主要的重点在实现这个对象上

```objc
//  BaseAnimator.h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BaseAnimator : NSObject <UIViewControllerAnimatedTransitioning>

/**
 *  动画执行时间(默认值为0.5s)
 */
@property (nonatomic) NSTimeInterval  transitionDuration;

/**
 *  == 子类重写此方法实现动画效果 ==
 *
 *  动画事件
 */
- (void)animateTransitionEvent;

/**
 *  == 在animateTransitionEvent使用才有效 ==
 *
 *  源头控制器
 */
@property (nonatomic, readonly, weak) UIViewController *fromViewController;

/**
 *  == 在animateTransitionEvent使用才有效 ==
 *
 *  目标控制器
 */
@property (nonatomic, readonly, weak) UIViewController *toViewController;

/**
 *  == 在animateTransitionEvent使用才有效 ==
 *
 *  containerView
 */
@property (nonatomic, readonly, weak) UIView           *containerView;

/**
 *  动画事件结束
 */
- (void)completeTransition;

@end
```

```objc
//  BaseAnimator.m
#import "BaseAnimator.h"

@interface BaseAnimator ()

@property (nonatomic, weak) id <UIViewControllerContextTransitioning> transitionContext;

@property (nonatomic, weak) UIViewController  *fromViewController;
@property (nonatomic, weak) UIViewController  *toViewController;
@property (nonatomic, weak) UIView            *containerView;

@end

@implementation BaseAnimator

#pragma mark - 初始化
- (instancetype)init {
    
    self = [super init];
    if (self) {
    
        // 默认参数设置
        [self deafultSet];
    }
    
    return self;
}

- (void)deafultSet {
    
    _transitionDuration = 0.5f;
}

#pragma mark - 动画代理
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    return _transitionDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    self.fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    self.toViewController   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    self.containerView      = [transitionContext containerView];
    self.transitionContext  = transitionContext;
    
    [self animateTransitionEvent];
}

- (void)animateTransitionEvent {
    
    /* == 代码示例 ==
     
    UIView *tmpView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [self.containerView addSubview:self.toViewController.view];
    [self.containerView addSubview:tmpView];
    
    [UIView animateWithDuration:self.transitionDuration
                          delay:0.0f
         usingSpringWithDamping:1 initialSpringVelocity:0.f options:0 animations:^{
             
             tmpView.frame = CGRectMake(0, 0, 100, 100);
             
         } completion:^(BOOL finished) {
             
             [tmpView removeFromSuperview];
             [self completeTransition];
         }];
     */
}

#pragma mark -
- (void)completeTransition {

    [self.transitionContext completeTransition:!self.transitionContext.transitionWasCancelled];
}

@end
```

其中的 `fromViewController` 就是准备跳转的控制器，`toViewController` 就是要跳转到的控制器，`containerView` 是整个动画的画布，需要将要跳转到的控制器的 `view` 添加到画布上执行动画，而在 `animateTransitionEvent` 中就时具体实现动画的过程了，不要忘了还要返回动画时间，用起来的时候就看各自的发挥了，可以编写子类来实现这个方法～
