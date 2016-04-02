#
#  Be sure to run `pod spec lint JXRouter.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "JXRouter"
  s.version      = "0.0.4"
  s.summary      = "页面路由."

  s.description  = <<-DESC
                  **Router 实践**
                   DESC

  s.homepage     = "https://github.com/sopig/JXRouter.git"
  s.license      = "MIT"

  s.author       = { "listen" => "chay0103@163.com" }
  
  s.platform     = :ios, "7.0"

  s.source       = { :git => "git@github.com:sopig/JXRouter.git", :tag => "#{s.version}" }

  s.source_files = "*"
  #s.source_files  = "Classes", "Classes/**/*.{h,m}"
  #s.exclude_files = "Classes/Exclude"

  s.public_header_files = "*.h"

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"

  # s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

end
