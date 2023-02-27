# Wacom Kit

A tiny MacOS menubar app that brings you precision mode on Wacom
Intuous without the translucent overlay. Current build stands at
200kB.

<p align="center">
  <img src="https://user-images.githubusercontent.com/10664455/221524723-9fe385c7-aff7-4006-8476-bce40849c07c.png">
</p>

When triggered, the precision mode will be centered at your cursor's
current location.

<p align="center">
  <img src="https://user-images.githubusercontent.com/10664455/221426164-4e616253-b70b-4ae3-a6e2-67283d66bc2e.png" width="500px">
</p>

Wacom Kit's precision mode will have absolutely no overlays and will
keep completely out of your way.

If your cursor is too close to the edge, it will be offset from the
centre only just enough to fit on the screen again.

<p align="center">
  <img src="https://user-images.githubusercontent.com/10664455/221426559-2a6c90fb-8fd5-4eab-8b0c-31e6412b1821.png" width="500px">
</p>

## Requirements

Your Wacom Intuous needs to already be working before installing this.
Wacom Kit requires Wacom's Drivers to work.

## Caveat

This project is only tweakable at the code level, so if you want a
custom key-binding or a custom percentage of the screen for your
precision mode, you will have to edit `AppDelegate.m` directly.

## Building

Open `Wacom Kit.xcodeproj` with XCode, build an Archive and drag that
into your `/Applications` folder.
