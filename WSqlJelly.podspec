#
# Be sure to run `pod lib lint WSqlJelly.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WSqlJelly'
  s.version          = '0.1.6'
  s.summary          = 'sqllite oc版本的封装，使用链式语法查询数据。'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
sqllite oc版本的封装，使用链式语法查询数据。
                       DESC

  s.homepage         = 'https://github.com/zzttwzq/WSqlJelly'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zzttwzq' => '1076976262@qq.com' }
  s.source           = { :git => 'https://github.com/zzttwzq/WSqlJelly.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'WSqlJelly/Classes/**/*'
  
  # s.resource_bundles = {
  #   'WSqlJelly' => ['WSqlJelly/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
