# 🎬 Sort My Footage

You film on your iPhone. On your Windows laptop, Claude looks at every photo and clip, gives it
a name that says what's in it, and puts it in the folders you choose (for example: Beach, Selfie,
B-roll). You watch them swirl into a spiral and then fly into their folders.

**Who it's for:** Windows computers only (it doesn't work on a Mac). It brings photos and videos
straight from an **iPhone**. Photos from any other phone work too, once they're in a folder on the computer.

**Needs:** Windows 10 or 11, and Claude Code with a paid Claude plan (Pro or higher).
The tool is free. Sorting uses your own Claude plan.

## Install

**The easiest way: let Claude do it.** Open Claude Code (the Code tab in the Claude desktop app,
or `claude` in a terminal) and paste this:

```
Install Sort My Footage for me from https://github.com/tami1511/sort-my-footage: download it to a temporary folder, run install.ps1 with -Yes, and tell me what you found.
```

That's it. Claude adds only what's missing (Python, ffmpeg) and puts a
**Sort My Footage** folder on your Desktop. No keys and no sign-ups.

**Or by hand, in 3 steps:**

1. Click the green **Code** button on this page, then **Download ZIP**.
2. Unzip it (right-click > Extract All).
3. Double-click **Install.bat** and press **Enter**.
   If Windows shows "Windows protected your PC", click **More info** > **Run anyway**.

## Use

1. Open the **Sort My Footage** folder on your Desktop and double-click **Sort My Footage.bat**.
   Or just tell Claude Code "sort my footage".
2. Type your folders, separated by commas, and choose **Videos**, **Photos** or **Both**.
3. Bring in your clips:
   - **From iCloud** (no cable; first turn on Photos in the iCloud for Windows app) or
     **iPhone cable** (plug in, unlock, tap Trust): the clips come in and are sorted straight away.
   - **Choose folder** (any folder of clips), then press **Sort**.
4. After a sort, press **R** to watch the animation again.

Before anything moves, the tool checks every answer from Claude. Photos it isn't sure about go to
**Other**, so take a quick look at that folder. Claude can make mistakes.

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

## Remove it

Delete the **Sort My Footage** folder on your Desktop (move your sorted clips out first) and the
folder `%USERPROFILE%\.claude\skills\sort-my-footage`. Python and ffmpeg stay; remove them in
Windows Settings > Apps if you don't need them.

## Privacy

- Your clips stay on your computer.
- Claude only sees small preview images, through your own Claude account. It can't open
  anything else on your computer.
- Nothing on your iPhone or in iCloud is changed: clips are copied.
- The tool only sorts. It doesn't post, upload or share anything.

## No support

This tool is shared as is, for free. There is no support and no way to report problems here.
If something goes wrong, press **Undo last sort** in the tool: it puts every file back.

License: MIT.
