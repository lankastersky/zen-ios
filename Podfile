platform :ios, '9.0'

target 'zen' do
  use_frameworks!

  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Storage'
  pod 'Fabric', '~> 1.7.9'
  pod 'Crashlytics', '~> 3.10.5'
  pod 'Zip', '~> 1.1'
  pod 'Cosmos', '~> 16.0'

target 'zenTests' do
    inherit! :search_paths
end

end

# Workaround for Cocoapods issue #7606
post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
end