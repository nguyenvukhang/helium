# Wacom Kit

A tiny MacOS menubar app that brings you precision mode on Wacom
Tablet **without the translucent overlay**. Current build stands at
200kB.

<p align="center">
  <img src="https://user-images.githubusercontent.com/10664455/229349733-44e14697-889e-49c2-9ada-1b1d979c011f.png">
</p>

When triggered, the precision mode will be centered at your cursor's
current location.

<p align="center">
  <img alt="nice position" src="https://user-images.githubusercontent.com/10664455/229350722-ea7462d7-e1b4-471b-9b7c-5a4b5026d00a.png" width="500px">
</p>

If your cursor is too close to the edge, it will be offset from the
centre only just enough to fit on the screen again.

<p align="center">
  <img alt="wacom kit correction" src="https://user-images.githubusercontent.com/10664455/229350734-07c89776-225f-4866-9af1-61ece9448295.png" width="500px">
</p>

This is unlike Wacom's precision mode default behaviour, which takes a
somewhat weighted offset from the middle of the screen.

<p align="center">
  <img alt="default correction" src="https://user-images.githubusercontent.com/10664455/229350731-c72dda9b-b788-425c-9573-7e48a1990ed2.png" width="500px">
</p>

Wacom Kit's off-center correction allows much easier corner access. If
your cursor was near the corner to start with, you probably want to go
all the way to the edges.

## Requirements

Your Wacom tablet needs to already be working before installing this.
Wacom Kit requires Wacom's drivers to work.

## Caveat

This project is only tweakable at the code level, so if you want a
custom key-binding or a custom percentage of the screen for your
precision mode, you will have to edit the source code directly.

## Building

Open `Wacom Kit.xcodeproj` with XCode, build an Archive and drag that
into your `/Applications` folder.
