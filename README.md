# Foxglove WebSocket Bridge

Stream sensor data from your iOS device and visualize it in [Foxglove](https://foxglove.dev/) 🤖

[<img src="https://user-images.githubusercontent.com/14237/232120565-88d0d9b1-2b0f-40b8-9547-a4a4c4c48156.png" height="40">](https://apps.apple.com/us/app/foxglove-websocket-bridge/id1673592198)

<img src="./screenshots/graphic/iphone14plus-6.5in.png" width="150"/> <img src="./screenshots/iphone14plus-6.5in.png" width="150"/> <img src="https://github.com/foxglove/foxglove-ios-bridge/assets/14237/ff7bdf76-d67f-4410-b204-1ce9c08332c8" width="256">


## About

This app demonstrates how custom data can be streamed to Foxglove using the [Foxglove WebSocket protocol](https://docs.foxglove.dev/docs/connecting-to-data/frameworks/custom/#live-data). The app hosts a WebSocket server; Foxglove connects to the server and requests data to be streamed depending on the [panels](https://docs.foxglove.dev/docs/visualization/panels/introduction/) used.

https://user-images.githubusercontent.com/14237/232120004-7e30932d-37de-43fb-9bc8-da2aa1a94556.mp4

## License

The Foxglove WebSocket Bridge app is licensed under the [MIT License](https://opensource.org/licenses/MIT).

## Contributing

Note: All contributors must agree to our [Contributor License Agreement](https://github.com/foxglove/cla).

## Releasing

To make a release of the app, perform the following steps:

1. Follow [these steps](https://developer.apple.com/help/app-store-connect/update-your-app/create-a-new-version/) to create a new version of the app on App Store Connect.
1. Update every instance of `CURRENT_PROJECT_VERSION` and `MARKETING_VERSION` in [project.pbxproj](WebSocketDemo.xcodeproj/project.pbxproj) as needed. The `MARKETING_VERSION` must match the new draft version in App Store Connect, and `CURRENT_PROJECT_VERSION` must be unique for each build you plan to upload.
1. In Xcode, follow [these steps](https://help.apple.com/xcode/mac/current/#/devf37a1db04) to create an archive.
1. Once the archive is completed, click the Distribute App button and choose to upload the build to App Store Connect.
   - Visit the [TestFlight tab](https://appstoreconnect.apple.com/apps/1673592198/testflight/ios) of App Store Connect to see the status of the newly uploaded build.
1. Attach the new build to the new app version, update other assets and metadata as needed, and submit the the app for review.

## Stay in touch

Join our [Slack channel](https://foxglove.dev/slack) to ask questions, share feedback, and stay up to date on what our team is working on.
