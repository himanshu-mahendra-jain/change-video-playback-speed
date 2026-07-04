export function getMediaState() {
    const media = document.querySelectorAll("video, audio");

    if (media.length === 0) {
        return {
            hasMedia: false,
            isPlaying: false,
            playbackRate: 1
        };
    }

    let selectedMedia = null;
    let isPlaying = false;

    // Prefer the first actively playing media element.
    for (const element of media) {
        if (
            !element.paused &&
            !element.ended &&
            element.readyState > 2
        ) {
            selectedMedia = element;
            isPlaying = true;
            break;
        }
    }

    selectedMedia ??= media[0];

    const playbackRate =
        Number.isFinite(selectedMedia.playbackRate) &&
            selectedMedia.playbackRate > 0
            ? selectedMedia.playbackRate
            : 1;

    return {
        hasMedia: true,
        isPlaying,
        playbackRate
    };
}


export function applyPlaybackSpeed(speed) {
    const ALLOWED_SPEEDS = Object.freeze([
        1,
        1.2,
        1.5,
        2
    ]);

    if (
        !Number.isFinite(speed) ||
        !ALLOWED_SPEEDS.includes(speed)
    ) {
        return;
    }

    const media = document.querySelectorAll("video, audio");

    // A failure on one media element must not prevent updating others.
    for (const element of media) {
        try {
            element.playbackRate = speed;
        } catch {
            // Continue with the remaining media elements.
        }
    }

    // Only the top frame displays the visual indicator.
    if (window !== window.top) {
        return;
    }

    const INDICATOR_ID = "cvps-speed-indicator";

    const existingIndicator =
        document.getElementById(INDICATOR_ID);

    if (existingIndicator) {
        existingIndicator.remove();
    }

    const indicator = document.createElement("div");

    indicator.id = INDICATOR_ID;
    indicator.textContent = `${speed}x`;

    Object.assign(indicator.style, {
        position: "fixed",
        top: "50%",
        left: "50%",
        transform: "translate(-50%, -50%)",
        background: "rgba(0, 0, 0, 0.75)",
        color: "#ffffff",
        padding: "10px 20px",
        borderRadius: "6px",
        fontSize: "24px",
        fontWeight: "bold",
        fontFamily: "Arial, sans-serif",
        lineHeight: "1.2",
        zIndex: "2147483647",
        pointerEvents: "none",
        userSelect: "none"
    });

    document.documentElement.appendChild(indicator);

    setTimeout(() => {
        indicator.remove();
    }, 1000);
}