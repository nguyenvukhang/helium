# Helium

Helium is a tiny MacOS menubar app that brings you precision mode on
Wacom Tablet **without the [translucent overlay]()**. Current build stands
at 300kB.

<img src="https://user-images.githubusercontent.com/10664455/230075724-e0196326-d220-48fb-a1fb-39f97d73049f.png">

When triggered, the precision mode will be centered at your cursor's
current location.

<p align="center">
  <img alt="focus mode" src="https://user-images.githubusercontent.com/10664455/230080680-3fc0f892-4050-49eb-907f-17b67900a4ab.png" width="500px">
</p>

If your cursor is too close to the edge, it will be offset from the
centre only just enough to fit on the screen again.

<p align="center">
  <img alt="heliumn's correction" src="https://user-images.githubusercontent.com/10664455/230081231-80d6e545-d2f5-407b-80fd-55e8bf18308d.png" width="500px">
</p>

This is unlike Wacom's precision mode default behaviour, which takes a
somewhat weighted offset from the center of the screen.

<p align="center">
  <img alt="wacom's correction" src="https://user-images.githubusercontent.com/10664455/230080640-fb285013-9a32-4f2f-b3d3-d44b0ae3b9f0.png" width="500px">
</p>

Helium's correction allows for much easier corner access. If your
cursor was near the corner to start with, you probably want to go all
the way to the edges.

## Requirements

Your Wacom tablet needs to already be working before installing this.
Helium requires Wacom's drivers to work.

## Building

Open `Helium.xcodeproj` with XCode, build an Archive and drag that
into your `/Applications` folder.

<p align="center">⠀</p>
<p align="center">⠀</p>
<p align="center"><code>π</code></p>
<p align="center">⠀</p>

##### P.S.

Here's how Wacom's implementation of precision mode looks like:

<img alt="wacom's impl" src="https://user-images.githubusercontent.com/10664455/230082390-7bcf5508-cbe6-4d79-9cab-25916b3900d1.png">
