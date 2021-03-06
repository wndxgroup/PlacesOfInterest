# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
$:.unshift("~/.rubymotion/rubymotion-templates")

# ===========================================================================================
# 1. Be sure to read `readme.md`.
# ===========================================================================================

require 'motion/project/template/ios'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  define_icon_defaults!(app)

  # ===========================================================================================
  # 2. Set your app name (this is what will show up under the icon when your app is installed).
  # ===========================================================================================
  app.name = 'POI'

  # version for your app
  app.version = '1.0.0'

  app.identifier = 'com.wndx.POIapp'

  app.installrapp do
    app.installr_api_token = 'NTbvKv5Xi3uKMkFQM9kmFMZSuTQVz04i'
    app.codesign_certificate = MotionProvisioning.certificate(
        type: :development,
        platform: :ios)

    app.provisioning_profile = MotionProvisioning.profile(
        bundle_identifier: app.identifier,
        app_name: app.name,
        platform: :ios,
        type: :development)
    app.entitlements['get-task-allow'] = false
  end

  if app.hockeyapp?
    app.hockeyapp do
      app.codesign_certificate = MotionProvisioning.certificate(
          type: :development,
          platform: :ios)

      app.provisioning_profile = MotionProvisioning.profile(
          bundle_identifier: app.identifier,
          app_name: app.name,
          platform: :ios,
          type: :development)
      app.entitlements['get-task-allow'] = false
      set :api_token, '79f41cba216c4eb9af10df52dcc648e0'
    end
  end

  app.development do
    app.codesign_certificate = MotionProvisioning.certificate(
      type: :development,
      platform: :ios)

    app.provisioning_profile = MotionProvisioning.profile(
      bundle_identifier: app.identifier,
      app_name: app.name,
      platform: :ios,
      type: :development)
  end

  app.release do
    app.codesign_certificate = MotionProvisioning.certificate(
      type: :distribution,
      platform: :ios,
      free: true)

    app.provisioning_profile = MotionProvisioning.profile(
      bundle_identifier: app.identifier,
      app_name: app.name,
      platform: :ios,
      type: :distribution,
      free: true)
  end

  # ===========================================================================================
  # 3. Set your deployment target (it's recommended that you at least target 10.0 and above).
  #    If you're using RubyMotion Starter Edition. You cannot set this value (the latest
  #    version of iOS will be used).
  # ===========================================================================================
  # app.deployment_target = '10.0'

  # ===========================================================================================
  # 4. Your app identifier is needed to deploy to an actual device. You do not need to set this
  #    if you are using the simulator. You can create an app identifier at:
  #    https://developer.apple.com/account/ios/identifier/bundle. You must enroll into Apple's
  #    Developer program to get access to this screen (there is an annual fee of $99).
  # ===========================================================================================
  # app.identifier = ''

  # ===========================================================================================
  # 5. If you need to reference any additional iOS libraries, use the config array below.
  # ===========================================================================================
  app.frameworks << 'MapKit' << 'CoreMotion' << 'CoreLocation' << 'Foundation' << 'SceneKit'
  app.frameworks << 'ARKit'

  # reasonable defaults
  app.device_family = [:iphone, :ipad]
  app.interface_orientations = [:portrait]
  app.info_plist['UIRequiresFullScreen'] = true
  app.info_plist['ITSAppUsesNonExemptEncryption'] = false

  # ===========================================================================================
  # 6. To deploy to an actual device, you will need to create a developer certificate at:
  #    https://developer.apple.com/account/ios/certificate/development
  #    The name of the certificate will be accessible via Keychain Access. Set the value you
  #    see there below.
  # ===========================================================================================
  # app.codesign_certificate = ''

  # ===========================================================================================
  # 7. To deploy to an actual device, you will need to create a provisioning profile. First:
  #    register your device at:
  #    https://developer.apple.com/account/ios/device/
  #
  #    Then create a development provisioning profile at:
  #    https://developer.apple.com/account/ios/profile/limited
  #
  #    Download the profile and set the path to the download location below.
  # ===========================================================================================
  # app.provisioning_profile = ''

  # ===========================================================================================
  # 8. Similar to Step 7. Production, create a production certificate at:
  #    https://developer.apple.com/account/ios/certificate/distribution.
  #    These values will need to be set to before you can deploy to the App Store. Compile
  #    using `rake clean archive:distribution` and upload the .ipa under ./build using
  #    Application Loader.
  # ===========================================================================================
  # app.codesign_certificate = ''
  # app.provisioning_profile = ''

  # ===========================================================================================
  # 9. If you want to create a beta build. Uncomment the line below and set your profile to
  #    point to your production provisions (Step 8).
  # ===========================================================================================
  # app.entitlements['beta-reports-active'] = true
end

def define_icon_defaults!(app)
  # This is required as of iOS 11.0 (you must use asset catalogs to
  # define icons or your app will be rejected. More information in
  # located in the readme.

  app.info_plist['CFBundleIcons'] = {
    'CFBundlePrimaryIcon' => {
      'CFBundleIconName' => 'AppIcon',
      'CFBundleIconFiles' => ['AppIcon60x60']
    }
  }

  app.info_plist['CFBundleIcons~ipad'] = {
    'CFBundlePrimaryIcon' => {
      'CFBundleIconName' => 'AppIcon',
      'CFBundleIconFiles' => ['AppIcon60x60', 'AppIcon76x76']
    }
  }

  app.info_plist['NSLocationAlwaysAndWhenInUseUsageDescription'] = 'So we know where you are when you are using the app and when you are not'
  app.info_plist['NSLocationAlwaysUsageDescription'] = 'So we can always know where you are'
  app.info_plist['NSLocationWhenInUseUsageDescription'] = 'So we can know where you are when you have the app open'
  app.info_plist['NSCameraUsageDescription'] = 'Needed for AR'
end
