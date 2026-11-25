require 'json'

Pod::Spec.new do |s|
  s.name                = 'dgis_mobile_sdk_full'
  s.version             = '14.3.0'
  s.summary             = 'A new Flutter FFI plugin project.'
  s.description         = <<-DESC
A new Flutter FFI plugin project.
                       DESC
  s.homepage            = 'http://example.com'
  s.license             = { :file => '../LICENSE' }
  s.author              = { 'Your Company' => 'email@example.com' }

  s.source              = { :path => '.' }
  # Sources live in the Swift Package layout so CocoaPods and Swift Package
  # Manager can build from the same files.
  s.source_files        = 'dgis_mobile_sdk_full/Sources/dgis_mobile_sdk_full/**/*.{h,mm}'
  s.public_header_files = 'dgis_mobile_sdk_full/Sources/dgis_mobile_sdk_full/include/**/*.h'

  s.dependency 'Flutter'

  # PlatformCDart.xcframework used to come from the `DGisFlutterFullSDK` trunk
  # pod. Trunk goes read-only, so this pod now fetches the very same artifact
  # (the one that pod vendored, byte for byte) from artifactory itself.
  #
  # The pin lives in `ios/dgis_artifact.json`; the Swift package declares the
  # same artifact, so both integration paths use the same binary.
  artifact = JSON.parse(File.read(File.join(__dir__, 'dgis_artifact.json')))

  # `prepare_command` runs for local (`:path`) pods as well as for published
  # ones (CocoaPods Installer::PodSourceInstaller#install! ->
  # PodSourcePreparer#prepare!), with the working directory set to this pod's
  # root, i.e. the `ios/` directory of whatever checkout is building --
  # including the one Flutter creates under `.symlinks/plugins`. The script is
  # idempotent, so an up-to-date checkout costs a single stat().
  s.prepare_command = <<-SHELL
    DGIS_ARTIFACT_NAME="#{artifact['artifact']}" \
    DGIS_ARTIFACT_URL="#{artifact['url']}" \
    DGIS_ARTIFACT_SHA1="#{artifact['sha1']}" \
    DGIS_ARTIFACT_VERSION="#{artifact['version']}" \
    /bin/bash "fetch_platform_cdart.sh"
  SHELL

  # Materialised by the prepare_command above: a symlink to the cached
  # xcframework, or the unpacked bundle itself when it was vendored in-tree.
  # Lives in `ios/Frameworks/`, outside the Swift package directory, so SwiftPM
  # mode never sees it.
  s.vendored_frameworks = 'Frameworks/PlatformCDart.xcframework'

  # PlatformCDart is linked by this target's own objects (FlutterMetalTexture.mm
  # calls dgis::dart::map::*), so -framework PlatformCDart must be part of this
  # target's OTHER_LDFLAGS.
  s.frameworks          = 'CoreVideo', 'Foundation', 'Metal', 'PlatformCDart', 'UIKit'
  s.platform = :ios, '16.0'
  s.requires_arc        = true
  s.compiler_flags      = '-fobjc-arc'
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386', 'OTHER_LDFLAGS' => '-all_load -ObjC' }
  s.swift_version = '5.0'
end
