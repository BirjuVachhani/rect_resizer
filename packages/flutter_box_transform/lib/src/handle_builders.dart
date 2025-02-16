import 'dart:ui';

import 'package:box_transform/box_transform.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'typedefs.dart';

/// Creates a new corner handle widget, with its appropriate gesture splash
/// zone.
@protected
class CornerHandleWidget extends StatelessWidget {
  /// The position of the handle.
  final HandlePosition handlePosition;

  /// The builder that is used to build the handle widget.
  final HandleBuilder builder;

  /// The size of the resize handle's gesture response area.
  final double resizeHandleGestureSize;

  /// The size of the rotation handle's gesture response area.
  final double rotationHandleGestureSize;

  /// The kind of devices that are allowed to be recognized.
  final Set<PointerDeviceKind> supportedDevices;

  /// Called when the handle dragging starts.
  final GestureDragStartCallback? onPanStart;

  /// Called when the handle dragging is updated.
  final GestureDragUpdateCallback? onPanUpdate;

  /// Called when the handle dragging ends.
  final GestureDragEndCallback? onPanEnd;

  /// Called when the handle dragging is canceled.
  final GestureDragCancelCallback? onPanCancel;

  /// Called when the handle rotates the box.
  final GestureRotationStartCallback? onRotationStart;

  /// Called when the handle rotates the box.
  final GestureRotationUpdateCallback? onRotationUpdate;

  /// Called when the handle rotates the box.
  final GestureRotationEndCallback? onRotationEnd;

  /// Called when the handle rotates the box.
  final GestureRotationCancelCallback? onRotationCancel;

  /// Whether the handle is resizable.
  final bool enabled;

  /// Whether the handle is visible.
  final bool visible;

  /// Whether the handle supports rotation.
  final bool rotatable;

  /// Whether to paint the handle's bounds for debugging purposes.
  final bool debugPaintHandleBounds;

  /// Creates a new handle widget.
  CornerHandleWidget({
    super.key,
    required this.handlePosition,
    required this.resizeHandleGestureSize,
    required this.rotationHandleGestureSize,
    required this.supportedDevices,
    required this.builder,

    // Resize
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
    this.onPanCancel,

    // Rotate
    this.onRotationStart,
    this.onRotationUpdate,
    this.onRotationEnd,
    this.onRotationCancel,

    // Config
    this.enabled = true,
    this.visible = true,
    this.rotatable = true,
    this.debugPaintHandleBounds = false,
  }) : assert(handlePosition.isDiagonal, 'A corner handle must be diagonal.');

  @override
  Widget build(BuildContext context) {
    Widget child =
        visible ? builder(context, handlePosition) : const SizedBox.shrink();

    if (enabled) {
      final double gestureGap =
          (rotationHandleGestureSize - resizeHandleGestureSize) / 2;
      child = GestureDetector(
        behavior: HitTestBehavior.opaque,
        supportedDevices: supportedDevices,
        onPanStart: onPanStart,
        onPanUpdate: onPanUpdate,
        onPanEnd: onPanEnd,
        onPanCancel: onPanCancel,
        child: MouseRegion(
          cursor: getResizeCursorForHandle(handlePosition),
          child: Padding(
            padding: rotatable
                ? getRotationCornerPadding(
                    handlePosition.opposite,
                    gestureGap,
                  )
                : EdgeInsets.zero,
            child: child,
          ),
        ),
      );

      if (rotatable) {
        if (kDebugMode && debugPaintHandleBounds) {
          child = ColoredBox(
              color: Colors.blue.withOpacity(0.5),
              child: child,
          );
        }
        child = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: onRotationStart,
          onPanUpdate: onRotationUpdate,
          onPanEnd: onRotationEnd,
          onPanCancel: onRotationCancel,
          child: MouseRegion(
            cursor: getRotationCursorForHandle(handlePosition),
            child: Padding(
              padding: getRotationCornerPadding(handlePosition, gestureGap),
              child: child,
            ),
          ),
        );
      }
    }

    if (kDebugMode && debugPaintHandleBounds) {
      child = ColoredBox(
        color: Colors.orange.withValues(alpha: 0.5),
        child: child,
      );
    }

    return Positioned(
      left: handlePosition.influencesLeft ? 0 : null,
      right: handlePosition.influencesRight ? 0 : null,
      top: handlePosition.influencesTop ? 0 : null,
      bottom: handlePosition.influencesBottom ? 0 : null,
      width: rotatable ? rotationHandleGestureSize : resizeHandleGestureSize,
      height: rotatable ? rotationHandleGestureSize : resizeHandleGestureSize,
      child: child,
    );
  }

  /// Returns the padding for the rotation gesture area.
  EdgeInsets getRotationCornerPadding(
      HandlePosition handlePosition, double value) {
    return switch (handlePosition) {
      HandlePosition.topLeft => EdgeInsets.only(left: value, top: value),
      HandlePosition.topRight => EdgeInsets.only(right: value, top: value),
      HandlePosition.bottomLeft => EdgeInsets.only(left: value, bottom: value),
      HandlePosition.bottomRight =>
        EdgeInsets.only(right: value, bottom: value),
      _ => throw Exception('Invalid handle position. Corners only.'),
    };
  }

  /// Returns the resize cursor for the given handle position.
  MouseCursor getResizeCursorForHandle(HandlePosition handle) {
    switch (handle) {
      case HandlePosition.topLeft:
      case HandlePosition.bottomRight:
        return SystemMouseCursors.resizeUpLeftDownRight;
      case HandlePosition.topRight:
      case HandlePosition.bottomLeft:
        return SystemMouseCursors.resizeUpRightDownLeft;
      default:
        throw Exception('Invalid handle position.');
    }
  }

  /// Returns the rotation cursor for the given handle position.
  /// TODO: No rotation cursor in Flutter.
  MouseCursor getRotationCursorForHandle(HandlePosition handle) {
    switch (handle) {
      case HandlePosition.topLeft:
      case HandlePosition.bottomRight:
        return SystemMouseCursors.resizeUpLeftDownRight;
      case HandlePosition.topRight:
      case HandlePosition.bottomLeft:
        return SystemMouseCursors.resizeUpRightDownLeft;
      default:
        throw Exception('Invalid handle position.');
    }
  }
}

/// Creates a new cardinal handle widget, with its appropriate gesture splash
/// zone.
@protected
class SideHandleWidget extends StatelessWidget {
  /// The position of the handle.
  final HandlePosition handlePosition;

  /// The builder that is used to build the handle widget.
  final HandleBuilder builder;

  /// The thickness of the handle that is used for gesture detection.
  final double resizeHandleGestureSize;

  /// The size of the rotation handle's gesture response area.
  final double rotationHandleGestureSize;

  /// The kind of devices that are allowed to be recognized.
  final Set<PointerDeviceKind> supportedDevices;

  /// Called when the handle dragging starts.
  final GestureDragStartCallback? onPanStart;

  /// Called when the handle dragging is updated.
  final GestureDragUpdateCallback? onPanUpdate;

  /// Called when the handle dragging ends.
  final GestureDragEndCallback? onPanEnd;

  /// Called when the handle dragging is canceled.
  final GestureDragCancelCallback? onPanCancel;

  /// Whether the handle is rotatable.
  final bool rotatable;

  /// Whether the handle is resizable.
  final bool enabled;

  /// Whether the handle is visible.
  final bool visible;

  /// Whether to paint the handle's bounds for debugging purposes.
  final bool debugPaintHandleBounds;

  /// Creates a new handle widget.
  SideHandleWidget({
    super.key,
    required this.handlePosition,
    required this.resizeHandleGestureSize,
    required this.rotationHandleGestureSize,
    required this.supportedDevices,
    required this.builder,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
    this.onPanCancel,
    this.rotatable = true,
    this.enabled = true,
    this.visible = true,
    this.debugPaintHandleBounds = false,
  }) : assert(handlePosition.isSide, 'A cardinal handle must be cardinal.');

  @override
  Widget build(BuildContext context) {
    Widget child =
        visible ? builder(context, handlePosition) : const SizedBox.shrink();

    if (enabled) {
      child = GestureDetector(
        behavior: HitTestBehavior.opaque,
        supportedDevices: supportedDevices,
        onPanStart: onPanStart,
        onPanUpdate: onPanUpdate,
        onPanEnd: onPanEnd,
        onPanCancel: onPanCancel,
        child: MouseRegion(
          cursor: getCursorForHandle(handlePosition),
          child: child,
        ),
      );
    }

    if (kDebugMode && debugPaintHandleBounds) {
      child = ColoredBox(
        color: Colors.yellow.withValues(alpha: 0.5),
        child: child,
      );
    }

    final double gestureSize =
        rotatable ? rotationHandleGestureSize : resizeHandleGestureSize;
    final double gestureOffset =
        gestureSize / 2 - (resizeHandleGestureSize / 2);

    return Positioned(
      left: handlePosition.isVertical
          ? gestureSize
          : handlePosition.influencesLeft
              ? gestureOffset
              : null,
      right: handlePosition.isVertical
          ? gestureSize
          : handlePosition.influencesRight
              ? gestureOffset
              : null,
      top: handlePosition.isHorizontal
          ? gestureSize
          : handlePosition.influencesTop
              ? gestureOffset
              : null,
      bottom: handlePosition.isHorizontal
          ? gestureSize
          : handlePosition.influencesBottom
              ? gestureOffset
              : null,
      width: handlePosition.isHorizontal ? resizeHandleGestureSize : null,
      height: handlePosition.isVertical ? resizeHandleGestureSize : null,
      child: child,
    );
  }

  /// Returns the cursor for the given handle position.
  MouseCursor getCursorForHandle(HandlePosition handle) {
    switch (handle) {
      case HandlePosition.left:
      case HandlePosition.right:
        return SystemMouseCursors.resizeLeftRight;
      case HandlePosition.top:
      case HandlePosition.bottom:
        return SystemMouseCursors.resizeUpDown;
      default:
        throw Exception('Invalid handle position.');
    }
  }
}
