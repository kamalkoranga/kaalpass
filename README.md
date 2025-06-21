# 🔐 KaalPass – Linux TOTP with Android Integration

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
1. Download **kaalpass.sh** (bash script to set system password) by running following command:<br>
    ```bash
    wget -O kaalpass.sh https://github.com/kamalkoranga/kaalpass/releases/latest/download/script.sh
    ```

2. Populate the **kaalpass.sh** with your custom values.
    ```bash
    #!/bin/bash

    # Replace with your linux username(check with `whoami`)
    USERNAME="YOUR_USERNAME"

    # This is your secret key, change it to something secure
    # This key will be used to generate the password
    SECRET="YOUR_SECRET_KEY"

    # Generate today's UTC date string
    DATE_KEY=$(date +%Y-%m-%d)

    # Generate SHA256 hash
    PASSWORD_HASH=$(echo -n "$SECRET$DATE_KEY" | sha256sum | awk '{print $1}')

    # Extract 14-character alphanumeric password
    PASSWORD=$(echo "$PASSWORD_HASH" | tr -cd '[:alnum:]' | cut -c1-14)

    # Test: Print the password
    #echo "Generated password for $USERNAME: $PASSWORD"

    # Set the user's password
    echo "$USERNAME:$PASSWORD" | sudo chpasswd
    ```

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
You can now install the Android app directly without building it manually.

#### ✅ Steps to Use the App:

1. **Download the APK:**
    - 📦 [Download app-release.apk](https://github.com/kamalkoranga/kaalpass/releases/latest/download/app-release.apk)

2. **Install on your Android device:**
    - Transfer the APK file to your device.
    - Enable Install unknown apps in your device settings if prompted.
    - Tap the APK to install the app.

3. **Configure the App:**
    - On first launch, the app will ask for a Secret Key.
    - Enter the exact same secret key used in your Linux script (/usr/local/bin/kaalpass.sh) so that passwords sync correctly.

4. **View Your Password:**
    - The app will show the auto-updating daily password based on your configured secret.
    - You can also change the secret later from the app’s left sidebar(swipe right from left side).


**| Tip**:  Create a widget of it to directly access your today's password from homescreen.

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
