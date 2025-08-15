Pod::Spec.new do |s|
  s.name                = 'dgis_mobile_sdk_full'
  s.version             = '12.8.0'
  s.summary             = 'A new Flutter FFI plugin project.'
  s.description         = <<-DESC
A new Flutter FFI plugin project.
                       DESC
  s.homepage            = 'http://example.com'
  s.license             = { :file => '../LICENSE' }
  s.author              = { 'Your Company' => 'email@example.com' }

  s.source              = { :path => '.' }
  s.source_files        = 'Classes/**/*.{h,mm}'
  s.public_header_files = 'Classes/**/*.h'

  s.dependency 'Flutter'
  s.dependency 'DGisFlutterFullSDK', '~> 12.8.0+1'

  s.frameworks          = 'CoreVideo', 'Foundation', 'Metal', 'UIKit'
  s.platform = :ios, '13.0'
  s.requires_arc        = true
  s.compiler_flags      = '-fobjc-arc'
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386', 'OTHER_LDFLAGS' => '-all_load -ObjC' }
  s.swift_version = '5.0'
end
