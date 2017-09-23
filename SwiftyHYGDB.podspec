#
# Be sure to run `pod lib lint SwiftyHYGDB.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SwiftyHYGDB'
  s.version          = '0.5.2'
  s.summary          = 'A Swift library to work with the astronexus.com HYG database of stars'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Helper library with `struct Star` representing stars from the astronexus.com HYG Database. Includes methods to load `*.csv` files in an efficient way when formatted according to astronexus description.
                        DESC

  s.homepage         = 'https://github.com/Bersaelor/SwiftyHYGDB'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Bersaelor' => 'konrad@mathheartcode.com' }
  s.source           = { :git => 'https://github.com/Bersaelor/SwiftyHYGDB.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/bersaelor'

  s.ios.deployment_target = '9.3'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.2'
  
  s.source_files = 'Sources/SwiftyHYGDB/*'  
end
