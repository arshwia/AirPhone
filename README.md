# AirPhone 📱💻

**AirPhone** is a simple and convenient tool to wirelessly mirror your Android phone to your Linux desktop using scrcpy.

Just one click and you're connected — no cables, no hassle!

## ✨ Features

- Automatic wireless ADB connection
- Saves your phone's IP and port for future use
- Clean GUI prompts using Zenity
- Easy install and uninstall scripts
- Desktop entry with icon (`.desktop` file)
- Optimized scrcpy flags (`--turn-screen-off` and `--stay-awake`)

## 🛠️ Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/arshwia/AirPhone.git
   cd AirPhone```

2. Install
    ```it:Bash./install.sh```

    1. Launch it from your applications menu or by running airphone in the terminal.

## 🔄 How to Use
1. Enable Wireless Debugging on your Android phone (Developer Options).
2. Run AirPhone.
3. Enter your phone's IP address and port (only the first time).
4. It will automatically connect and start mirroring your screen.

## 🧠 About This Project
This project was built mostly for fun as a coding vibe project. A large part of the code was written with the help of AI. The goal was to create a clean, useful tool for personal daily use.

## Requirements

- scrcpy
- adb (Android Platform Tools)
- zenity
- notify-send (libnotify)

## 📄 License
- MIT License — feel free to use, modify, and share.

<b>Built with ❤️ and a bit of AI magic</b>