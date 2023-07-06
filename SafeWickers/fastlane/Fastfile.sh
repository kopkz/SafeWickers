# This file contains the fastlane.tools configuration
# You can find the documentation at https://docs.fastlane.tools
#
# For a list of all available actions, check out
#
# https://docs.fastlane.tools/actions
#
# For a list of all available plugins, check out
#
# https://docs.fastlane.tools/plugins/available-plugins
#

# Uncomment the line if you want fastlane to automatically update itself
# update\_fastlane

default_platform(:ios)

platform :ios do
  lane :build do
    cocoapods

    gym(
      scheme: "Debug",
      workspace: "Safe Wickers.xcworkspace",
      export_options: "./exportOptions.plist"
    )
  end
end
