<div align="center">
<img src="https://github.com/roeybiran/Knobby/assets/37002381/6f1d3a48-6dea-4e96-b82e-59cb02b36082" alt="Knobby’s app icon" style="display:block" />
<h1>Knobby</h1>
<p>A tiny app to control your Mac’s volume and screen brightness with Vim key bindings.</p>
</div>

This app exists because:

- I wanted a dead–simple “agent” app that could be quickly summoned whenever (stylishly if possible) and allow me to adjust the Mac’s volume and brightness with Vim key bindings.
- I wanted to play with latest Apple technologies (e.g. Sonoma’s SwiftUI, Observation…).

As of macOS Sonoma and on Apple Silicon machines, the only reliable way to programmatically control the display’s brightness is through the private DisplayServices framework, which necessitates removing the app’s sandbox. This is why this app can’t be distributed through the App Store.

**Requires macOS Sonoma.**

## Demo

https://github.com/roeybiran/Knobby/assets/37002381/2c052fd6-8102-467b-b577-2d8048c58548

## Install

- Download the latest release, mount the DMG and move the app bundle to your applications folder.

## Usage

- To activate this app from anywhere using a global keyboard shortcut, and without taking focus off the current app, use an app like [Karabiner–Elements](https://github.com/pqrs-org/Karabiner-Elements) and configure your desired keyboard shortcut to run the following shell script:

```
open -gja Knobby
```
