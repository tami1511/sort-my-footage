# 🎬 Sort My Footage

You film on your iPhone. On your laptop, Claude looks at every clip, gives it a name that
says what's in it, and puts it in the folders you choose (for example: Beach, Selfie, B-roll).
You watch every clip fly into its folder.

**Needs:** Windows 10 or 11, and Claude Code with a paid Claude plan (Pro or higher).

## Install

**The easiest way: let Claude do it.** Open Claude Code (the Code tab in the Claude desktop app,
or `claude` in a terminal) and paste this:

```
Install Sort My Footage for me from https://github.com/tami1511/sort-my-footage: download it to a temporary folder, run install.ps1 with -Yes, and tell me what you found.
```

That's it. Claude adds only what's missing (Python, ffmpeg) and puts a
**Sort My Footage** folder on your Desktop. No keys, no sign-ups, nothing to uninstall.

**Or by hand, in 3 steps:**

1. Click the green **Code** button on this page, then **Download ZIP**.
2. Unzip it (right-click > Extract All).
3. Double-click **Install.bat** and press **Enter**.
   If Windows shows "Windows protected your PC", click **More info** > **Run anyway**.

## Use

1. Open the **Sort My Footage** folder on your Desktop and double-click **Sort My Footage.bat**.
   Or just tell Claude Code "sort my footage".
2. Bring in your clips:
   - **From iCloud** (no cable): first turn on Photos in the iCloud for Windows app.
   - **iPhone cable**: plug in, unlock, tap Trust.
   - **Choose folder**: any folder of clips.
3. Type your folders, separated by commas.
4. Choose **Videos**, **Photos** or **Both**, and press **Sort**.

**Undo last sort** puts everything back with the old names.
**footage-index.md** lists every clip in words, so you can ask Claude "find the clip where...".

## What's inside

```
sort-my-footage/          the skill (copied to %USERPROFILE%\.claude\skills\sort-my-footage)
├── SKILL.md              how Claude uses it
└── scripts/
    ├── sort_footage.py   the sorting engine and the window
    ├── window.html       the animated window
    └── import_iphone.ps1 brings clips from the iPhone over a cable
Install.bat / install.ps1 the installer
```

## Privacy

- Your clips stay on your computer.
- Only small stills from each clip are shown to Claude, through your own Claude account.
- Nothing on your iPhone or in iCloud is changed: clips are copied.
- The tool only sorts. It doesn't post, upload or share anything.

## No support

This tool is shared as is, for free. There is no support and no way to report problems here.
If something goes wrong, press **Undo last sort** in the tool: it puts every file back.

License: MIT.
