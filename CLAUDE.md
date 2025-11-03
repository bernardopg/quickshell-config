# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is "illogical-impulse" (ii), a comprehensive Wayland desktop shell built with **Quickshell** and QML. It provides a complete desktop environment including a top bar, sidebars, dock, lock screen, overview, on-screen display, and many other modular components for Hyprland on Linux.

## Running and Testing

### Start the Shell
```bash
quickshell -c ii
```

### Reload the Shell
The shell has built-in reload functionality. After making changes, you can reload without restarting:
- Use Hyprland IPC to trigger reload
- Or kill and restart the quickshell process

### Settings Application
```bash
# Open the settings UI (separate Qt application)
qml settings.qml
```

The settings app provides a GUI for editing `~/.config/illogical-impulse/config.json`.

### Testing Individual Modules
Modules are lazy-loaded via `LazyLoader` in `shell.qml`. You can disable modules by setting their enable flags:
```qml
property bool enableBar: true
property bool enableBackground: true
// ... etc
```

## Architecture

### Entry Point: shell.qml
The `shell.qml` file is the Quickshell entry point. It:
- Sets Qt environment pragmas (scale factor, controls style)
- Imports all module namespaces
- Defines enable/disable flags for each module
- Lazy-loads modules using `LazyLoader` based on configuration
- Initializes singletons on startup (MaterialThemeLoader, Config, etc.)

### Module System
Modules are organized under `modules/` and follow a pattern:
- Each module is a self-contained QML component
- Modules use `LazyLoader` for conditional loading
- Modules can respond to IPC commands and global shortcuts
- Module examples: `bar/`, `dock/`, `sidebarLeft/`, `sidebarRight/`, `lock/`, `overview/`

### Services (modules/common vs services/)
- **services/**: Singleton QML services providing system integration (Audio, Bluetooth, Network, Brightness, Battery, Notifications, etc.)
- **modules/common/**: Reusable UI components, widgets, utilities, and the Config/Persistent singletons

### Configuration System
- **Config.qml** (`modules/common/Config.qml`): Manages user configuration from `~/.config/illogical-impulse/config.json`
  - Auto-saves changes with debouncing (`readWriteDelay`)
  - Watches file for external changes
  - Nested JSON structure accessed via `Config.options.foo.bar`
- **Persistent.qml** (`modules/common/Persistent.qml`): Runtime state persistence to `~/.local/state/quickshell/states.json`
  - Stores session state (AI settings, timer states, sidebar states)
  - Tracks Hyprland instance to detect restarts

### Global State Management
**GlobalStates.qml**: Singleton for runtime UI state coordination
- Tracks open/closed state of modules (sidebar, overview, OSK, etc.)
- Manages global keyboard state (`superDown`, screen lock state)
- Coordinates IPC handlers and global shortcuts
- Does NOT persist across restarts (see Persistent.qml for that)

### Bar Architecture
The bar (`modules/bar/`) is the top panel:
- **Bar.qml**: Creates a `PanelWindow` per monitor with auto-hide, exclusion zones, hover detection
- **BarContent.qml**: Three-section layout (left/center/right)
  - Left: Sidebar button, GitCommits widget, Media controls
  - Center: Workspaces
  - Right: Clock, Weather, Battery, SysTray, indicators (volume, network, bluetooth, notifications)
- Scrolling on left side changes brightness, right side changes volume
- Shows/hides based on `Config.options.bar.autoHide` and hover/super key press

### Appearance and Theming
- **Appearance.qml** (in `modules/common/`): Centralized theme values (colors, sizes, fonts, animations)
- **MaterialThemeLoader.qml** (service): Loads Material Design 3 color schemes
- Colors are sourced from Material You schemes and adapted for the UI
- All components use `Appearance.colors.*`, `Appearance.sizes.*`, etc.

### Hyprland Integration
- Uses Quickshell's Hyprland plugin for workspace management, window tracking, IPC
- Sends hyprctl commands for zoom, cursor control, and other compositor features
- Listens to Hyprland events for window focus, workspace changes

### Widgets and Common Components
Key reusable widgets in `modules/common/widgets/`:
- **RippleButton**: Material Design ripple effect button
- **MaterialSymbol**: Icon font rendering
- **PopupToolTip**: Hover tooltips
- **StyledPopup**: Consistent popup styling
- **CircularProgress**, **ClippedProgressBar**: Progress indicators
- **Revealer**: Animated show/hide wrapper
- **NotificationItem**, **NotificationGroup**: Notification UI

### Scripts Directory
Contains helper scripts for various tasks:
- `ai/`: AI-related utilities and prompts
- `colors/`: Color scheme generation and management
- `hyprland/`: Hyprland-specific automation
- `images/`, `videos/`: Media processing
- `thumbnails/`: Thumbnail generation

## Development Patterns

### When Adding New Widgets to Bar
1. Create the widget component in `modules/bar/YourWidget.qml`
2. Add it to `BarContent.qml` in the appropriate section (left/center/right)
3. Wrap in `BarGroup` for consistent styling
4. Add configuration options to `Config.qml` under `bar.yourWidget`
5. Use `Loader { active: Config.options.bar.yourWidget.enable }` for conditional loading

### Creating New Services
1. Add singleton QML file to `services/YourService.qml`
2. Use `pragma Singleton` at the top
3. Expose properties and functions for other components to consume
4. Services should be stateless or manage their own state internally

### IPC and Global Shortcuts
Components can define IPC handlers and shortcuts:
```qml
IpcHandler {
    target: "bar"
    function toggle(): void { /* ... */ }
}

GlobalShortcut {
    name: "barToggle"
    description: "Toggles bar"
    onPressed: { /* ... */ }
}
```

### Color and Theme Usage
Always use `Appearance.colors.*` for colors and `Appearance.m3colors.*` for Material 3 colors:
```qml
color: Appearance.colors.colLayer0
color: Appearance.m3colors.m3primary
```

Use `ColorUtils` functions for color manipulation:
```qml
ColorUtils.transparentize(color, alpha)
ColorUtils.mix(color1, color2, ratio)
```

### Animations
Use centralized animation definitions from `Appearance.animation.*`:
```qml
Behavior on opacity {
    animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
}
```

## File Locations

### Config Files
- User config: `~/.config/illogical-impulse/config.json`
- Shell config: This directory (`~/.config/quickshell/ii/`)

### State Files
- Runtime state: `~/.local/state/quickshell/states.json`
- Cache/thumbnails: Check `Directories.cache` in scripts

### Assets
- Icons and images: `assets/`
- Default configs: `defaults/`

## Git Commits Widget

The `GitCommits.qml` widget visualizes recent commit activity:
- Hardcoded to track this repository (`~/.config/quickshell/ii`)
- Runs git commands via Process to count commits per day
- Displays last 5 days as colored squares (GitHub-style)
- Refreshes every 5 minutes
- Configurable via `Config.options.bar.gitCommits.enable`

## Translation Support

The codebase supports multiple languages via `Translation.qml` service:
- Wrap user-facing strings with `Translation.tr("text")`
- Translation files in `translations/` directory
- Language selection in settings

## Key Dependencies

- **Quickshell**: QML-based Wayland shell framework
- **Qt 6**: QtQuick, QtQuick.Controls
- **Hyprland**: Wayland compositor (primary target)
- Various system tools: git, hyprctl, bash, wl-clipboard, etc.
