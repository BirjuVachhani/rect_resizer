import 'package:vector_math/vector_math.dart';

import 'enums.dart';
import 'geometry.dart';
import 'result.dart';

/// A class that transforms a [Box] in several different supported forms.
class BoxTransformer {
  /// A private constructor to prevent instantiation.
  const BoxTransformer._();

  /// Calculates the new position of the [initialBox] based on the
  /// [initialLocalPosition] of the mouse cursor and wherever [localPosition]
  /// of the mouse cursor is currently at.
  ///
  /// The [clampingRect] is the box that the [initialBox] is not allowed
  /// to go outside of when dragging or resizing.
  static RawMoveResult move({
    required Box initialBox,
    required Vector2 initialLocalPosition,
    required Vector2 localPosition,
    Box clampingRect = Box.largest,
  }) {
    final Vector2 delta = localPosition - initialLocalPosition;

    final Box unclampedBox = initialBox.translate(delta.x, delta.y);
    final Box clampedBox = clampingRect.containOther(unclampedBox);
    final Vector2 clampedDelta = clampedBox.topLeft - initialBox.topLeft;

    final Box newRect = initialBox.translate(clampedDelta.x, clampedDelta.y);

    return MoveResult(
      rect: newRect,
      oldRect: initialBox,
      delta: delta,
      rawSize: newRect.size,
    );
  }

  /// Resizes the given [initialBox] with given [initialLocalPosition] of
  /// the mouse cursor and wherever [localPosition] of the mouse cursor is
  /// currently at.
  ///
  /// Specifying the [handle] and [resizeMode] will determine how the
  /// [initialBox] will be resized.
  ///
  /// The [initialFlip] helps determine the initial state of the rectangle.
  ///
  /// The [clampingRect] is the box that the [initialBox] is not allowed
  /// to go outside of when dragging or resizing.
  ///
  /// The [constraints] is the constraints that the [initialBox] is not allowed
  /// to shrink or grow beyond.
  static RawResizeResult resize({
    required Box initialBox,
    required Vector2 initialLocalPosition,
    required Vector2 localPosition,
    required HandlePosition handle,
    required ResizeMode resizeMode,
    required Flip initialFlip,
    Box clampingRect = Box.largest,
    Constraints constraints = const Constraints.unconstrained(),
    bool flipRect = true,
  }) {
    Vector2 delta = localPosition - initialLocalPosition;

    // getFlipForBox uses delta instead of localPosition to know exactly when
    // to flip based on the current local position of the mouse cursor.
    final Flip currentFlip = !flipRect
        ? Flip.none
        : getFlipForBox(initialBox, delta, handle, resizeMode);

    // This sets the constraints such that it reflects flipRect state.
    if (flipRect && (constraints.minWidth == 0 || constraints.minHeight == 0)) {
      // Rect flipping is enabled, but minWidth or minHeight is 0 which
      // means it won't be able to flip. So we update the constraints
      // to allow flipping.
      constraints = Constraints(
        minWidth: constraints.minWidth == 0
            ? -constraints.maxWidth
            : constraints.minWidth,
        minHeight: constraints.minHeight == 0
            ? -constraints.maxHeight
            : constraints.minHeight,
        maxWidth: constraints.maxWidth,
        maxHeight: constraints.maxHeight,
      );
    } else if (!flipRect && constraints.isUnconstrained) {
      // Rect flipping is disabled, but the constraints are unconstrained.
      // So we update the constraints to prevent flipping.
      constraints = Constraints(
        minWidth: 0,
        minHeight: 0,
        maxWidth: constraints.maxWidth,
        maxHeight: constraints.maxHeight,
      );
    }

    if (resizeMode.hasSymmetry) delta = Vector2(delta.x * 2, delta.y * 2);

    final Dimension newSize = _calculateNewSize(
      initialBox: initialBox,
      handle: handle,
      delta: delta,
      flip: currentFlip,
      resizeMode: resizeMode,
      clampingRect: clampingRect,
      constraints: constraints,
    );
    final double newWidth = newSize.width.abs();
    final double newHeight = newSize.height.abs();

    Box newRect;
    if (resizeMode.hasSymmetry) {
      newRect = Box.fromCenter(
        center: initialBox.center,
        width: newWidth,
        height: newHeight,
      );
    } else {
      double left;
      double top;

      /// If the handle is a side handle and its a scalable resizing, then
      /// the resizing should be w.r.t. the opposite side of the handle.
      /// This is needs to be handled separately because the anchor point in
      /// this case is the center of the handle on the opposite side.
      if (resizeMode.isScalable && handle.isSide) {
        if (handle.isHorizontal) {
          left = handle.influencesLeft
              ? initialBox.right - newWidth
              : initialBox.left;
          top = initialBox.center.y - newHeight / 2;
        } else {
          top = handle.influencesTop
              ? initialBox.bottom - newHeight
              : initialBox.top;
          left = initialBox.center.x - newWidth / 2;
        }
      } else {
        left = handle.influencesLeft
            ? initialBox.right - newWidth
            : initialBox.left;
        top = handle.influencesTop
            ? initialBox.bottom - newHeight
            : initialBox.top;
      }
      Box rect = Box.fromLTWH(left, top, newWidth, newHeight);

      // Flip the rect only if flipRect is true.
      newRect = flipRect ? flipBox(rect, currentFlip, handle) : rect;
    }

    newRect = clampingRect.containOther(newRect);

    // Detect terminal resizing, where the resizing reached a hard limit.
    bool minWidthReached = false;
    bool maxWidthReached = false;
    bool minHeightReached = false;
    bool maxHeightReached = false;
    if (delta.x != 0) {
      if (newRect.width <= initialBox.width &&
          newRect.width == constraints.minWidth) {
        minWidthReached = true;
      }
      if (newRect.width >= initialBox.width &&
          (newRect.width == constraints.maxWidth ||
              newRect.width == clampingRect.width)) {
        maxWidthReached = true;
      }
    }
    if (delta.y != 0) {
      if (newRect.height <= initialBox.height &&
          newRect.height == constraints.minHeight) {
        minHeightReached = true;
      }
      if (newRect.height >= initialBox.height &&
              newRect.height == constraints.maxHeight ||
          newRect.height == clampingRect.height) {
        maxHeightReached = true;
      }
    }

    return ResizeResult(
      rect: newRect,
      oldRect: initialBox,
      flip: currentFlip * initialFlip,
      resizeMode: resizeMode,
      delta: delta,
      rawSize: newSize,
      minWidthReached: minWidthReached,
      maxWidthReached: maxWidthReached,
      minHeightReached: minHeightReached,
      maxHeightReached: maxHeightReached,
    );
  }

  /// Flips the given [rect] with given [flip] with [handle] being the
  /// pivot point.
  static Box flipBox(Box rect, Flip flip, HandlePosition handle) {
    switch (handle) {
      case HandlePosition.topLeft:
        return rect.translate(
          flip.isHorizontal ? rect.width : 0,
          flip.isVertical ? rect.height : 0,
        );
      case HandlePosition.topRight:
        return rect.translate(
          flip.isHorizontal ? -rect.width : 0,
          flip.isVertical ? rect.height : 0,
        );
      case HandlePosition.bottomLeft:
        return rect.translate(
          flip.isHorizontal ? rect.width : 0,
          flip.isVertical ? -rect.height : 0,
        );
      case HandlePosition.bottomRight:
        return rect.translate(
          flip.isHorizontal ? -rect.width : 0,
          flip.isVertical ? -rect.height : 0,
        );
      case HandlePosition.left:
        return rect.translate(
          flip.isHorizontal ? rect.width : 0,
          0,
        );
      case HandlePosition.top:
        return rect.translate(
          0,
          flip.isVertical ? rect.height : 0,
        );
      case HandlePosition.right:
        return rect.translate(
          flip.isHorizontal ? -rect.width : 0,
          0,
        );
      case HandlePosition.bottom:
        return rect.translate(
          0,
          flip.isVertical ? -rect.height : 0,
        );
    }
  }

  /// Calculates flip state of the given [rect] w.r.t [localPosition] and
  /// [handle]. It uses [handle] and [localPosition] to determine the quadrant
  /// of the [rect] and then checks if the [rect] is flipped in that quadrant.
  static Flip getFlipForBox(
    Box rect,
    Vector2 localPosition,
    HandlePosition handle,
    ResizeMode resizeMode,
  ) {
    final double widthFactor = resizeMode.hasSymmetry ? 0.5 : 1;
    final double heightFactor = resizeMode.hasSymmetry ? 0.5 : 1;

    final double effectiveWidth = rect.width * widthFactor;
    final double effectiveHeight = rect.height * heightFactor;

    final double handleXFactor = handle.influencesLeft ? -1 : 1;
    final double handleYFactor = handle.influencesTop ? -1 : 1;

    final double posX = effectiveWidth + localPosition.x * handleXFactor;
    final double posY = effectiveHeight + localPosition.y * handleYFactor;

    return Flip.fromValue(posX, posY);
  }

  static Dimension _calculateNewSize({
    required Box initialBox,
    required HandlePosition handle,
    required Vector2 delta,
    required Flip flip,
    required ResizeMode resizeMode,
    Box clampingRect = Box.largest,
    Constraints constraints = const Constraints.unconstrained(),
  }) {
    final double aspectRatio = initialBox.width / initialBox.height;

    initialBox = flipBox(initialBox, flip, handle);
    Box rect;

    /// If the handle is a side handle and its a scalable resizing, then
    /// the resizing should be w.r.t. the opposite side of the handle.
    /// This is needs to be handled separately because the anchor point in
    /// this case is the center of the handle on the opposite side.
    if (handle.isSide && resizeMode.isScalable) {
      double left;
      double top;
      double right;
      double bottom;

      if (handle.isHorizontal) {
        left =
            handle.influencesLeft ? initialBox.left + delta.x : initialBox.left;
        right = handle.influencesRight
            ? initialBox.right + delta.x
            : initialBox.right;
        final width = right - left;
        final height = width / aspectRatio;
        top = initialBox.centerLeft.y - height / 2;
        bottom = initialBox.centerLeft.y + height / 2;
      } else {
        top = handle.influencesTop ? initialBox.top + delta.y : initialBox.top;
        bottom = handle.influencesBottom
            ? initialBox.bottom + delta.y
            : initialBox.bottom;
        final height = bottom - top;
        final width = height * aspectRatio;
        left = initialBox.centerLeft.x - width / 2;
        right = initialBox.centerLeft.x + width / 2;
      }
      rect = Box.fromLTRB(left, top, right, bottom);
    } else {
      rect = Box.fromLTRB(
        initialBox.left + (handle.influencesLeft ? delta.x : 0),
        initialBox.top + (handle.influencesTop ? delta.y : 0),
        initialBox.right + (handle.influencesRight ? delta.x : 0),
        initialBox.bottom + (handle.influencesBottom ? delta.y : 0),
      );
    }
    if (resizeMode.hasSymmetry) {
      final widthDelta = (initialBox.width - rect.width) / 2;
      final heightDelta = (initialBox.height - rect.height) / 2;
      rect = Box.fromLTRB(
        initialBox.left + widthDelta,
        initialBox.top + heightDelta,
        initialBox.right - widthDelta,
        initialBox.bottom - heightDelta,
      );
    }

    rect = clampingRect.containOther(
      rect,
      resizeMode: resizeMode,
      aspectRatio: aspectRatio,
    );

    // When constraining this rect, it might have a negative width or height
    // because it has not been normalized yet. If the minimum width or height
    // is larger than zero, constraining will not work as expected because the
    // negative width or height will be ignored. To fix this, we take the
    // absolute value of the width and height before constraining and then
    // multiply the result with the sign of the width and height.
    final double wSign = rect.width.sign;
    final double hSign = rect.height.sign;
    rect = constraints.constrainBox(rect, absolute: true);
    rect = Box.fromLTWH(
      rect.left,
      rect.top,
      rect.width * wSign,
      rect.height * hSign,
    );

    final double newWidth;
    final double newHeight;
    final newAspectRatio = rect.width / rect.height;

    if (resizeMode.isScalable) {
      if (newAspectRatio.abs() < aspectRatio.abs()) {
        newHeight = rect.height;
        newWidth = newHeight * aspectRatio;
      } else {
        newWidth = rect.width;
        newHeight = newWidth / aspectRatio;
      }
    } else {
      newWidth = rect.width;
      newHeight = rect.height;
    }

    return Dimension(
      newWidth.abs() * (flip.isHorizontal ? -1 : 1),
      newHeight.abs() * (flip.isVertical ? -1 : 1),
    );
  }
}
