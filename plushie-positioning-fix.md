# Plushie Positioning Bug

## Problem

The plushie appears correctly on the bed on iPhone 17 Pro, but floats above the bed on iPhone 16e.

**Root cause:** The background image (832x1248) is scaled to fill the screen area using `max(scaleX, scaleY)`. Different screen sizes and safe area insets produce different screen area dimensions, which changes how the image is cropped. On some devices the image is scaled by width (cropping top/bottom), on others by height (cropping sides). This shifts where the bed appears in screen coordinates, but the plushie was positioned in screen coordinates with a hardcoded offset.

## Attempt 1: Proportional offset from displayed image height

Replaced:
```swift
let plushieY = screenY - screenHeight / 2 + plushieSprite.size.height * 0.187 / 2 + 250
```

With:
```swift
let displayedImageHeight = texture.size().height * scale
let plushieY = screenY - displayedImageHeight / 2 + displayedImageHeight * 0.55
```

**Result:** Still floating on iPhone 16e (worse). The proportion 0.55 was calibrated to match the iPhone 17 Pro position, but the displayed image height varies only slightly across devices, so the offset barely changed. The fundamental issue remained: the plushie was still in screen-space, not image-space.

## Attempt 2: Parent the plushie to the city sprite (current)

Made the plushie a child of `citySprite` instead of `cropNode`, positioning it in the background image's own coordinate system:

```swift
plushieSprite.setScale(0.187 / scale)       // compensate for parent's scale
plushieSprite.position = CGPoint(x: -313, y: 63)  // image-space coords
plushieSprite.zPosition = 5
citySprite.addChild(plushieSprite)
```

**Why this should work:** The plushie's position is now relative to the center of the background image, not the screen. No matter how the image is scaled or cropped on different devices, the plushie stays at the same spot on the bed. The scale is divided by the parent's scale (`0.187 / scale`) so the plushie keeps the same visual size.

**Status:** Awaiting test on both iPhone 17 Pro and iPhone 16e.

## Coordinate derivation

The image-space coordinates `(-313, 63)` were derived from the working iPhone 17 Pro position:
- City sprite center in scene: `(size.width/2, screenY)`
- Working plushie scene position: `(60, 440.75)`
- Image-space X: `(60 - 196.5) / 0.4363 = -313`
- Image-space Y: `(440.75 - 413.5) / 0.4363 = 63`
