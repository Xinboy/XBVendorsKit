#
# Be sure to run `pod lib lint FunctionModule.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XBVendorsKit'
  s.version          = '0.0.1'
  s.summary          = '第三方组件'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: 第三方组件，主要集合各种第三方的扩展以及封装
                       DESC

  s.homepage         = 'https://dev.tencent.com/u/Xinbo2016/p/XBVendorsKit/git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '洪新博' => 'xinbo.hong@hotmail.com' }
  s.source           = { :git => 'https://git.dev.tencent.com/Xinbo2016/XBVendorsKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  
  s.source_files = 'XBVendorsKit/Classes/**/*'
  # s.resource_bundles = {
  #   'FunctionModule' => ['XBVendorsKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  
  s.frameworks = 'UIKit', 'Foundation'
  s.dependency 'Masonry'
  s.dependency 'SVProgressHUD'
  s.dependency 'AFNetworking'
  s.dependency 'MJRefresh'
  s.dependency 'JPush'
  s.dependency 'Crashlytics'

end
