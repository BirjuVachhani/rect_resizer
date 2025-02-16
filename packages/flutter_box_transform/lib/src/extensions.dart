import 'dart:ui';

import 'package:box_transform/box_transform.dart';
import 'package:flutter/rendering.dart' as widgets;
import 'package:vector_math/vector_math.dart';

import 'ui_result.dart';

/// Provides convenient methods for [RawResizeResult].
extension ResizeResultExt on RawResizeResult {
  /// Converts a `ResizeResult` from `rect_resizer` to a `UIResizeResult`
  UIResizeResult toUI() {
    return UIResizeResult(
      rect: rect.toRect(),
      oldRect: oldRect.toRect(),
      boundingRect: boundingRect.toRect(),
      oldBoundingRect: oldBoundingRect.toRect(),
      flip: flip,
      resizeMode: resizeMode,
      delta: delta.toOffset(),
      rawSize: rawSize.toSize(),
      minWidthReached: minWidthReached,
      minHeightReached: minHeightReached,
      maxWidthReached: maxWidthReached,
      maxHeightReached: maxHeightReached,
      largestRect: largestRect.toRect(),
      handle: handle,
    );
  }
}

/// Provides convenient methods for [RawMoveResult].
extension MoveResultExt on RawMoveResult {
  /// Converts a `MoveResult` from `rect_resizer` to a `UIMoveResult`
  UIMoveResult toUI() {
    return UIMoveResult(
      rect: rect.toRect(),
      oldRect: oldRect.toRect(),
      boundingRect: boundingRect.toRect(),
      oldBoundingRect: oldBoundingRect.toRect(),
      delta: delta.toOffset(),
      rawSize: rawSize.toSize(),
      largestRect: largestRect.toRect(),
    );
  }
}

/// Provides convenient methods for [RawRotateResult].
extension RotateResultExt on RawRotateResult {
  /// Converts a `RotateResult` from `rect_resizer` to a `UIRotateResult`
  UIRotateResult toUI() {
    return UIRotateResult(
      rect: rect.toRect(),
      boundingRect: boundingRect.toRect(),
      oldBoundingRect: oldBoundingRect.toRect(),
      delta: delta.toOffset(),
      rawSize: rawSize.toSize(),
      rotation: rotation,
    );
  }
}

/// Provides convenient methods for [Box].
extension BoxExt on Box {
  /// Converts a `Box` from `rect_resizer` to a `Rect`
  Rect toRect() => Rect.fromLTWH(left, top, width, height);
}

/// Provides convenient methods for [Rect].
extension RectExt on Rect {
  /// Converts a `Rect` to a `Box` from `rect_resizer`
  Box toBox() => Box.fromLTRB(left, top, right, bottom);
}

/// Provides convenient methods for [Vector2].
extension Vector2Ext on Vector2 {
  /// Converts a `Vector2` from `vector_math` to a `Offset`
  Offset toOffset() => Offset(x, y);
}

/// Provides convenient methods for [Offset].
extension UIVector2Ext on Offset {
  /// Converts a `Offset` to a `Vector2` from `vector_math`
  Vector2 toVector2() => Vector2(dx, dy);
}

/// Provides convenient methods for [Dimension].
extension DimensionExt on Dimension {
  /// Converts a `Dimension` from `rect_resizer` to a `Size`
  Size toSize() => Size(width, height);
}

/// Provides convenient methods for [Size].
extension SizeExt on Size {
  /// Converts a `Size` to a `Dimension` from `rect_resizer`
  Dimension toDimension() => Dimension(width, height);
}

/// Provides convenient methods for [widgets.BoxConstraints].
extension BoxConstraitnsExt on widgets.BoxConstraints {
  /// Converts a `BoxConstraints` from `flutter/rendering` to a `Constraints` from `rect_resizer`
  Constraints toConstraints() => Constraints(
        minWidth: minWidth,
        maxWidth: maxWidth,
        minHeight: minHeight,
        maxHeight: maxHeight,
      );
}

/// Provides convenient methods for [Constraints].
extension ConstraintsExt on Constraints {
  /// Converts a `Constraints` from `rect_resizer` to a `BoxConstraints` from `flutter/rendering`
  widgets.BoxConstraints toBoxConstraints() => widgets.BoxConstraints(
        minWidth: minWidth,
        maxWidth: maxWidth,
        minHeight: minHeight,
        maxHeight: maxHeight,
      );
}
