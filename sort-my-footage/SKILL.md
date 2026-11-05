---
name: sort-my-footage
description: Sort phone photos and videos on a Windows laptop. Claude looks at each clip and photo, gives it a name that says what is in it, and moves it into folders the user types (for example "Beach, Selfie, B-roll"), with an animated window, Undo, and a footage-index.md that lists every clip in words. Brings clips from an iPhone through iCloud for Windows, a USB cable, or an iCloud .zip. Use when the user says sort my footage, organize my clips, rename my IMG_ files, open the sorting tool, bring my iPhone clips to the laptop, or "find the clip where..." in footage that was already sorted.
---

# Sort My Footage

A local tool for Windows. Needs Python 3, ffmpeg and ffprobe, Microsoft Edge (for the window)
and Claude Code signed in with a paid Claude plan (`claude auth status`).

Code: `scripts/` in this skill. The user's files: `Desktop\Sort My Footage\` (set
`SORT_FOOTAGE_HOME` to use another folder). iPhone clips land in `Sort My Footage\iPhone Footage\`.

## Open the window

Double-click `Desktop\Sort My Footage\Sort My Footage.bat`, or run:

```bash
pythonw "%USERPROFILE%\.claude\skills\sort-my-footage\scripts\sort_footage.py"
```

In the window: type the folders, pick **Videos / Photos / Both**, then either
- **From iCloud** or **iPhone cable**: brings the new clips in and sorts them straight away, or
- **Choose folder** / **iCloud .zip**, then **Sort**.

The clips swirl into a spiral, then fly to their folders. **Undo last sort** puts everything
back with the old names. Only files loose in the chosen folder are sorted, so sorting again
only touches new clips. After a sort, press **R** to replay the animation.

## From the terminal

```bash
python "%USERPROFILE%\.claude\skills\sort-my-footage\scripts\sort_footage.py" --folder "<folder>" --folders "Beach, Selfie, B-roll"
python "%USERPROFILE%\.claude\skills\sort-my-footage\scripts\sort_footage.py" --folder "<folder>" --undo
```

- Always ask the user for the folder names; never invent them. "Other" is added for misfits.
- If Claude isn't signed in, the user runs `claude auth login` once.
- Moving files is the user's data: say what will move before sorting a folder they did not name.

## Find a clip after a sort

Read `footage-index.md` (or `footage-index.csv`) in the sorted folder: one line per clip with
folder, new name, length, date and a one-sentence description. Search it and answer with the path.

## Safety

- The window's local server listens on 127.0.0.1 only, with a random key in an HttpOnly,
  SameSite=Strict cookie, plus Host and Origin checks, so web pages cannot drive it.
- Claude runs with only the Read tool, limited to this run's preview images, no MCP servers and
  no saved session. Text inside images is treated as content, never as instructions.
- Every answer is checked before anything moves: known IDs only, only the user's folders,
  and low-confidence answers go to "Other". File names are cleaned to `a-z0-9-`.
- Undo only moves files inside the sorted folder. Zip import keeps file names only.
- Imports copy; nothing on the iPhone or in iCloud is changed.
- Only small preview images are shown to Claude, through the user's own Claude account.
