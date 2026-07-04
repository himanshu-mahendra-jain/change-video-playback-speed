import {
    getMediaState,
    applyPlaybackSpeed
} from "./page.js";


const SPEEDS = Object.freeze([
    1,
    1.2,
    1.5,
    2
]);


export async function changePlaybackSpeed(tabId) {
    if (!Number.isInteger(tabId)) {
        return;
    }

    try {
        // Pass 1: inspect media in every accessible frame.
        const results = await chrome.scripting.executeScript({
            target: {
                tabId,
                allFrames: true
            },
            func: getMediaState
        });

        const mediaFrames = results
            .filter((result) =>
                result?.result?.hasMedia === true &&
                Number.isFinite(result.result.playbackRate)
            )
            .map((result) => ({
                frameId: result.frameId,
                isPlaying: result.result.isPlaying === true,
                playbackRate: result.result.playbackRate
            }));

        if (mediaFrames.length === 0) {
            return;
        }

        /*
         * Selection priority:
         * 1. Media in the top frame.
         * 2. Playing media in another frame.
         * 3. First frame containing media.
         */
        const selectedMedia =
            mediaFrames.find((frame) => frame.frameId === 0) ??
            mediaFrames.find((frame) => frame.isPlaying) ??
            mediaFrames[0];

        const currentSpeed = selectedMedia.playbackRate;

        // Use the next higher configured speed, then cycle back to 1x.
        const nextSpeed =
            SPEEDS.find((speed) => speed > currentSpeed) ??
            SPEEDS[0];

        if (!SPEEDS.includes(nextSpeed)) {
            return;
        }

        /*
         * Pass 2: apply one synchronized speed to media in every
         * accessible frame. The top frame also shows the indicator.
         */
        await chrome.scripting.executeScript({
            target: {
                tabId,
                allFrames: true
            },
            func: applyPlaybackSpeed,
            args: [nextSpeed]
        });

        await chrome.action.setBadgeText({
            tabId,
            text: String(nextSpeed)
        });
    } catch (error) {
        console.error(
            "Unable to change playback speed:",
            error
        );
    }
}