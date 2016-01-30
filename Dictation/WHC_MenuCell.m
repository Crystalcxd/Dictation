//
//  WHC_MenuCell.m
//  Dictation
//
//  Created by Michael on 16/1/5.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import "WHC_MenuCell.h"

#define KWHC_MENUCELL_ANMATION_PADING (10.0)

@interface WHC_MenuCell ()<UIGestureRecognizerDelegate>{
    BOOL                                  _isOpen;              //是否打开菜单
    BOOL                                  _isScorllClose;       //是否滚动关闭菜单
    CGFloat                               _startX;              //存储拉开菜单开始触摸x坐标
    UIView                              * _menuView;            //菜单view
    UIPanGestureRecognizer              * _panGesture;          //手势
}

@end

@implementation WHC_MenuCell

//初始化UI
- (void)initUI{
    _panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGesture:)];
    _panGesture.delegate = self;
    [self.contentView addGestureRecognizer:_panGesture];
    
    UITapGestureRecognizer  * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapGestrue:)];
    tapGesture.delegate = self;
    [self.contentView addGestureRecognizer:tapGesture];
    
    if(_menuItemTitles == nil){
        _menuItemTitles = @[];
    }
    if(_menuItemBackImages == nil){
        _menuItemBackImages = @[];
    }
    if(_menuItemBackColors == nil){
        _menuItemBackColors = @[[UIColor redColor]];
    }
    if(_menuItemTitleColors == nil){
        _menuItemTitleColors = @[[UIColor blackColor]];
    }
    if(_menuItemWidths == nil){
        _menuItemWidths = @[];
    }
    if(_menuItemNormalImages == nil){
        _menuItemNormalImages = @[];
    }
    if(_menuItemSelectedImages == nil){
        _menuItemSelectedImages = @[];
    }
    
    CGFloat  _menuViewX = CGRectGetWidth(_ContentView.frame) - _menuViewWidth;
    _menuView = [[UIView alloc]initWithFrame:CGRectMake(_menuViewX + CGRectGetMinX(_ContentView.frame), 0.0, _menuViewWidth, CGRectGetHeight(_ContentView.frame))];
    _menuView.backgroundColor = [UIColor clearColor];
    [self.contentView insertSubview:_menuView belowSubview:_ContentView];
    
    NSInteger menuItemCount = _menuItemTitles.count;
    NSInteger menuBackImageCount = _menuItemBackImages.count;
    NSInteger menuBackColorCount = _menuItemBackColors.count;
    NSInteger menuTitleColorCount = _menuItemTitleColors.count;
    NSInteger menuItemWidthCount = _menuItemWidths.count;
    NSInteger menuItemNormalImageCount = _menuItemNormalImages.count;
    NSInteger menuItemSelectedImageCount = _menuItemSelectedImages.count;
    CGFloat btnWidth = _menuViewWidth / (CGFloat)menuItemCount;
    
    CGFloat (^currentWidth)(NSInteger i) = ^(NSInteger i){
        CGFloat  width = 0.0;
        for (NSInteger j = 0; j <= i ; j++) {
            width += [_menuItemWidths[j] floatValue];
        }
        return width;
    };
    
    //创建菜单按钮
    for (NSInteger i = 0; i < menuItemCount; i++) {
        UIButton  * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i;
        CGRect btnRc = CGRectMake(i * btnWidth, 0.0, btnWidth, CGRectGetHeight(_ContentView.frame));
        btn.frame = btnRc;
        if(menuItemWidthCount == menuItemCount){
            
            btnRc.origin.x = currentWidth(i - 1);
            btnRc.size.width = [_menuItemWidths[i] floatValue];
            btn.frame = btnRc;
        }
        [btn setTitle:_menuItemTitles[i] forState:UIControlStateNormal];
        NSInteger  titleColorIndex = i;
        if(titleColorIndex >= menuTitleColorCount){
            titleColorIndex = menuTitleColorCount - 1;
            if(titleColorIndex < 0){
                titleColorIndex = 0;
            }
        }
        if(titleColorIndex < menuTitleColorCount){
            [btn setTitleColor:_menuItemTitleColors[titleColorIndex] forState:UIControlStateNormal];
        }
        NSInteger  imageIndex = i;
        if(imageIndex >= menuBackImageCount){
            imageIndex = menuBackImageCount - 1;
            if(imageIndex < 0){
                imageIndex = 0;
            }
        }
        if(imageIndex > menuBackImageCount){
            [btn setBackgroundImage:[UIImage imageNamed:_menuItemBackImages[imageIndex]] forState:UIControlStateNormal];
        }
        
        NSInteger  colorIndex = i;
        if(colorIndex >= menuBackColorCount){
            colorIndex = menuBackColorCount - 1;
            if(colorIndex < 0){
                colorIndex = 0;
            }
        }
        if(colorIndex < menuBackColorCount){
            btn.backgroundColor = _menuItemBackColors[colorIndex];
        }
        
        if(i < menuItemNormalImageCount){
            NSString  * imageName = _menuItemNormalImages[i];
            if(imageName != nil && imageName.length){
                [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
            }
            
            if(i < menuItemSelectedImageCount){
                NSString  * selectedImageName = _menuItemSelectedImages[i];
                if(selectedImageName != nil && selectedImageName.length){
                    [btn setImage:[UIImage imageNamed:selectedImageName] forState:UIControlStateHighlighted];
                }
            }
        }
        btn.titleLabel.minimumScaleFactor = 0.1;
        btn.titleLabel.adjustsFontSizeToFitWidth = YES;
        if(_fontSize == 0.0){
            _fontSize = 18.0;
        }
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:_fontSize];
        [btn addTarget:self action:@selector(clickMenuItem:) forControlEvents:UIControlEventTouchUpInside];
        [_menuView addSubview:btn];
    }
}


//加载xib
- (void)awakeFromNib{
    [self initUI];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self initUI];
    }
    return self;
}

//设置滚动列表时菜单关闭状态
- (void)setIsScrollClose{
    _isScorllClose = NO;
}

//下面两个方法有子类实现属于触摸监听方法
- (void)startScrollviewCell:(BOOL)state x:(CGFloat)moveX{}
- (void)didEndScrollViewCell:(BOOL)state{}

//单击菜单项
- (void)clickMenuItem:(UIButton *)sender{
    [self closeCellWithAnimation:YES];
}

//批量关闭tableview上得多个cell菜单
- (BOOL)closeCellWithTableView:(UITableView*)tableView index:(NSInteger)index animation:(BOOL)b{
    
    NSArray  * indexPathArr = [tableView indexPathsForVisibleRows];
    BOOL  handleResult = NO;
    for (NSIndexPath * indexPath in indexPathArr) {
        if(_index != indexPath.row && index > -1){
            
            WHC_MenuCell * cell = (WHC_MenuCell *)[tableView cellForRowAtIndexPath:indexPath];
            [cell setIsScrollClose];
            if([cell closeCellWithAnimation:b]){
                handleResult = YES;
            }
        }else if(index <= -1){
            
            WHC_MenuCell * cell = (WHC_MenuCell *)[tableView cellForRowAtIndexPath:indexPath];
            if(_index != indexPath.row){
                [cell setIsScrollClose];
            }
            if([cell closeCellWithAnimation:b]){
                handleResult = YES;
            }
        }
    }
    return handleResult;
}

//关闭cell菜单
- (BOOL)closeCellWithAnimation:(BOOL)b{
    BOOL isClose = NO;
    if(_isOpen){
        isClose = YES;
        if(b){
            [UIView animateWithDuration:0.2 animations:^{
                _ContentView.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
            }completion:^(BOOL finished) {
                _isOpen = NO;
                [self didEndScrollViewCell:_isOpen];
            }];
        }else{
            _ContentView.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
            _isOpen = NO;
            [self didEndScrollViewCell:_isOpen];
        }
    }
    return isClose;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

//手势处理
- (void)handlePanGesture:(UIPanGestureRecognizer*)panGesure{
    
    switch (panGesure.state) {
        case UIGestureRecognizerStateBegan:{
            
            _startX = _ContentView.transform.tx;
            _isScorllClose = [_delegate WHC_MenuCell:self didPullCell:_index];
        }
            break;
        case UIGestureRecognizerStateChanged:{
            if(_isScorllClose && _isOpen == NO){
                return;
            }
            CGFloat    currentX = _ContentView.transform.tx;
            CGFloat    moveDistanceX = [panGesure translationInView:panGesure.view].x;
            CGFloat    velocityX = [panGesure velocityInView:panGesure.view].x;
            CGFloat    moveX = _startX + moveDistanceX;
            
            if(velocityX > 0){//right
                if(currentX >= KWHC_MENUCELL_ANMATION_PADING){
                    [panGesure setTranslation:CGPointMake(KWHC_MENUCELL_ANMATION_PADING, 0.0) inView:panGesure.view];
                    break;
                }
            }else{
                if(currentX < -_menuViewWidth){
                    moveX = currentX - 0.4;
                    [panGesure setTranslation:CGPointMake(moveX, 0.0) inView:panGesure.view];
                }
            }
            _ContentView.transform = CGAffineTransformMakeTranslation(moveX, 0.0);
            [self startScrollviewCell:_isOpen x:moveDistanceX];
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:{
            _isScorllClose = NO;
            if(_ContentView.transform.tx > 0.0){
                
                [UIView animateWithDuration:0.2 animations:^{
                    _ContentView.transform = CGAffineTransformMakeTranslation(-KWHC_MENUCELL_ANMATION_PADING, 0.0);
                }completion:^(BOOL finished) {
                    _isOpen = NO;
                    [self didEndScrollViewCell:_isOpen];
                    [UIView animateWithDuration:0.2 animations:^{
                        _ContentView.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
                    }];
                }];
                
            }else if (_ContentView.transform.tx < 0){
                
                CGFloat  tx  = fabs(_ContentView.transform.tx);
                if(tx < _menuViewWidth / 2.0 || (tx < _menuViewWidth && _isOpen)){
                    [UIView animateWithDuration:0.2 animations:^{
                        _ContentView.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
                    }completion:^(BOOL finished) {
                        _isOpen = NO;
                        [self didEndScrollViewCell:_isOpen];
                    }];
                }else{
                    [UIView animateWithDuration:0.2 animations:^{
                        _ContentView.transform = CGAffineTransformMakeTranslation(-_menuViewWidth, 0.0);
                    }completion:^(BOOL finished) {
                        _isOpen = YES;
                        [self didEndScrollViewCell:_isOpen];
                    }];
                }
            }
        }
            break;
        default:
            break;
    }
}

- (void)handleTapGestrue:(UITapGestureRecognizer*)tapGesture{
    
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    
    if([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]){
        
        return [_delegate WHC_MenuCell:self didPullCell:-1];
        
    }else if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class] ]){
        
        UIPanGestureRecognizer  * panGesture = (UIPanGestureRecognizer*)gestureRecognizer;
        CGPoint                   velocityPoint = [panGesture velocityInView:panGesture.view];
        if(fabs(velocityPoint.x) > fabs(velocityPoint.y)){
            return YES;
        }else{
            _isScorllClose = [_delegate WHC_MenuCell:self didPullCell:-1];
            return _isScorllClose;
        }
    }
    return NO;
}

@end
