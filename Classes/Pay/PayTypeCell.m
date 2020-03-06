//
//  PayTypeCell.m
//  temp
//
//  Created by Xinbo Hong on 2019/1/12.
//  Copyright © 2019年 Xinbo. All rights reserved.
//

#import "PayTypeCell.h"
#import "Masonry.h"

NSString *const kIconImageNameKey = @"kIconImageNameKey";
NSString *const kPayTypeNameKey = @"kPayTypeNameKey";
NSString *const kPayTypeDescKey = @"kPayTypeDescKey";
NSString *const kSelectedImageNameKey = @"kselectedImageNameKey";

NSString *const kNormalImageName = @"pay_type_normal";
NSString *const kSelectedImageName = @"pay_type_selected";



@interface PayTypeCell ()

@property (nonatomic, strong) UIImageView *iconImageView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *descLabel;

@property (nonatomic, strong) UIImageView *selectedImageView;

@end



@implementation PayTypeCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.iconImageView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.descLabel];
        [self.contentView addSubview:self.selectedImageView];
    }
    return self;
}

- (void)showWithData:(NSDictionary *)dataDict {
    self.iconImageView.image = dataDict[kIconImageNameKey] != nil ? dataDict[kIconImageNameKey] : nil;
    self.selectedImageView.image = dataDict[kSelectedImageNameKey] != nil ? dataDict[kSelectedImageNameKey] : nil;
    self.nameLabel.text = dataDict[kPayTypeNameKey] != nil ? dataDict[kPayTypeNameKey] : @"";
    self.descLabel.text = dataDict[kPayTypeDescKey] != nil ? dataDict[kPayTypeDescKey] : @"";
}

- (void)setCellSelected:(BOOL)cellSelected {
    _cellSelected = cellSelected;
    self.selectedImageView.image = [UIImage imageNamed:cellSelected ? kSelectedImageName: kNormalImageName];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    [self setupMasonry];
    [self.contentView layoutIfNeeded];
    
}

- (void)setupMasonry {
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(11);
        make.centerY.equalTo(self.contentView);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(40);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImageView.mas_right).offset(24);
        make.top.equalTo(self.iconImageView);
        make.width.equalTo(self.contentView).multipliedBy(0.5);
        make.height.mas_equalTo(20);
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel);
        make.top.equalTo(self.nameLabel.mas_bottom);
        make.width.equalTo(self.contentView).multipliedBy(0.5);
        make.height.mas_equalTo(20);
    }];
    
    [self.selectedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-30);
        make.centerY.equalTo(self.contentView);
        make.width.mas_equalTo(20);
        make.height.mas_equalTo(20);
    }];
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        self.iconImageView = [[UIImageView alloc] init];
    }
    return _iconImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.textColor = [UIColor colorWithWhite:48 / 255.0 alpha:1.0];
        self.nameLabel.font = [UIFont systemFontOfSize:16];
        [self.nameLabel sizeToFit];
    }
    return _nameLabel;
}

- (UILabel *)descLabel {
    if (!_descLabel) {
        self.descLabel = [[UILabel alloc] init];
        self.descLabel.textColor = [UIColor colorWithWhite:99 / 255.0 alpha:1.0];
        self.descLabel.font = [UIFont systemFontOfSize:12];
        [self.descLabel sizeToFit];
    }
    return _descLabel;
}

- (UIImageView *)selectedImageView {
    if (!_selectedImageView) {
        self.selectedImageView = [[UIImageView alloc] init];
    }
    return _selectedImageView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
