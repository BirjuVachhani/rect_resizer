part of 'resizer.dart';

/// Handles resizing for [ResizeMode.scale].
final class ScaleResizer extends Resizer {
  /// A default constructor for [ScaleResizer].
  const ScaleResizer();

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
    ({Box rect, Box largest, bool hasValidFlip}) result = _resizeRect(
      initialRect: initialRect,
      explodedRect: explodedRect,
      clampingRect: clampingRect,
      handle: handle,
      constraints: constraints,
      flip: flip,
    );

    if (!result.hasValidFlip) {
      // Since we can't flip the box, explodedRect (which is a raw rect with delta applied)
      // would be flipped so we can't use that because it would make the size
      // calculations wrong. Instead we use box from the result which is the
      // flipped box but with correct constraints applied. (min rect always).
      final newResult = _resizeRect(
        explodedRect: result.rect,
        initialRect: initialRect,
        clampingRect: clampingRect,
        handle: handle,
        flip: Flip.none,
        constraints: constraints,
      );

      if (!newResult.hasValidFlip) {
        // This should never happen. If it does, it means that the box is
        // invalid even after flipping it back to the original state and we
        // can't flip it back again. This means that the box might be invalid
        // in the first place or something catastrophic happened!!! Contact
        // the package author if this happens.
        return (
          rect: initialRect,
          largest: result.largest,
          hasValidFlip: false
        );
      }

      return newResult;
    }

    return result;
  }

  ({Box rect, Box largest, bool hasValidFlip}) _resizeRect({
    required Box initialRect,
    required Box explodedRect,
    required Box clampingRect,
    required HandlePosition handle,
    required Constraints constraints,
    required Flip flip,
  }) {
    final flippedHandle = handle.flip(flip);
    final effectiveInitialRect = flipRect(initialRect, flip, handle);

    ({Box rect, Box largest, bool hasValidFlip}) result;

    switch (flippedHandle) {
      case HandlePosition.none:
        throw ArgumentError('HandlePosition.none is not supported!');
      case HandlePosition.topLeft:
        result = handleTopLeft(explodedRect, effectiveInitialRect, clampingRect,
            flippedHandle, constraints, flip);
        break;
      case HandlePosition.topRight:
        result = handleTopRight(explodedRect, effectiveInitialRect,
            clampingRect, flippedHandle, constraints, flip);
        break;
      case HandlePosition.bottomLeft:
        result = handleBottomLeft(explodedRect, effectiveInitialRect,
            clampingRect, flippedHandle, constraints, flip);
        break;
      case HandlePosition.bottomRight:
        result = handleBottomRight(explodedRect, effectiveInitialRect,
            clampingRect, flippedHandle, constraints, flip);
        break;
      case HandlePosition.left:
        result = handleLeft(explodedRect, effectiveInitialRect, clampingRect,
            flippedHandle, constraints, flip);
        break;
      case HandlePosition.top:
        result = handleTop(explodedRect, effectiveInitialRect, clampingRect,
            flippedHandle, constraints, flip);
        break;
      case HandlePosition.right:
        result = handleRight(explodedRect, effectiveInitialRect, clampingRect,
            flippedHandle, constraints, flip);
        break;
      case HandlePosition.bottom:
        result = handleBottom(explodedRect, effectiveInitialRect, clampingRect,
            flippedHandle, constraints, flip);
        break;
    }

    return result;
  }

  /// Handle resizing for [HandlePosition.bottomRight] handle
  /// for [ResizeMode.scale].
  ({Box rect, Box largest, bool hasValidFlip}) handleBottomRight(
    Box rect,
    Box initialRect,
    Box clampingRect,
    HandlePosition handle,
    Constraints constraints,
    Flip flip,
  ) {
    Box area = getAvailableAreaForHandle(
      rect: initialRect,
      clampingRect: clampingRect,
      handle: handle,
      constraints: constraints,
    );

    area = constrainAvailableAreaForScaling(
      area: area,
      initialRect: initialRect,
      handle: handle,
      constraints: constraints,
    );

    final initialAspectRatio = initialRect.safeAspectRatio;

    double rectWidth = rect.width;
    double rectHeight = rect.height;

    final cursorRect = rect;

    if (cursorRect.safeAspectRatio.abs() < initialAspectRatio.abs()) {
      rectWidth = rectHeight * initialAspectRatio;
    } else {
      rectHeight = rectWidth / initialAspectRatio;
    }

    final maxRect = getClampingRectForHandle(
      initialRect: initialRect,
      availableArea: area,
      handle: handle,
    );

    final minRect = getMinRectForScaling(
      initialRect: initialRect,
      handle: handle,
      constraints: constraints,
    );

    rect = Box.fromHandle(
      handle.anchor(initialRect),
      handle,
      rectWidth,
      rectHeight,
    );

    Box largest = maxRect;
    if (rect.width > maxRect.width || rect.height > maxRect.height) {
      rect = maxRect;
      largest = maxRect;
    } else if (rect.width < minRect.width || rect.height < minRect.height) {
      rect = minRect;
      largest = maxRect;
    }

    final isValid = isRectBound(rect, constraints, clampingRect);

    return (rect: rect, largest: largest, hasValidFlip: isValid);
  }

  /// Handle resizing for the right handle.
  ({Box rect, Box largest, bool hasValidFlip}) handleRight(
    Box rect,
    Box initialRect,
    Box clampingRect,
    HandlePosition handle,
    Constraints constraints,
    Flip flip,
  ) {
    final initialAspectRatio = initialRect.safeAspectRatio;

    Box area = getAvailableAreaForHandle(
      rect: initialRect,
      clampingRect: clampingRect,
      handle: handle,
      constraints: constraints,
    );

    area = constrainAvailableAreaForScaling(
      area: area,
      initialRect: initialRect,
      handle: handle,
      constraints: constraints,
    );

    if (area.width < initialRect.width) {
      // initial box needs shrinking
      final maxWidth = area.width;
      final maxHeight = maxWidth / initialAspectRatio;

      initialRect = Box.fromHandle(
        handle.anchor(initialRect),
        handle,
        maxWidth,
        maxHeight,
      );
    }

    final maxRect = getClampingRectForHandle(
      initialRect: initialRect,
      availableArea: area,
      handle: handle,
    );

    final minRect = getMinRectForScaling(
      initialRect: initialRect,
      handle: handle,
      constraints: constraints,
    );

    double rectWidth = rect.width;
    double rectHeight = rect.height;

    rectHeight = rectWidth / initialAspectRatio;

    rect = Box.fromHandle(
      handle.anchor(initialRect),
      handle,
      rectWidth,
      rectHeight,
    );

    Box largest = maxRect;
    if (rect.width > maxRect.width || rect.height > maxRect.height) {
      rect = maxRect;
      largest = maxRect;
    } else if (rect.width < minRect.width || rect.height < minRect.height) {
      rect = minRect;
      largest = maxRect;
    }

    final isValid = isRectBound(rect, constraints, clampingRect);

    return (rect: rect, largest: largest, hasValidFlip: isValid);
  }

  /// handle resizing for the left handle
  ({Box rect, Box largest, bool hasValidFlip}) handleLeft(
    Box rect,
    Box initialRect,
    Box clampingRect,
    HandlePosition handle,
    Constraints constraints,
    Flip flip,
  ) {
    final initialAspectRatio = initialRect.safeAspectRatio;

    Box area = getAvailableAreaForHandle(
      rect: initialRect,
      clampingRect: clampingRect,
      handle: handle,
      constraints: constraints,
    );

    area = constrainAvailableAreaForScaling(
      area: area,
      initialRect: initialRect,
      handle: handle,
      constraints: constraints,
    );

    if (area.width < initialRect.width) {
      // initial box needs shrinking
      final maxWidth = area.width;
      final maxHeight = maxWidth / initialAspectRatio;

      initialRect = Box.fromHandle(
        handle.anchor(initialRect),
        handle,
        maxWidth,
        maxHeight,
      );
    }

    final maxRect = getClampingRectForHandle(
      initialRect: initialRect,
      availableArea: area,
      handle: handle,
    );

    final minRect = getMinRectForScaling(
      initialRect: initialRect,
      handle: handle,
      constraints: constraints,
    );

    double rectWidth = rect.width;
    double rectHeight = rect.height;

    rectHeight = rectWidth / initialAspectRatio;

    rect = Box.fromHandle(
      handle.anchor(initialRect),
      handle,
      rectWidth,
      rectHeight,
    );

    Box largest = maxRect;
    if (rect.width > maxRect.width || rect.height > maxRect.height) {
      rect = maxRect;
      largest = maxRect;
    } else if (rect.width < minRect.width || rect.height < minRect.height) {
      rect = minRect;
      largest = maxRect;
    }

    final isValid = isRectBound(rect, constraints, clampingRect);

    return (rect: rect, largest: largest, hasValidFlip: isValid);
  }

  /// handle resizing for the bottom handle.
  ({Box rect, Box largest, bool hasValidFlip}) handleBottom(
    Box rect,
    Box initialRect,
    Box clampingRect,
    HandlePosition handle,
    Constraints constraints,
    Flip flip,
  ) {
    final initialAspectRatio = initialRect.safeAspectRatio;

    Box area = getAvailableAreaForHandle(
      rect: initialRect,
      clampingRect: clampingRect,
      handle: handle,
      constraints: constraints,
    );

    area = constrainAvailableAreaForScaling(
      area: area,
      initialRect: initialRect,
      handle: handle,
      constraints: constraints,
    );

    if (area.height < initialRect.height) {
      // initial box needs shrinking
      final maxHeight = area.height;
      final maxWidth = maxHeight * initialAspectRatio;

      initialRect = Box.fromHandle(
        handle.anchor(initialRect),
        handle,
        maxWidth,
        maxHeight,
      );
    }

    final maxRect = getClampingRectForHandle(
      initialRect: initialRect,
      availableArea: area,
      handle: handle,
    );

    final minRect = getMinRectForScaling(
      initialRect: initialRect,
      handle: handle,
      constraints: constraints,
    );

    double rectWidth = rect.width;
    double rectHeight = rect.height;

    rectWidth = rectHeight * initialAspectRatio;

    rect = Box.fromHandle(
      handle.anchor(initialRect),
      handle,
      rectWidth,
      rectHeight,
    );

    Box largest = maxRect;
    if (rect.width > maxRect.width || rect.height > maxRect.height) {
      rect = maxRect;
      largest = maxRect;
    } else if (rect.width < minRect.width || rect.height < minRect.height) {
      rect = minRect;
      largest = maxRect;
    }

    final isValid = isRectBound(rect, constraints, clampingRect);

    return (rect: rect, largest: largest, hasValidFlip: isValid);
  }

  /// handle resizing for the top handle.
  ({Box rect, Box largest, bool hasValidFlip}) handleTop(
    Box rect,
    Box initialRect,
    Box clampingRect,
    HandlePosition handle,
    Constraints constraints,
    Flip flip,
  ) {
    final initialAspectRatio = initialRect.safeAspectRatio;

    Box area = getAvailableAreaForHandle(
      rect: initialRect,
      clampingRect: clampingRect,
      handle: handle,
      constraints: constraints,
    );

    area = constrainAvailableAreaForScaling(
      area: area,
      initialRect: initialRect,
      handle: handle,
      constraints: constraints,
    );

    if (area.height < initialRect.height) {
      // initial box needs shrinking
      final maxHeight = area.height;
      final maxWidth = maxHeight * initialAspectRatio;

      initialRect = Box.fromHandle(
        handle.anchor(initialRect),
        handle,
        maxWidth,
        maxHeight,
      );
    }

    final maxRect = getClampingRectForHandle(
      initialRect: initialRect,
      availableArea: area,
      handle: handle,
    );

    final minRect = getMinRectForScaling(
      initialRect: initialRect,
      handle: handle,
      constraints: constraints,
    );

    double rectWidth = rect.width;
    double rectHeight = rect.height;

    rectWidth = rectHeight * initialAspectRatio;

    rect = Box.fromHandle(
      handle.anchor(initialRect),
      handle,
      rectWidth,
      rectHeight,
    );

    Box largest = maxRect;
    if (rect.width > maxRect.width || rect.height > maxRect.height) {
      rect = maxRect;
      largest = maxRect;
    } else if (rect.width < minRect.width || rect.height < minRect.height) {
      rect = minRect;
      largest = maxRect;
    }

    final isValid = isRectBound(rect, constraints, clampingRect);

    return (rect: rect, largest: largest, hasValidFlip: isValid);
  }

  /// Handle resizing for [HandlePosition.topLeft] handle
  /// for [ResizeMode.scale].
  ({Box rect, Box largest, bool hasValidFlip}) handleTopLeft(
    Box rect,
    Box initialRect,
    Box clampingRect,
    HandlePosition handle,
    Constraints constraints,
    Flip flip,
  ) {
    Box area = getAvailableAreaForHandle(
      rect: initialRect,
      clampingRect: clampingRect,
      handle: handle,
      constraints: constraints,
    );

    area = constrainAvailableAreaForScaling(
      area: area,
      initialRect: initialRect,
      handle: handle,
      constraints: constraints,
    );

    final initialAspectRatio = initialRect.safeAspectRatio;

    double rectWidth = rect.width;
    double rectHeight = rect.height;

    final cursorRect = rect;

    if (cursorRect.safeAspectRatio.abs() < initialAspectRatio.abs()) {
      rectWidth = rectHeight * initialAspectRatio;
    } else {
      rectHeight = rectWidth / initialAspectRatio;
    }

    final maxRect = getClampingRectForHandle(
      initialRect: initialRect,
      availableArea: area,
      handle: handle,
    );

    final minRect = getMinRectForScaling(
      initialRect: initialRect,
      handle: handle,
      constraints: constraints,
    );

    rect = Box.fromHandle(
      handle.anchor(initialRect),
      handle,
      rectWidth,
      rectHeight,
    );

    Box largest = maxRect;
    if (rect.width > maxRect.width || rect.height > maxRect.height) {
      rect = maxRect;
      largest = maxRect;
    } else if (rect.width < minRect.width || rect.height < minRect.height) {
      rect = minRect;
      largest = maxRect;
    }

    final isValid = isRectBound(rect, constraints, clampingRect);

    return (rect: rect, largest: largest, hasValidFlip: isValid);
  }

  /// Handle resizing for [HandlePosition.bottomLeft] handle
  /// for [ResizeMode.scale].
  ({Box rect, Box largest, bool hasValidFlip}) handleBottomLeft(
    Box rect,
    Box initialRect,
    Box clampingRect,
    HandlePosition handle,
    Constraints constraints,
    Flip flip,
  ) {
    Box area = getAvailableAreaForHandle(
      rect: initialRect,
      clampingRect: clampingRect,
      handle: handle,
      constraints: constraints,
    );

    area = constrainAvailableAreaForScaling(
      area: area,
      initialRect: initialRect,
      handle: handle,
      constraints: constraints,
    );

    final initialAspectRatio = initialRect.safeAspectRatio;

    double rectWidth = rect.width;
    double rectHeight = rect.height;

    final cursorRect = rect;

    if (cursorRect.safeAspectRatio.abs() < initialAspectRatio.abs()) {
      rectWidth = rectHeight * initialAspectRatio;
    } else {
      rectHeight = rectWidth / initialAspectRatio;
    }

    final maxRect = getClampingRectForHandle(
      initialRect: initialRect,
      availableArea: area,
      handle: handle,
    );

    final minRect = getMinRectForScaling(
      initialRect: initialRect,
      handle: handle,
      constraints: constraints,
    );

    rect = Box.fromHandle(
      handle.anchor(initialRect),
      handle,
      rectWidth,
      rectHeight,
    );

    Box largest = maxRect;
    if (rect.width > maxRect.width || rect.height > maxRect.height) {
      rect = maxRect;
      largest = maxRect;
    } else if (rect.width < minRect.width || rect.height < minRect.height) {
      rect = minRect;
      largest = maxRect;
    }

    final isValid = isRectBound(rect, constraints, clampingRect);

    return (rect: rect, largest: largest, hasValidFlip: isValid);
  }

  /// Handle resizing for [HandlePosition.topRight] handle
  /// for [ResizeMode.scale].
  ({Box rect, Box largest, bool hasValidFlip}) handleTopRight(
    Box rect,
    Box initialRect,
    Box clampingRect,
    HandlePosition handle,
    Constraints constraints,
    Flip flip,
  ) {
    Box area = getAvailableAreaForHandle(
      rect: initialRect,
      clampingRect: clampingRect,
      handle: handle,
      constraints: constraints,
    );

    area = constrainAvailableAreaForScaling(
      area: area,
      initialRect: initialRect,
      handle: handle,
      constraints: constraints,
    );

    final initialAspectRatio = initialRect.safeAspectRatio;

    double rectWidth = rect.width;
    double rectHeight = rect.height;

    final cursorRect = rect;

    if (cursorRect.safeAspectRatio.abs() < initialAspectRatio.abs()) {
      rectWidth = rectHeight * initialAspectRatio;
    } else {
      rectHeight = rectWidth / initialAspectRatio;
    }

    final maxRect = getClampingRectForHandle(
      initialRect: initialRect,
      availableArea: area,
      handle: handle,
    );

    final minRect = getMinRectForScaling(
      initialRect: initialRect,
      handle: handle,
      constraints: constraints,
    );

    rect = Box.fromHandle(
      handle.anchor(initialRect),
      handle,
      rectWidth,
      rectHeight,
    );

    Box largest = maxRect;
    if (rect.width > maxRect.width || rect.height > maxRect.height) {
      rect = maxRect;
      largest = maxRect;
    } else if (rect.width < minRect.width || rect.height < minRect.height) {
      rect = minRect;
      largest = maxRect;
    }

    final isValid = isRectBound(rect, constraints, clampingRect);

    return (rect: rect, largest: largest, hasValidFlip: isValid);
  }
}
