part of 'resizer.dart';

/// Handles resizing for [ResizeMode.symmetricScale].
final class SymmetricScaleResizer extends Resizer {
  /// A default constructor for [SymmetricScaleResizer].
  const SymmetricScaleResizer();

  @override
  ({Box rect, Box largest, bool hasValidFlip}) resize({
    required Box initialRect,
    required Box explodedRect,
    required Box clampingRect,
    required HandlePosition handle,
    required Constraints constraints,
    required Flip flip,
    required double rotation,
    required BindingStrategy bindingStrategy,
  }) {
    switch (handle) {
      case HandlePosition.none:
        throw ArgumentError('HandlePosition.none is not supported!');
      case HandlePosition.topLeft:
      case HandlePosition.topRight:
      case HandlePosition.bottomLeft:
      case HandlePosition.bottomRight:
        return handleScaleSymmetricCorner(
          explodedRect,
          initialRect,
          clampingRect,
          handle.isNone ? HandlePosition.bottomRight : handle,
          constraints,
        );
      case HandlePosition.left:
      case HandlePosition.top:
      case HandlePosition.right:
      case HandlePosition.bottom:
        return handleScaleSymmetricSide(
          explodedRect,
          initialRect,
          clampingRect,
          handle,
          constraints,
        );
    }
  }

  /// Handles the symmetric resize mode for corner handles.
  ({Box rect, Box largest, bool hasValidFlip}) handleScaleSymmetricCorner(
    Box rect,
    Box initialRect,
    Box clampingRect,
    HandlePosition handle,
    Constraints constraints,
  ) {
    final initialAspectRatio = initialRect.safeAspectRatio;

    final Box availableArea;

    if (!constraints.isUnconstrained) {
      final constrainedBox = Box.fromCenter(
        center: initialRect.center,
        width: constraints.maxWidth,
        height: constraints.maxHeight,
      );
      availableArea = Box.fromLTRB(
        max(constrainedBox.left, clampingRect.left),
        max(constrainedBox.top, clampingRect.top),
        min(constrainedBox.right, clampingRect.right),
        min(constrainedBox.bottom, clampingRect.bottom),
      );
    } else {
      availableArea = clampingRect;
    }

    final maxRect = scaledSymmetricClampingRect(initialRect, availableArea);

    final Box minRect;
    if (!constraints.isUnconstrained) {
      final double minWidth;
      final double minHeight;
      if (initialRect.safeAspectRatio > 1) {
        minHeight = constraints.minHeight;
        minWidth = minHeight * initialAspectRatio;
      } else {
        minWidth = constraints.minWidth;
        minHeight = minWidth / initialAspectRatio;
      }
      minRect = Box.fromCenter(
        center: initialRect.center,
        width: minWidth,
        height: minHeight,
      );
    } else {
      minRect = Box.fromCenter(
        center: initialRect.center,
        width: 0,
        height: 0,
      );
    }

    double rectWidth = rect.width;
    double rectHeight = rect.height;

    final cursorRect = rect;

    if (cursorRect.safeAspectRatio.abs() < initialAspectRatio.abs()) {
      rectWidth = rectHeight * initialAspectRatio;
    } else {
      rectHeight = rectWidth / initialAspectRatio;
    }

    rect = Box.fromCenter(
      center: initialRect.center,
      width: rectWidth,
      height: rectHeight,
    );

    if (rect.width > maxRect.width || rect.height > maxRect.height) {
      rect = maxRect;
      return (rect: maxRect, largest: maxRect, hasValidFlip: true);
    } else if (rect.width < minRect.width || rect.height < minRect.height) {
      return (rect: minRect, largest: maxRect, hasValidFlip: true);
    }

    return (rect: rect, largest: maxRect, hasValidFlip: true);
  }

  /// Handles the symmetric resize mode for side handles.
  ({Box rect, Box largest, bool hasValidFlip}) handleScaleSymmetricSide(
    Box rect,
    Box initialRect,
    Box clampingRect,
    HandlePosition handle,
    Constraints constraints,
  ) {
    final initialAspectRatio = initialRect.safeAspectRatio;

    final Box availableArea;

    if (!constraints.isUnconstrained) {
      final constrainedBox = Box.fromCenter(
        center: initialRect.center,
        width: constraints.maxWidth,
        height: constraints.maxHeight,
      );
      availableArea = Box.fromLTRB(
        max(constrainedBox.left, clampingRect.left),
        max(constrainedBox.top, clampingRect.top),
        min(constrainedBox.right, clampingRect.right),
        min(constrainedBox.bottom, clampingRect.bottom),
      );
    } else {
      availableArea = clampingRect;
    }

    final maxRect = scaledSymmetricClampingRect(initialRect, availableArea);

    final Box minRect;
    if (!constraints.isUnconstrained) {
      final double minWidth;
      final double minHeight;
      if (initialRect.safeAspectRatio > 1) {
        minHeight = constraints.minHeight;
        minWidth = minHeight * initialAspectRatio;
      } else {
        minWidth = constraints.minWidth;
        minHeight = minWidth / initialAspectRatio;
      }
      minRect = Box.fromCenter(
        center: initialRect.center,
        width: minWidth,
        height: minHeight,
      );
    } else {
      minRect = Box.fromCenter(
        center: initialRect.center,
        width: 0,
        height: 0,
      );
    }

    double rectWidth = rect.width.abs();
    double rectHeight = rect.height.abs();

    if (handle.isHorizontal) {
      rectHeight = rectWidth / initialAspectRatio;
    } else {
      rectWidth = rectHeight * initialAspectRatio;
    }

    rect = Box.fromCenter(
      center: initialRect.center,
      width: rectWidth,
      height: rectHeight,
    );

    if (rect.width > maxRect.width || rect.height > maxRect.height) {
      rect = maxRect;
      return (rect: maxRect, largest: maxRect, hasValidFlip: true);
    } else if (rect.width < minRect.width || rect.height < minRect.height) {
      return (rect: minRect, largest: maxRect, hasValidFlip: true);
    }

    return (rect: rect, largest: maxRect, hasValidFlip: true);
  }
}
