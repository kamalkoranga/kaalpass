# 🔐 KaalPass – TOTP-Based Daily Password System for Linux with Android App Integration

**KaalPass** is a secure, TOTP-based system that automatically rotates your Linux system password every day and syncs it to an Android app (with widget support) for easy and secure access.

---

## 📌 Features:


- ⏱️ **Daily Password Change** – Uses a script to update your Linux system password daily.
- 🧰 **TOTP-Based Logic** – Ensures secure, predictable password generation on both devices.
- 📱 **Android App Integration** – Displays the current password securely on your phone.
- 🧩 **Home Screen Widget** – Access the current password instantly with one tap.
- 📋 **Copy to Clipboard** – Copies password with one click from the app and the widget.
- 🌗 **Theme Support** – Light and dark themes with persistence across sessions.
- 🔌 **Offline Functionality** – The app operates seamlessly without an internet connection.

---


## 🛠️ Setup

### 💻 Linux (TOTP & Password Rotation)
1. Download [kaalpass.sh](https://github.com/kamalkoranga/kaalpass/releases/latest/download/script.sh) by running following command:<br>
    ```bash
    wget -O kaalpass.sh https://github.com/kamalkoranga/kaalpass/releases/latest/download/script.sh
    ```

2. Populate the **kaalpass.sh** with your custom values like *USERNAME* and *SECRET*.

3. Save this file in ```/usr/local/bin``` by running following command:<br>
    ```bash
    sudo mv kaalpass.sh /usr/local/bin
    ```

4. Now if you do:<br>
    ```bash
    sudo ls /usr/local/bin
    ```
    There should be```kaalpass.sh``` file.

5. Make it executable<br>
    ```bash
    sudo chmod +x /usr/local/bin/kaalpass.sh
    ```

6. Add a Cron (automate this script)<br>
    ```bash
    sudo crontab -e

    # add these two lines in the editor
    0 0 * * * /usr/local/bin/kaalpass.sh
    @reboot /usr/local/bin/kaalpass.sh

7. Run this manually to test or to set the password right now:

    ```bash
    sudo /usr/local/bin/kaalpass.sh
    ```

Now the script is configured in your machine. Now set up android app 👇.


### 📱Android App (APK)
1. Make sure you have flutter installed if not then install from [here](https://flutter.dev).

2. Clone the repo:<br>
   ```bash
   git clone https://github.com/kamalkoranga/kaalpass.git
   ```

3. Update the **secret variable** in [home_page.dart](/lib/pages/home_page.dart):Line 23 that is ```final String secret = 'MY_SUPER_SECRET';``` with the same secret key that had in your ```/usr/local/bin/kaalpass.sh``` file.

4. Change the linux username to your linux username in [kaal_pass_widget](/android/app/src/main/res/layout/kaal_pass_widget.xml): Line 36 that is ```android:text="YOUR_LINUX_USERNAME's Password"```

5. Install flutter packages:<br>
    ```bash
    flutter pub get
    ```

6. Build your apk by running following command:<br>
    ```bash
    flutter build apk --release
    ```
    This generates a release APK in:<br>
    ```bash
    build/app/outputs/flutter-apk/app-release.apk
    ```

7. Transfer the APK to your Android device.
    Enable Install unknown apps permission in your device settings if not already enabled.
    Open the APK file to install the app.
    Once installed, open the app to view today's password synced with your Linux system.

**| Tip**:  Create a widget of it to directly access your today's password.

---

#### ⚠️ NOTE:
SECRET KEY should be same in both script and app so that they can sync the same password, even if there is a change of single character then the password changed by the script will be different from what the app is showing. 

---

## 💡 Widget Behavior
- Tapping the widget:
    - Refreshes the displayed password
    - Copies it to the clipboard
- Works without opening the app
- Responsive dark mode styling

---

## 🤝 Contributing

Feel free to open issues or submit PRs for improvements and ideas!

---

## 📜 License

MIT License. See [LICENSE](/LICENSE) for more details.
