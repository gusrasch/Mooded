# Mooded - Personal Mood & Habit Tracker

An iOS app for tracking your daily mood and habits, with beautiful visualizations and helpful reminders.

## Getting Started

These instructions will guide you through the process of setting up your development environment and deploying the app to your personal iOS device.

### Prerequisites

- A Mac computer running macOS Ventura (13.0) or later
- [Xcode 15](https://apps.apple.com/us/app/xcode/id497799835) or later installed from the Mac App Store
- An iOS device running iOS 17.0 or later (for device deployment)
- An Apple ID (free)

### Setting Up Your Apple Developer Profile

1. Create an Apple ID (if you don't have one):
   - Visit [Apple ID creation page](https://appleid.apple.com/account)
   - Click "Create Your Apple ID"
   - Follow the on-screen instructions
   - Verify your email address

2. Set up your free Apple Developer profile:
   - Open Xcode
   - Go to Xcode → Settings (or Preferences in older versions)
   - Navigate to the "Accounts" tab
   - Click the "+" button in the lower-left corner
   - Select "Apple ID"
   - Sign in with your Apple ID
   - Xcode will automatically set up your free developer profile

### Deploying to Your Personal Device

1. Connect your iOS device to your Mac using a USB cable

2. Trust your Mac on your iOS device:
   - On your iOS device, you'll see a "Trust This Computer?" alert
   - Tap "Trust" and enter your device passcode

3. Configure the project in Xcode:
   - Open the Mooded.xcodeproj file
   - In the Navigator panel (left sidebar), click on the root project item (Mooded)
   - In the center panel, select "Mooded" under TARGETS
   - In the "Signing & Capabilities" tab:
     - Check "Automatically manage signing"
     - Select your personal team (associated with your Apple ID)
     - Wait for Xcode to generate a provisioning profile

4. Set up your device for development:
   - On your iOS device, go to Settings → Privacy & Security
   - Scroll down and find "Developer Mode"
   - Toggle it on
   - Your device will restart

5. Deploy the app:
   - In Xcode, at the top of the window, select your iOS device from the device dropdown menu
   - Click the "Play" (▶) button or press Cmd + R to build and run
   - Wait for the app to install on your device

6. Trust the developer profile on your device:
   - When first launching the app, you'll see "Untrusted Developer"
   - On your iOS device, go to Settings → General → VPN & Device Management
   - Under "Developer App", tap your Apple ID
   - Tap "Trust [your Apple ID]"
   - Tap "Trust" again to confirm

### Additional Notes

- The free Apple Developer profile allows you to:
  - Deploy apps to your personal devices
  - Test all features of your app
  - Keep the app installed for up to 7 days before needing to redeploy

- Limitations of the free profile:
  - Cannot publish to the App Store
  - Must redeploy every 7 days
  - Limited to 10 app IDs per team
  - Cannot access certain capabilities (like Push Notifications)

- If you need to deploy for longer periods or publish to the App Store, consider enrolling in the [Apple Developer Program](https://developer.apple.com/programs/) ($99/year)

## Troubleshooting

If you encounter issues:

1. **Signing Problems**:
   - In Xcode, try Clean Build Folder (Shift + Cmd + K)
   - Delete the app from your device and redeploy

2. **Device Not Recognized**:
   - Disconnect and reconnect your device
   - Trust the computer again if prompted
   - Restart Xcode

3. **Build Errors**:
   - Ensure you're running the latest Xcode version
   - Clean Build Folder and rebuild
   - Delete Derived Data (Xcode → Settings → Locations → Derived Data → Delete)

## Support

For additional help:
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [Xcode Help](https://help.apple.com/xcode/)
- [Apple Developer Forums](https://developer.apple.com/forums/)
