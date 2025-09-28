<div align="center">
<img src="./assets/appicon.png" alt="Knobby’s app icon" style="display:block" />
<h1>Knobby</h1>
<p>A tiny app to control your Mac’s volume and screen brightness with Vim key bindings.</p>
</div>

This app exists because I wanted a dead–simple “agent” app that could be quickly summoned whenever (stylishly if possible) and allow me to adjust the Mac’s volume and brightness with Vim key bindings.

Note: As of macOS Sonoma and on Apple Silicon machines, the only reliable way to programmatically control the display’s brightness is through the private DisplayServices framework, which necessitates removing the app’s sandbox. This is why this app can’t be distributed through the App Store.

https://github.com/user-attachments/assets/0aaca6ab-d7aa-49db-a15a-88c98595d17d

**Requires macOS Sonoma.**

## Install

Download the latest release, mount the DMG and move the app bundle to your applications folder.

## Usage

Manipulating the currently focused setting (either volume or brightness):

| Key Binding  | Action          |
| ------------ | --------------- |
| <kbd>L</kbd> | Increase by 10% |
| <kbd>H</kbd> | Decrease by 10% |
| <kbd>J</kbd> | Set to 0%       |
| <kbd>K</kbd> | Set to 100%     |

General shortcuts:

| Key Binding    | Action                 |
| -------------- | ---------------------- |
| <kbd>Tab</kbd> | Change focused setting |
| <kbd>Esc</kbd> | Dismiss Knobby         |

## Acknowledgements

- [sindresorhus/KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts)
