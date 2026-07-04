# Change Video Playback Speed

A lightweight extension for quickly changing video and audio playback speed with a toolbar click or keyboard shortcut.

The extension is designed to be simple, fast, private, and predictable. It has no popup, no floating controller, no settings page, no analytics, and no broad website access.

## Features

* Cycle playback speed with one toolbar click
* Use a keyboard shortcut to change speed
* Synchronize video and audio elements to the same playback speed
* Support media in accessible iframes
* Show a temporary on-page speed indicator
* Show the selected speed in the extension toolbar badge
* Handle rapid repeated actions sequentially per tab
* No persistent background monitoring
* No storage or browsing-history collection
* No network requests
* No analytics or tracking

## Playback Speed Cycle

The extension cycles through the following speeds:

```text
1x → 1.25x → 1.5x → 2x → 1x
```

If the current playback rate is not one of the configured values, the extension selects the next higher configured speed.

Examples:

```text
1.1x  → 1.25x
1.3x  → 1.5x
1.75x → 2x
2.5x  → 1x
```

## Usage

### Toolbar

Click the extension icon to move to the next playback speed.

## Keyboard Shortcut

The extension includes a default keyboard shortcut for quickly cycling through the available playback speeds.

Default shortcuts:

| Operating System | Shortcut               |
| ---------------- | ---------------------- |
| Windows          | `Alt+S`                |
| Linux            | `Alt+S`                |
| ChromeOS         | `Alt+S`                |
| macOS            | `Command+Shift+Period` |

The keyboard shortcut performs exactly the same action as clicking the extension icon.

Users can change the shortcut at any time through browser's extension keyboard shortcut settings.

## Project Structure

```text
change-video-playback-speed/
├── manifest.json
├── README.md
└── src/
    ├── background.js
    ├── playback.js
    └── page.js
```

### `manifest.json`

Defines the extension metadata, permissions, service worker, toolbar action, and keyboard command.

The service worker uses ES modules.

### `src/background.js`

Handles user-triggered extension events:

* Toolbar clicks
* Keyboard shortcut commands
* Active-tab lookup for keyboard commands
* Per-tab operation queues

The per-tab queue ensures rapid actions are processed sequentially within the same tab while allowing different tabs to operate independently.

Example:

```text
Press 1 → 1x    → 1.25x
Press 2 → 1.25x → 1.5x
Press 3 → 1.5x  → 2x
```

Without sequential processing, overlapping asynchronous operations could theoretically read the same playback speed before another operation applies its update.

### `src/playback.js`

Coordinates the playback-speed workflow.

The extension uses a two-pass approach.

#### Pass 1: Inspect

The extension checks accessible frames for video and audio elements and retrieves their playback state.

Media-state selection follows this priority:

1. Media in the top frame
2. Playing media in another accessible frame
3. The first accessible frame containing media

The next playback speed is calculated once for the entire tab.

#### Pass 2: Apply

The selected speed is applied to all detected video and audio elements in all accessible frames.

This keeps media synchronized to one playback rate.

After the speed is applied:

* The top frame displays the temporary speed indicator.
* The extension toolbar badge is updated.

## Iframe Handling

The extension uses a tab-level two-pass strategy for iframe support.

Example:

```text
Main page:
Video A → 1x
Video B → 1x

Iframe 1:
Video C → 1x

Iframe 2:
Audio D → 1x
```

After one action:

```text
Video A → 1.25x
Video B → 1.25x
Video C → 1.25x
Audio D → 1.25x
```

The speed is calculated once and then applied consistently across accessible frames.

Some embedded frames may not be accessible because of browser security restrictions and the extension's intentionally limited permission model.

## Page Functions

`src/page.js` contains self-contained functions executed in webpage contexts.

### `getMediaState()`

Detects video and audio elements in the current frame.

It prefers an actively playing media element when determining the frame's current playback speed. If nothing is playing, it falls back to the first media element.

### `applyPlaybackSpeed()`

Validates the requested playback speed and applies it to all video and audio elements in the current frame.

A failure on one media element does not prevent the extension from attempting to update the remaining elements.

The function also displays the speed indicator when running in the top frame.

## Toolbar Badge

After changing playback speed, the extension displays the selected value in the toolbar badge.

Possible badge values are:

```text
1
1.25
1.5
2
```

The badge is tab-specific.

## Speed Indicator

Every successful playback-speed change displays a temporary indicator in the center of the page.

Examples:

```text
1.25x
1.5x
2x
```

The indicator:

* Appears only in the top frame
* Does not intercept pointer events
* Cannot be selected
* Uses a very high stacking order
* Automatically disappears after one second

## Permissions

The extension requests only:

```json
{
  "permissions": [
    "activeTab",
    "scripting"
  ]
}
```

### `activeTab`

Provides temporary access to the active tab after the user invokes the extension.

The extension does not request permanent access to all websites.

### `scripting`

Allows the extension to execute the media detection and playback-speed functions in the user-invoked tab and accessible frames.

## Privacy

The extension:

* Does not collect user data
* Does not collect browsing history
* Does not use analytics
* Does not use tracking
* Does not make network requests
* Does not store playback history
* Does not store per-site preferences
* Does not use remote code
* Does not load external JavaScript
* Does not request broad host permissions

All playback-speed operations happen locally in the browser.

## Performance

The extension is event-driven.

It performs no continuous work while idle.

There is:

* No polling
* No `setInterval`
* No `MutationObserver`
* No persistent content script
* No automatic media monitoring
* No background network activity

Work occurs only after a toolbar click or keyboard shortcut.

Each action performs:

```text
User action
    ↓
Inspect accessible frames
    ↓
Select current playback state
    ↓
Calculate next speed once
    ↓
Apply speed across accessible frames
    ↓
Show indicator in top frame
    ↓
Update toolbar badge
```

## Security Design

The extension follows a minimal-capability approach.

It intentionally avoids:

* Broad host permissions
* Remote code
* External dependencies
* Analytics SDKs
* Advertising SDKs
* Remote configuration
* Web-accessible resources
* Unnecessary message listeners
* Native messaging
* Persistent page monitoring

Playback speeds are validated before being applied to media elements.

## Known Limitations

* Some browser-protected pages do not allow script injection.
* Some embedded cross-origin players may not be accessible under the extension's limited permission model.
* Websites may independently override playback speed after the extension applies it.
* The extension intentionally does not monitor pages continuously to reapply playback speed.
* Mobile browser support depends on the browser and platform's extension capabilities.

## Design Philosophy

Change Video Playback Speed is intentionally focused on one task:

> Change playback speed quickly, without menus, overlays, configuration, tracking, or permanent website access.

The extension favors explicit user actions, limited permissions, predictable behavior, and minimal background activity over automatic playback management.

### License

The source code for this project is licensed under the GNU General Public License v3.0 (GPLv3). See the `LICENSE` file for the full license terms.

If you fork or build upon this project, attribution to the original project is appreciated.