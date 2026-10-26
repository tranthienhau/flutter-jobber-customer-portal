# Regenerating screenshots and demo GIFs

## Screenshots (iOS simulator)

```sh
xcrun simctl boot "iPhone 17 Pro"
flutter pub get
flutter drive --driver test_driver/integration_test.dart \
  --target integration_test/screenshot_test.dart -d "iPhone 17 Pro"
```

`integration_test/screenshot_test.dart` pumps the real `MidasPortalApp`, signs in, and walks
Home, a site (Northgate Office Park), the request-a-change form, a new request (it taps
Add photo, which attaches a sample photo instead of opening the camera), the confirmation,
the job status timeline, the requests list, completed work (it rates the visit), invoices
and an invoice, the support chat (it sends a message and waits for the reply),
notifications and account, then flips `sessionProvider.setLinked(false)` to capture the
first-run home. It uses fixed `pump(Duration)` steps rather than `pumpAndSettle` so the mock
API latency and animations finish deterministically, and jumps between tabs with the
`routerProvider` where a back gesture would be flaky. Each
`binding.takeScreenshot('NN-name')` is written to `screenshots/NN-name.png` by
`test_driver/integration_test.dart` (`integrationDriver(onScreenshot:)`).

Screenshots are then resized to 603px wide and compressed:

```sh
cd screenshots
for f in [0-9]*.png; do sips -Z 1311 $f; pngquant --quality 75-92 --force --ext .png $f; done
```

## iOS demo GIF

```sh
xcrun simctl io booted recordVideo --codec h264 --force /tmp/ios.mp4 &
flutter drive --driver test_driver/integration_test.dart \
  --target integration_test/screenshot_test.dart -d "iPhone 17 Pro"
kill -INT %1
ffmpeg -ss 32 -to 101 -i /tmp/ios.mp4 -vf "setpts=PTS/2.4" -an /tmp/ios_cut.mp4
ffmpeg -y -i /tmp/ios_cut.mp4 -vf "fps=10,scale=280:-1:flags=lanczos,palettegen=max_colors=128:stats_mode=diff" /tmp/pal.png
ffmpeg -y -i /tmp/ios_cut.mp4 -i /tmp/pal.png \
  -lavfi "fps=10,scale=280:-1:flags=lanczos[x];[x][1:v]paletteuse=dither=bayer:bayer_scale=4:diff_mode=rectangle" \
  screenshots/demo.gif
```

Trim `-ss` to the first frame of the sign-in screen (the build and install take the first
part of the recording).

## Android demo GIF

```sh
emulator -avd Medium_Phone_API_36.1 -port 5556 &
flutter drive --driver test_driver/integration_test.dart \
  --target integration_test/screenshot_test.dart -d emulator-5556 &
# once the log prints "capture Midas portal flows":
adb -s emulator-5556 shell screenrecord --time-limit 85 --size 540x1200 /sdcard/ademo.mp4
adb -s emulator-5556 pull /sdcard/ademo.mp4 /tmp/android.mp4
```

Trim (`-ss 1.5 -to 72`, `setpts=PTS/2.4`) and run the same two-pass ffmpeg palette conversion
into `screenshots/demo-android.gif`. Let `screenrecord` stop on `--time-limit` so the mp4 is
finalized. The Android run writes Android-sized PNGs into `screenshots/`, so back up and
restore the iOS set afterwards.
