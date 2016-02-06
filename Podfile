source 'https://github.com/appodeal/CocoaPods.git'
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'
#use_frameworks!
inhibit_all_warnings!

target 'Horoscope' do

	pod 'AFNetworking', '~> 2.6'
	pod 'Google/Analytics', '~> 1.0'
	pod 'Appodeal'
	pod 'Fabric'
	pod 'Crashlytics'
	
end

target 'HoroscopeTests' do

end

target 'HoroscopeUITests' do

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end
    end
end
