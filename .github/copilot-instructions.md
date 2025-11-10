# Copilot Instructions - illogical-impulse

## Project Overview

**illogical-impulse** is a comprehensive Wayland desktop shell built with **Quickshell** (QML-based) for Hyprland. It provides a modular desktop environment including bar, sidebars, dock, lock screen, overview, OSD, and more.

## Running & Testing

```bash
# Start shell
quickshell -c ii

# Open settings UI (separate Qt application)
qs -p settings.qml
# Or use keybind: Super+I

# Reload shell after changes
# Use Hyprland: Ctrl+Super+R
# Or: killall quickshell; quickshell -c ii

# Debug mode with verbose logging
QUICKSHELL_LOG=debug quickshell -c ii

# Test specific module
quickshell -c ii --test-module bar
```

## Architecture

### Entry Point: `shell.qml`

- Sets Qt pragmas (scale, controls style)
- Imports all module namespaces (`qs.modules.*`, `qs.services`)
- Uses `LazyLoader` to conditionally load modules based on `Config.ready` and enable flags
- Initializes singletons on startup: `MaterialThemeLoader`, `Config`, `Persistent`, etc.
- Manages global IPC commands and shortcuts

### Module System (`modules/`)

Each module is self-contained and lazy-loaded:

- **bar/**: Top panel with workspaces, system indicators, media controls
- **dock/**: App launcher dock with favorites and running apps
- **sidebarLeft/**: App launcher sidebar with search
- **sidebarRight/**: Quick settings, network, bluetooth, volume mixer
- **lock/**: Lock screen with PAM authentication
- **overview/**: Window/workspace overview (exposé style)
- **onScreenDisplay/**: Volume/brightness OSD notifications
- **notificationPopup/**: Desktop notification toasts
- **settings/**: Settings UI pages (loaded separately via `settings.qml`)

Modules respond to IPC commands and global shortcuts, coordinate via `GlobalStates.qml`.

### Services vs Common (`services/` vs `modules/common/`)

- **`services/`**: Singleton QML services (use `pragma Singleton`)

  - System integration: `Audio`, `Bluetooth`, `Network`, `Brightness`, `Battery`, `Notifications`
  - Features: `Ai`, `Translation`, `Wallpapers`, `MprisController`, `Cliphist`
  - Stateless or manage their own state internally
  - Always accessed via singleton pattern: `Audio.volume`, `Network.connected`

- **`modules/common/`**: Reusable UI components and utilities
  - **`Config.qml`**: User config from `~/.config/illogical-impulse/config.json`
  - **`Persistent.qml`**: Runtime state to `~/.local/state/quickshell/states.json`
  - **`Appearance.qml`**: Centralized theme (colors, fonts, animations, sizes)
  - **`GlobalStates.qml`**: Runtime UI state coordination (sidebar open/closed, etc.)
  - **`widgets/`**: Reusable components (`RippleButton`, `MaterialSymbol`, `StyledPopup`, etc.)
  - **`functions/`**: Utility functions (`ColorUtils`, `StringUtils`, etc.)

### Configuration System

#### Config.qml

```qml
// Access nested config
Config.options.bar.autoHide
Config.options.appearance.transparency.enable
Config.options.modules.dock.position // "bottom", "left", "right"

// Auto-saves with debouncing (readWriteDelay = 50ms by default)
Config.options.bar.enable = false // Auto-saved to config.json

// Nested structure mirrors JSON at ~/.config/illogical-impulse/config.json
// Always check Config.ready before accessing options
if (Config.ready) {
    myProperty = Config.options.something
}
```

#### Persistent.qml

```qml
// Runtime state (survives reload, not Hyprland restart)
Persistent.states.ai.model = "gemini"
Persistent.states.sidebar.bottomGroup.tab = 2
Persistent.states.dock.pinnedApps = ["firefox", "kitty", "code"]

// Tracks Hyprland instance to detect restarts
Persistent.isNewHyprlandInstance // true if Hyprland restarted

// Use for user preferences that should persist across reloads
// but reset on compositor restart
```

#### GlobalStates.qml

```qml
// UI state (does NOT persist - runtime only)
GlobalStates.sidebarRightOpen = true
GlobalStates.overviewOpen = false
GlobalStates.screenLocked = false
GlobalStates.currentWorkspace = 1

// Use for temporary UI state that should reset on reload
// Good for: panel visibility, popup states, current selection
```

### Theme & Appearance

Always use `Appearance.*` for consistent styling:

```qml
// Colors - use semantic names
color: Appearance.colors.colLayer0          // Background layers
color: Appearance.colors.colPrimary         // Primary accent
color: Appearance.colors.colSecondary       // Secondary accent
color: Appearance.colors.colText            // Text color
color: Appearance.m3colors.m3primary        // Material 3 colors
color: Appearance.m3colors.m3onSurface      // Text on surface

// Color utilities (from modules/common/functions)
import qs.modules.common.functions as CF
color: CF.ColorUtils.transparentize(Appearance.colors.colPrimary, 0.5)
color: CF.ColorUtils.mix(color1, color2, 0.3)
color: CF.ColorUtils.darken(Appearance.colors.colLayer1, 0.2)

// Animations - use predefined animation objects
Behavior on opacity {
    animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
}
Behavior on x {
    animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
}

// Fonts, sizes, rounding
font.pixelSize: Appearance.font.pixelSize.large        // 16px
font.pixelSize: Appearance.font.pixelSize.medium       // 14px
font.pixelSize: Appearance.font.pixelSize.small        // 12px
font.family: Appearance.font.family                    // System font
font.weight: Font.Medium

radius: Appearance.rounding.small          // 8px
radius: Appearance.rounding.medium         // 12px
radius: Appearance.rounding.large          // 16px

implicitHeight: Appearance.sizes.barHeight              // 48px
implicitWidth: Appearance.sizes.sidebarWidth            // 400px
spacing: Appearance.sizes.defaultSpacing                // 8px
```

### Translation System

Wrap ALL user-facing strings with `Translation.tr()`:

```qml
text: Translation.tr("Settings")
tooltip: Translation.tr("Open settings")
label: Translation.tr("Volume")

// With placeholders - use %1, %2, etc.
text: Translation.tr("Model set to %1").arg(modelName)
text: Translation.tr("%1 of %2 items").arg(current).arg(total)

// Plurals - English key should include singular/plural logic
text: Translation.tr("1 notification", "%1 notifications", count).arg(count)

// Context-specific translations (same word, different meaning)
text: Translation.tr("Open") // verb - to open something
text: Translation.tr("Open", "state") // adjective - not closed
```

Translation files: `translations/*.json` (9 languages supported: pt_BR, en_US, zh_CN, ja_JP, ru_RU, it_IT, he_HE, uk_UA, vi_VN)

**Important**: When adding new translatable strings:

1. Add English text as key in code
2. Run translation tool: `cd translations/tools && python translate.py`
3. Review auto-translations for accuracy
4. Update CHANGELOG.md with new strings

### Adding Features

#### New Bar Widget

1. Create `modules/bar/YourWidget.qml`

   ```qml
   import QtQuick
   import Quickshell
   import qs.modules.common as Common
   import qs.services as Services

   Item {
       id: root
       implicitWidth: content.implicitWidth
       implicitHeight: Common.Appearance.sizes.barHeight

       // Widget implementation
   }
   ```

2. Add to `BarContent.qml` in appropriate section (left/center/right)

   ```qml
   // In leftContent, centerContent, or rightContent
   Loader {
       active: Common.Config.ready && Common.Config.options.bar.yourWidget.enable
       sourceComponent: YourWidget {}
   }
   ```

3. Add config options to `modules/common/Config.qml`:

   ```qml
   // Inside Config.options.bar object
   property JsonObject yourWidget: JsonObject {
       property bool enable: true
       property string position: "left" // "left", "center", "right"
       property int order: 5
   }
   ```

4. Add to settings UI in `modules/settings/BarConfig.qml`

#### New Service

1. Create `services/YourService.qml`

   ```qml
   pragma Singleton
   import QtQuick
   import Quickshell

   Singleton {
       id: root

       // Properties
       property bool available: false
       property string status: "idle"

       // Signals
       signal statusChanged()

       // Functions
       function doSomething(): void {
           // Implementation
       }

       // Internal components
       Component.onCompleted: {
           initialize()
       }
   }
   ```

2. Import in modules: `import qs.services as Services`
3. Use: `Services.YourService.doSomething()`

#### New Module

1. Create module directory: `modules/yourModule/`
2. Create main file: `modules/yourModule/YourModule.qml`
3. Add IPC handler and shortcuts
4. Register in `shell.qml`:

   ```qml
   property bool enableYourModule: Config.options.modules.yourModule.enable

   LazyLoader {
       id: yourModuleLoader
       active: Config.ready && enableYourModule
       component: YourModule {}
   }
   ```

5. Add config section in `Config.qml`

#### IPC & Shortcuts

```qml
// In your module QML file
IpcHandler {
    target: "moduleName"

    function toggle(): void {
        visible = !visible
    }

    function show(): void {
        visible = true
    }

    function hide(): void {
        visible = false
    }
}

GlobalShortcut {
    name: "moduleToggle"
    description: Translation.tr("Toggle module")
    onPressed: {
        toggle()
    }
}

// Usage from command line:
// quickshell --ipc moduleName toggle
```

## Common Patterns

### Lazy Loading

```qml
// Basic lazy loading
LazyLoader {
    active: Config.ready && Config.options.module.enable
    component: YourModule {}
}

// Lazy loading with dynamic properties
LazyLoader {
    id: loader
    active: someCondition

    Binding {
        target: loader.item
        property: "someProp"
        value: someValue
        when: loader.item !== null
    }
}

// Conditional component loading
Loader {
    active: condition
    sourceComponent: Component {
        YourComponent {}
    }
}
```

### Process Execution

```qml
// Basic process
Process {
    id: myProc
    command: ["bash", "-c", "your-command"]
    running: true
    stdout: SplitParser {
        onRead: data => {
            console.log("Output:", data)
        }
    }
}

// Process with error handling
Process {
    id: myProc
    command: ["bash", "-c", "your-command"]
    running: true

    stdout: SplitParser {
        onRead: data => handleOutput(data)
    }

    stderr: SplitParser {
        onRead: data => console.error("Error:", data)
    }

    onExited: (code, status) => {
        if (code !== 0) {
            console.error("Process failed:", code)
        }
    }
}
```

### File I/O

```qml
// Reading files
FileView {
    id: fileReader
    path: "/path/to/file"

    onLoaded: {
        const content = text()
        const json = JSON.parse(content)
        processData(json)
    }
}

// Writing files (use Process)
Process {
    id: writer
    command: ["bash", "-c", `echo '${data}' > ${path}`]
    running: true
}
```

### State Management

```qml
// Use states for complex UI transitions
Item {
    id: root

    states: [
        State {
            name: "expanded"
            PropertyChanges { target: root; height: 400 }
        },
        State {
            name: "collapsed"
            PropertyChanges { target: root; height: 48 }
        }
    ]

    transitions: Transition {
        NumberAnimation {
            properties: "height"
            duration: Appearance.animation.elementMove.duration
            easing.type: Appearance.animation.elementMove.easing
        }
    }
}
```

### Signals and Connections

```qml
// Defining signals
signal itemClicked(string itemId)
signal statusChanged()

// Connecting to signals
Connections {
    target: someObject
    function onSomethingChanged() {
        handleChange()
    }
}

// Emitting signals
itemClicked("item-123")
```

## Key Dependencies

- **Quickshell**: QML Wayland shell framework (provides `PanelWindow`, `LazyLoader`, IPC, etc.)
  - Version: Latest from git
  - Docs: https://quickshell.outfoxxed.me
- **Qt 6**: QtQuick, QtQuick.Controls, QtQuick.Window
  - Minimum version: 6.5
- **Hyprland**: Primary compositor (uses `Quickshell.Hyprland` plugin)
  - Version: 0.40+
- System tools:
  - Required: `git`, `hyprctl`, `bash`, `wl-clipboard`
  - Optional: `pactl` (audio), `brightnessctl` (brightness), `notify-send` (notifications)

## File Structure

```
~/.config/quickshell/ii/              # Shell config (this repo)
├── shell.qml                         # Entry point
├── settings.qml                      # Settings app entry
├── modules/
│   ├── bar/                          # Top bar module
│   ├── dock/                         # Dock module
│   ├── sidebarLeft/                  # Left sidebar
│   ├── sidebarRight/                 # Right sidebar
│   ├── lock/                         # Lock screen
│   ├── overview/                     # Window overview
│   ├── onScreenDisplay/              # OSD
│   ├── notificationPopup/            # Notifications
│   ├── settings/                     # Settings pages
│   └── common/                       # Shared components
│       ├── Config.qml
│       ├── Persistent.qml
│       ├── Appearance.qml
│       ├── GlobalStates.qml
│       ├── widgets/                  # UI widgets
│       └── functions/                # Utility functions
├── services/                         # Singleton services
│   ├── Audio.qml
│   ├── Bluetooth.qml
│   ├── Network.qml
│   └── ...
└── translations/                     # i18n files
    ├── pt_BR.json
    ├── en_US.json
    └── ...

~/.config/illogical-impulse/          # User config
└── config.json                       # User preferences

~/.local/state/quickshell/            # Runtime state
└── states.json                       # Persistent runtime state

~/Pictures/Wallpapers/                # Default wallpapers
```

## Settings App (settings.qml)

Separate Qt application loaded via `qs -p settings.qml`:

- Uses `ApplicationWindow` (not `PanelWindow`)
- Pages in `modules/settings/*.qml`:
  - `QuickConfig.qml`: Quick toggles and common settings
  - `GeneralConfig.qml`: General shell settings
  - `BarConfig.qml`: Bar configuration
  - `BackgroundConfig.qml`: Wallpaper and background
  - `InterfaceConfig.qml`: Theme and appearance
  - `ServicesConfig.qml`: External services (AI, etc.)
  - `AdvancedConfig.qml`: Advanced options
  - `AboutConfig.qml`: About and credits
- Navigation rail with 8 pages
- Direct manipulation of `Config.options.*` (readWriteDelay = 0 for immediate save)
- Live preview of changes

## Common Gotchas

1. **Import Aliases**: Always use aliases for clarity

   ```qml
   import qs.modules.common as Common
   import qs.modules.common.functions as CF
   import qs.services as Services

   // Then use: Common.Config, CF.ColorUtils, Services.Audio
   ```

2. **Config Ready**: Always check `Config.ready` before accessing options

   ```qml
   // Wrong
   visible: Config.options.module.enable

   // Right
   visible: Config.ready && Config.options.module.enable
   ```

3. **LazyLoader Active**: Module only loads when `active` is true (saves memory)

   - Use for optional modules
   - Don't use for critical components

4. **Translation Keys**: English text is the key, must exist in ALL translation files

   - Use descriptive English text
   - Keep keys consistent across similar contexts
   - Run translation tool after adding new strings

5. **Persistent vs GlobalStates**:

   - `Persistent` survives reload, cleared on Hyprland restart
   - `GlobalStates` is runtime only, cleared on reload
   - `Config` survives everything, saved to disk

6. **Module Enable Flags**: Check `shell.qml` for `enableModuleName` properties

   - Each module has a dedicated enable property
   - Controlled by Config.options.modules.moduleName.enable

7. **Singleton Pragma**: Services MUST have this structure:

   ```qml
   pragma Singleton
   import QtQuick

   Singleton {
       id: root
       // ... implementation
   }
   ```

8. **Window Types**:

   - Use `PanelWindow` for shell UI (bar, dock, sidebars)
   - Use `ApplicationWindow` for standalone apps (settings)

9. **Property Bindings**: Be careful with binding loops

   ```qml
   // Wrong - creates binding loop
   width: height
   height: width

   // Right - use explicit values or one-way binding
   width: 100
   height: width
   ```

10. **Signal Handlers**: Use function syntax for clarity

    ```qml
    // Old style (avoid)
    onClicked: { doSomething() }

    // New style (prefer)
    onClicked: () => { doSomething() }
    ```

## Debugging & Troubleshooting

### Logging

```qml
// Basic logging
console.log("Info message")
console.warn("Warning message")
console.error("Error message")

// Structured logging
console.log("Module loaded:", moduleName, "enabled:", enabled)

// Conditional logging
if (Config.options.advanced.debugMode) {
    console.log("Debug info:", data)
}
```

### Common Issues

1. **Module not loading**: Check `Config.ready` and enable flag
2. **Styling not applied**: Verify `Appearance.*` imports
3. **Config not saving**: Check file permissions in `~/.config/illogical-impulse/`
4. **Translation missing**: Run translation tool, check all 9 language files
5. **IPC not working**: Verify target name matches module name
6. **Process hangs**: Add timeout or check command syntax
7. **Memory leak**: Check LazyLoader active conditions

### Performance Tips

- Use `LazyLoader` for optional modules
- Avoid creating components in loops, use `Repeater` or `ListView`
- Use `visible: false` instead of destroying components when possible
- Cache expensive computations
- Use `Binding { when: condition }` for conditional property updates

## Development Workflow

1. **Edit QML files** with your preferred editor

   - VSCode with QML extension recommended
   - Enable QML linting

2. **Reload shell** to test changes

   - Fast reload: Ctrl+Super+R in Hyprland
   - Full restart: `killall quickshell; quickshell -c ii`

3. **Check logs** for errors

   - Terminal output if run from terminal
   - Log files: `~/.local/share/quickshell/*/log.qslog`
   - Use `QUICKSHELL_LOG=debug` for verbose output

4. **Test settings changes**

   - Via settings UI: `qs -p settings.qml`
   - Manual config edit: `~/.config/illogical-impulse/config.json`
   - Verify both methods work

5. **Add translations** for new strings

   - Add English text in code with `Translation.tr()`
   - Run: `cd translations/tools && python translate.py`
   - Review and adjust auto-translations
   - Test in different languages

6. **Update documentation**

   - Update CHANGELOG.md with changes
   - Update relevant docs in `docs/`
   - Update TODO.md if needed
   - Update this file if adding new patterns

7. **Commit changes**
   ```bash
   git add -A
   git commit -m "feat: descriptive commit message"
   # Follow conventional commits format
   ```

## Code Style Guidelines

### QML Formatting

```qml
// Property order: id, implicit sizes, properties, signals, functions, children
Item {
    id: root
    implicitWidth: 100
    implicitHeight: 100

    property string title: "Example"
    property bool enabled: true

    signal clicked()

    function doSomething(): void {
        // implementation
    }

    Rectangle {
        // child items
    }
}

// Use 4 spaces for indentation
// Use camelCase for properties and functions
// Use PascalCase for component names
// Add type hints to functions
```

### Naming Conventions

- **Properties**: `camelCase` (e.g., `isVisible`, `backgroundColor`)
- **Functions**: `camelCase` (e.g., `handleClick`, `updateState`)
- **Components**: `PascalCase` (e.g., `MyButton`, `CustomWidget`)
- **Constants**: `UPPER_CASE` or `camelCase` (e.g., `MAX_WIDTH` or `maxWidth`)
- **IDs**: `camelCase` (e.g., `mainContent`, `topBar`)

### Comments

```qml
// Single-line comments for brief explanations

/*
 * Multi-line comments for complex logic
 * or detailed explanations
 */

/**
 * JSDoc-style comments for public APIs
 * @param {string} text - The text to display
 * @returns {void}
 */
function setText(text: string): void {
    // implementation
}
```

## Best Practices

1. **Modular Design**: Keep components focused and reusable
2. **State Management**: Use appropriate storage (Config/Persistent/GlobalStates)
3. **Performance**: Lazy load optional components, avoid unnecessary updates
4. **Accessibility**: Use semantic colors, proper contrast, keyboard navigation
5. **i18n**: Wrap all user-facing text with Translation.tr()
6. **Error Handling**: Handle process failures, file I/O errors, null checks
7. **Documentation**: Comment complex logic, update docs with changes
8. **Testing**: Test on different screens, languages, themes

## Documentation Resources

- **CLAUDE.md**: Comprehensive architecture reference and AI instructions
- **CHANGELOG.md**: Recent changes and version history
- **docs/**: Detailed technical documentation
  - `docs/architecture.md`: System architecture
  - `docs/modules.md`: Module documentation
  - `docs/services.md`: Service documentation
  - `docs/configuration.md`: Configuration guide
- **translations/tools/README.md**: Translation system guide
- **TODO.md**: Planned features and improvements

## Final Reminder

**At the end of every change that adds/modifies user-facing strings:**

1. Update all 9 translation files in `translations/`

   - Use the translation tool: `cd translations/tools && python translate.py`
   - Review auto-translations for accuracy and context

2. Update `CHANGELOG.md`

   - Add entry under appropriate version/section
   - Include new features, fixes, or changes

3. Update relevant documentation

   - Module docs if adding features
   - This file if adding new patterns
   - README if changing user-facing behavior

4. Update `TODO.md`

   - Mark completed items
   - Add new tasks if discovered

5. Commit with descriptive message
   - Follow conventional commits format
   - Include scope if relevant: `feat(bar): add new widget`

This ensures consistency, maintainability, and a great user experience across all supported languages.
