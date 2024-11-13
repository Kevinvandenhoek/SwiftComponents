Pod::Spec.new do |s|
  s.name             = 'SwiftComponents'
  s.version          = '1.0.9'
  s.summary          = 'A SwiftUI Components library.'
  s.homepage         = 'https://github.com/Kevinvandenhoek/SwiftComponents.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author           = { 'Kevin van den Hoek' => 'kevinvandenhoek@gmail.com' }
  s.source           = { :git => 'https://github.com/Kevinvandenhoek/SwiftComponents.git', :tag => s.version.to_s }
  s.ios.deployment_target = '15.0'
  s.swift_version = '5.0'
  s.source_files = 'Sources/SwiftComponents/**/*'
end
