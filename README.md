# MiniTop

A minimal macOS web browser app that provides a clean, distraction-free way to access web applications. Built with Swift and WebKit.

## Features

- **Web Browser**: Full WebKit-based browser in a native macOS window
- **URL Management**: Set custom URLs with keyboard shortcut (⌘U)
- **Recent URLs**: Access your 10 most recently visited URLs from the menu
- **Stay On Top**: Toggle window to stay above all other applications (⌘T)
- **Persistent Settings**: Automatically saves and restores your last URL, recent URLs, and preferences
- **Modern Browser Identity**: Uses updated User-Agent to ensure compatibility with modern web apps like Gmail

## Default Behavior

- Starts with Google Keep (https://keep.google.com) by default
- Remembers your last visited URL and loads it on next startup
- Window can be resized, minimized, and closed normally

## Keyboard Shortcuts

- **⌘U**: Set new URL
- **⌘T**: Toggle stay on top
- **⌘Q**: Quit application

## Menu Options

- **Set URL...**: Enter any web address to navigate to
- **Recent URLs**: Quick access to your browsing history
- **Stay On Top**: Keep window above other applications
- **Quit**: Exit the application

## Building and Running

### Prerequisites
- macOS with Xcode or Swift command line tools
- Swift 5.0 or later

### Compile and Run
```bash
swift main.swift
```

The app will compile and launch immediately.

## Settings Storage

Settings are automatically saved to:
```
~/Library/Application Support/MiniTop/settings.json
```

This includes:
- Last visited URL
- Recent URLs list (up to 10 entries)
- Stay on top preference

## Use Cases

- **Web App Wrapper**: Use any web application as if it were a native macOS app
- **Always Visible Tools**: Keep important web tools visible with stay-on-top mode
- **Distraction-Free Browsing**: Minimal interface for focused web application usage
- **Quick Access**: Fast switching between frequently used web applications

## Technical Details

- Built with Swift and WebKit (WKWebView)
- Uses modern Chrome User-Agent for maximum web compatibility
- JSON-based settings persistence
- Native macOS menu integration
- Proper window management and level control

## License

This project is open source. Feel free to modify and distribute as needed. 