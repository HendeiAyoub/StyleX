#require_relative '../node_modules/react-native/scripts/react_native_pods'
#require_relative '../node_modules/@react-native-community/cli-platform-ios/native_modules'

# Resolve React Native from the embedded module folder. The repository keeps the
# native iOS app at the root and the RN package under ShoppingModuleRN.
react_native_app_path = File.join(__dir__, 'ShoppingModuleRN')
react_native_node_modules = File.join(react_native_app_path, 'node_modules')
react_native_path = 'ShoppingModuleRN/node_modules/react-native'

require Pod::Executable.execute_command('node', ['-p',
  'require.resolve(
    "react-native/scripts/react_native_pods.rb",
    {paths: [process.argv[1]]},
  )', react_native_app_path]).strip

platform :ios, min_ios_version_supported
prepare_react_native_project!

linkage = ENV['USE_FRAMEWORKS']
if linkage != nil
  Pod::UI.puts "Configuring Pod with #{linkage}ally linked Frameworks".green
  use_frameworks! :linkage => linkage.to_sym
end

target 'ShoppingApp' do
  config = {
    :reactNativePath => react_native_path
  }

  use_react_native!(
    :path => config[:reactNativePath],
    # An absolute path to your application root.
    :app_path => react_native_app_path
  )

  target 'ShoppingAppWidgetExtension' do
    inherit! :complete
    # Pods for testing
  end
  
  target 'ShoppingAppTests' do
    inherit! :complete
    # Pods for testing
  end

  post_install do |installer|
    react_native_post_install(
      installer,
      config[:reactNativePath],
      :mac_catalyst_enabled => false,
      # :ccache_enabled => true
    )
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
          config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
        end
      end
  end
end
