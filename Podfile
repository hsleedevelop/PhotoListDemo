install! 'cocoapods', :deterministic_uuids => false
source 'https://github.com/CocoaPods/Specs.git'

# Uncomment this line to define a global platform for your project
platform :ios, '12.0'

# ignore all warnings from all pods
inhibit_all_warnings!

def rx_pods
  # RX
  pod 'RxSwift', '~> 5.1.1'
  pod 'RxCocoa', '~> 5.1.1'
  pod 'RxSwiftExt', '~> 5.1.1'
  pod 'RxGesture', '~> 3.0.2'
end

def debug_pods
  # debug
  pod 'FLEX',   :configurations => ['Debug']
end

def shared_pods
    use_frameworks!
    rx_pods
    debug_pods
end

target 'PhotoListDemo' do
    shared_pods
end

target 'PhotoListDemoTests' do
   inherit! :search_paths
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        swift_version = '5.2'
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = swift_version
        end
    end
end
