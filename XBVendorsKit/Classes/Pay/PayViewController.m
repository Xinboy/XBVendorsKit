//
//  PayViewController.m
//  temp
//
//  Created by Xinbo Hong on 2019/1/12.
//  Copyright © 2019年 Xinbo. All rights reserved.
//

#import "PayViewController.h"
#import "PayTypeCell.h"
#import "Masonry.h"

#import <WXApi.h>
#import <AlipaySDK/AlipaySDK.h>

static NSString *const kWXPayResultNotificationKey = @"kWXPayResultNotificationKey";
static NSString *const kAliPayResultNotificationKey  = @"kAliPayResultNotificationKey";

@interface PayViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *headerBgView;

@property (nonatomic, strong) UILabel *moneyLabel;

@property (nonatomic, strong) UITextField *moneyTextField;

@property (nonatomic, strong) UILabel *payTypeLabel;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIButton *payButton;

@property (nonatomic, strong) PayTypeCell *lastSelectedCell;

@property (nonatomic, strong) NSArray *payTypeArray;
@end

@implementation PayViewController

#pragma mark - --- Life Cycle ---
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.navigationItem.title = <#导航栏名字#>;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wxpayResult:) name:kWXPayResultNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alipayResult:) name:kAliPayResultNotificationKey object:nil];
    
    self.payTypeArray = @[@{kIconImageNameKey: [UIImage imageNamed:@"alipay"],
                            kPayTypeNameKey: @"支付宝",
                            kPayTypeDescKey: @"使用支付宝支付",
                            kSelectedImageNameKey : [UIImage imageNamed:@"pay_type_normal"]},
                          @{kIconImageNameKey: [UIImage imageNamed:@"wxpay"],
                            kPayTypeNameKey: @"微信",
                            kPayTypeDescKey: @"使用微信支付",
                            kSelectedImageNameKey : [UIImage imageNamed:@"pay_type_normal"]}];
    
    self.view.backgroundColor = [UIColor colorWithWhite:246 / 255.0 alpha:1.0];
    
    [self.view addSubview:self.headerBgView];
    [self.headerBgView addSubview:self.moneyLabel];
    [self.headerBgView addSubview:self.moneyTextField];
    
    [self.view addSubview:self.payTypeLabel];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.payButton];
    
    [self setupUI];
    [self.view layoutSubviews];
    [self setupUIAfterLayout];
    
    [self showDataFromService];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

}
#pragma mark - --- Delegate ---
#pragma mark - --- TableView Delegate And Datasource ---
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.payTypeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PayTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    [cell showWithData:self.payTypeArray[indexPath.row]];
    
    if (indexPath.row == 0) {
        self.lastSelectedCell = cell;
        cell.cellSelected = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PayTypeCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.cellSelected = YES;
    self.lastSelectedCell.cellSelected = NO;
    
    self.lastSelectedCell = cell;
    
}
#pragma mark - --- Event Response ---
- (void)sendWxPay {
    if (![WXApi isWXAppInstalled]) {
        //微信未安装
        return;
    }
    PayReq *req = [[PayReq alloc] init];
    //    req.partnerId = model.partnerid;
    //    req.prepayId = model.prepayid;
    //    req.nonceStr = model.noncestr;
    //    req.timeStamp = model.timestamp;
    //    req.package = model.pay_package;
    //    req.sign = model.sign;
    [WXApi sendReq:req];
}

- (void)wxpayResult:(NSNotification *)notif {
    BaseResp *resp = [notif.userInfo objectForKey:@"resp"];
    NSString *memo;
    if([resp isKindOfClass:[PayResp class]]) {
        switch (resp.errCode) {
            case WXSuccess:
                memo = @"支付成功";
                break;
            case WXErrCodeCommon:
                memo = @"支付错误";
                break;
            case WXErrCodeUserCancel:
                memo = @"用户取消";
                break;
            default:
                memo = resp.errStr;
                break;
        }
    }
    
}

- (void)sendAliPAy {
    [[AlipaySDK defaultService] payOrder:@"" fromScheme:@"temp" callback:^(NSDictionary *resultDic) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kAliPayResultNotificationKey object:nil userInfo:@{@"resultDic":resultDic}];
    }];
}


- (void)alipayResult:(NSNotification *)notif {
    NSDictionary *resultDict = [notif.userInfo objectForKey:@"resultDic"];
    NSString *resultStatus = resultDict[@"resultStatus"];
    NSString *memo;
    switch ([resultStatus integerValue]) {
        case 9000:
            memo = @"支付成功!";
            break;
        case 4000:
            memo = @"订单支付失败!";
            break;
        case 6001:
            memo = @"用户中途取消!";
            break;
        case 6002:
            memo = @"网络连接出错!";
            break;
        case 8000:
            memo = @"正在处理中...";
            break;
        default:
            memo = [resultDict objectForKey:@"memo"];
            break;
    }
}

#pragma mark - --- Private Methods ---
- (void)showDataFromService {
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:kWXPayResultNotificationKey];
    [[NSNotificationCenter defaultCenter] removeObserver:kAliPayResultNotificationKey];
}
#pragma mark - --- SetupUI ---
- (void)setupUI {
    
    [self.headerBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(88);
        make.height.mas_equalTo(150);
    }];
    
    [self.moneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerBgView).offset(11);
        make.top.equalTo(self.headerBgView).offset(22);
        make.height.mas_equalTo(20);
    }];
    
    [self.moneyTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.moneyLabel);
        make.top.equalTo(self.moneyLabel.mas_bottom).offset(30);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width - 20);
        make.height.mas_equalTo(44);
    }];
    
    [self.payTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(11);;
        make.top.equalTo(self.headerBgView.mas_bottom).offset(50);
        make.width.equalTo(self.view);
        make.height.mas_equalTo(44);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.payTypeLabel.mas_bottom);
    }];
    
    [self.payButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(88);
        make.height.mas_equalTo(44);
        make.bottom.equalTo(self.view.mas_bottom).offset(-30);
    }];
}

- (void)setupUIAfterLayout {
    self.payButton.layer.masksToBounds = YES;
    self.payButton.layer.cornerRadius = CGRectGetHeight(self.payButton.frame) * 0.5;
    
}
#pragma mark - --- Getters and Setters ---
- (UIView *)headerBgView {
    if (!_headerBgView) {
        self.headerBgView = [[UIView alloc] init];
        self.headerBgView.backgroundColor = [UIColor whiteColor];
        self.headerBgView.userInteractionEnabled = YES;
    }
    return _headerBgView;
}


- (UILabel *)moneyLabel {
    if (!_moneyLabel) {
        self.moneyLabel = [[UILabel alloc] init];
        self.moneyLabel.textColor = [UIColor colorWithWhite:48 / 255.0 alpha:1.0];
        self.moneyLabel.font = [UIFont systemFontOfSize:18];
        self.moneyLabel.text = @"充值金额";
        [self.moneyLabel sizeToFit];
    }
    return _moneyLabel;
}

- (UITextField *)moneyTextField {
    if (!_moneyTextField) {
        self.moneyTextField = [[UITextField alloc] init];
        self.moneyTextField.borderStyle = UITextBorderStyleNone;
        self.moneyTextField.keyboardType = UIKeyboardTypeDecimalPad;
        self.moneyTextField.font = [UIFont systemFontOfSize:30];
        self.moneyTextField.textColor = [UIColor colorWithWhite:48 / 255.0 alpha:1.0];
        
        UILabel *leftView = [[UILabel alloc] init];
        leftView.frame = CGRectMake(0, 0, 44, 44);
        leftView.font = [UIFont systemFontOfSize:30];
        leftView.textColor = [UIColor colorWithWhite:48 / 255.0 alpha:1.0];
        leftView.text = @"￥";
        self.moneyTextField.leftView = leftView;
        self.moneyTextField.leftViewMode = UITextFieldViewModeAlways;
    }
    return _moneyTextField;
}

- (UILabel *)payTypeLabel {
    if (!_payTypeLabel) {
        self.payTypeLabel = [[UILabel alloc] init];
        self.payTypeLabel.backgroundColor = [UIColor whiteColor];
        self.payTypeLabel.textColor = [UIColor colorWithWhite:48 / 255.0 alpha:1.0];
        self.payTypeLabel.font = [UIFont systemFontOfSize:18];
        self.payTypeLabel.text = @"请选择支付方式";
        
    }
    return _payTypeLabel;
}

- (UITableView *)tableView {
    if (!_tableView) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.tableFooterView = [UIView new];
        [self.tableView registerClass:[PayTypeCell class] forCellReuseIdentifier:@"Cell"];
        self.tableView.rowHeight = 88;
    }
    return _tableView;
}

-(UIButton *)payButton {
    if (!_payButton) {
        self.payButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.payButton setTitle:@"支付" forState:UIControlStateNormal];
        [self.payButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        self.payButton.backgroundColor = [UIColor orangeColor];
    }
    return _payButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
@end
