part of 'resizer.dart';

/// Handles freeform resizing with support for rotation.
///
/// In addition to the freeform resizing logic from the non‐rotated version,
/// this implementation attempts to reposition and constrain a rotated
/// rectangle. The new rectangle is computed based on the user’s drag (the
/// [explodedRect]), the allowed clamping area ([clampingRect]), size
/// constraints, and rotation. It also applies a binding strategy which affects
/// how the available area is computed for the resizing handle.
///
/// **NOTE:** Several parts of this implementation are problematic compared to
/// the non-rotated version which is flawless and passes all tests. The issues
/// are marked inline with `// [ISSUE]`.
final class FreeformResizer extends Resizer {
  /// Creates a constant instance of [FreeformResizer].
  const FreeformResizer();

  /// Resizes the rectangle based on user interaction, constraints, and
  /// rotation.
  ///
  /// Parameters:
  /// - [initialRect]: The original rectangle before resizing begins.
  /// - [explodedRect]: The rectangle produced by applying the user’s drag. It
  ///   might temporarily exceed constraints.
  /// - [clampingRect]: The bounding rectangle within which the resized
  ///   rectangle must remain.
  /// - [handle]: The resizing handle (e.g., a corner or side) that anchors the
  ///   resize operation.
  /// - [constraints]: Minimum and maximum size constraints for the rectangle.
  /// - [flip]: Determines whether the rectangle’s coordinates should be
  ///   flipped.
  /// - [rotation]: The rotation angle (in radians) applied to the rectangle.
  /// - [bindingStrategy]: A strategy indicating whether to bind to the original
  ///   box or its bounding rectangle when computing available area.
  ///
  /// Returns a record containing:
  /// - [rect]: The newly computed rectangle after applying repositioning,
  ///   constraints, and rotation.
  /// - [largest]: The largest available area for the handle, useful for UI hints.
  /// - [hasValidFlip]: A boolean indicating whether the computed rectangle meets
  ///   the constraints (used here as a proxy for valid flipping and binding).
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
    final HandlePosition flippedHandle = handle.flip(flip);

    final Box effectiveInitialRect = flipRect(initialRect, flip, handle);
    final Box initialBoundingRect = BoxTransformer.calculateBoundingRect(
      rotation: rotation,
      unrotatedBox: effectiveInitialRect,
    );
    final Box effectiveInitialBoundingRect =
        flipRect(initialBoundingRect, flip, handle);

    Box newRect = explodedRect;

    // When resizing with rotation, the box must be repositioned immediately
    // after resizing to ensure the opposite handle is anchored properly.
    // The reason this is needed is because when resizing with rotation,
    // the resize happens around the center of the rect, which mobilizes all
    // handles. This corrects that behavior by repositioning the rect.
    newRect = repositionRotatedResizedBox(
      newRect: newRect,
      initialRect: initialRect,
      rotation: rotation,
    );
    Box newBoundingRect = BoxTransformer.calculateBoundingRect(
      rotation: rotation,
      unrotatedBox: newRect,
    );

    // Check if the new bounding rectangle is clamped within the allowed area.
    // [ISSUE] The commented-out switch below indicates that the bindingStrategy
    // should affect which rect is checked. Currently, only newBoundingRect is used.
    final bool isClamped = isRectClamped(
      newBoundingRect,
      // switch (bindingStrategy) {
      //   BindingStrategy.originalBox => newRect,
      //   BindingStrategy.boundingBox => newBoundingRect,
      // },
      clampingRect,
    );

    // If the rectangle is not clamped, compute a corrective delta to adjust it.
    if (!isClamped) {
      Vector2 correctiveDelta = BoxTransformer.stopRectAtClampingRect(
        rect: newRect,
        clampingRect: clampingRect,
        rotation: rotation,
      );
      print('correctiveDelta: $correctiveDelta');

      if (correctiveDelta.x != 0 || correctiveDelta.y != 0) {
        // Resize
        if (correctiveDelta.x > 0) {
          newRect = Box.fromLTWH(
            newRect.left + correctiveDelta.x,
            newRect.top,
            newRect.width - correctiveDelta.x,
            newRect.height,
          );
        } else {
          newRect = Box.fromLTWH(
            newRect.left,
            newRect.top,
            newRect.width + correctiveDelta.x,
            newRect.height,
          );
        }
        if (correctiveDelta.y > 0) {
          newRect = Box.fromLTWH(
            newRect.left,
            newRect.top + correctiveDelta.y,
            newRect.width,
            newRect.height - correctiveDelta.y,
          );
        } else {
          newRect = Box.fromLTWH(
            newRect.left,
            newRect.top,
            newRect.width,
            newRect.height + correctiveDelta.y,
          );
        }
      }

      newRect = repositionRotatedResizedBox(
        newRect: newRect,
        initialRect: initialRect,
        rotation: rotation,
      );

      // Recalculate the bounding rectangle after applying the corrective delta.
      newBoundingRect = BoxTransformer.calculateBoundingRect(
        rotation: rotation,
        unrotatedBox: newRect,
      );
    }

    bool isBound = false;
    // Apply size constraints if they are set.
    // if (!constraints.isUnconstrained) {
    //   // Clamp the current width and height to within allowed limits.
    //   final Dimension constrainedSize = Dimension(
    //     newRect.width.clamp(constraints.minWidth, constraints.maxWidth),
    //     newRect.height.clamp(constraints.minHeight, constraints.maxHeight),
    //   );
    //
    //   // Calculate how much adjustment is needed to reach the constrained size.
    //   final Dimension constrainedDelta = Dimension(
    //     constrainedSize.width - newRect.width,
    //     constrainedSize.height - newRect.height,
    //   );
    //
    //   // Recalculate the rectangle using the flipped handle's anchor.
    //   newRect = Box.fromHandle(
    //     flippedHandle.anchor(effectiveInitialRect),
    //     flippedHandle,
    //     newRect.width + constrainedDelta.width,
    //     newRect.height + constrainedDelta.height,
    //   );
    //
    //   // Reposition again after applying constraints.
    //   newRect = repositionRotatedResizedBox(
    //     newRect: newRect,
    //     initialRect: initialRect,
    //     rotation: rotation,
    //   );
    //
    //   // Update the bounding rectangle to reflect the constrained, repositioned rect.
    //   newBoundingRect = BoxTransformer.calculateBoundingRect(
    //     rotation: rotation,
    //     unrotatedBox: newRect,
    //   );
    //
    //   // Check if the new rectangle satisfies the constraints.
    //   isBound = isRectConstrained(
    //     newRect,
    //     constraints,
    //   );
    //
    //   // If the rectangle is still not properly constrained, fall back to minimum sizes.
    //   if (!isBound) {
    //     newRect = Box.fromHandle(
    //       handle.anchor(initialRect),
    //       handle,
    //       handle.influencesHorizontal
    //           ? constraints.minWidth
    //           : constrainedSize.width,
    //       handle.influencesVertical
    //           ? constraints.minHeight
    //           : constrainedSize.height,
    //     );
    //     // [ISSUE] Falling back to the unflipped handle and initialRect may ignore
    //     // the rotation context, leading to inconsistencies.
    //     newRect = repositionRotatedResizedBox(
    //       newRect: newRect,
    //       initialRect: initialRect,
    //       rotation: rotation,
    //     );
    //     newBoundingRect = BoxTransformer.calculateBoundingRect(
    //       rotation: rotation,
    //       unrotatedBox: newRect,
    //     );
    //   }
    // }

    final Box effectiveBindingRect = switch (bindingStrategy) {
      BindingStrategy.originalBox => effectiveInitialRect,
      BindingStrategy.boundingBox => effectiveInitialBoundingRect,
    };
    final Box bindingRect = switch (bindingStrategy) {
      BindingStrategy.originalBox => initialRect,
      BindingStrategy.boundingBox => initialBoundingRect,
    };

    final Box area = getAvailableAreaForHandle(
      rect: isBound ? effectiveBindingRect : bindingRect,
      handle: isBound ? flippedHandle : handle,
      clampingRect: clampingRect,
    );

    return (rect: newRect, largest: area, hasValidFlip: isBound);
  }

  /// Repositions a rotated and resized box back to its original unrotated
  /// position.
  ///
  /// This method attempts to calculate the correct position for a rectangle
  /// that has been both rotated and resized, returning it to the coordinate
  /// space of the unrotated original rectangle.
  ///
  /// Parameters:
  /// - [newRect]: The current, potentially rotated rectangle.
  /// - [initialRect]: The original rectangle before rotation and resizing.
  /// - [rotation]: The rotation angle (in radians).
  ///
  /// Returns a new [Box] that represents the repositioned rectangle.
  Box repositionRotatedResizedBox({
    required Box newRect,
    required Box initialRect,
    required double rotation,
  }) {
    // If there is no rotation, no repositioning is needed.
    if (rotation == 0) return newRect;

    // Compute the delta between the top-left corners of the new and initial
    // rectangles.
    final Vector2 positionDelta = newRect.topLeft - initialRect.topLeft;

    // Calculate the new position in the unrotated space.
    final Vector2 newPos = BoxTransformer.calculateUnrotatedPos(
      initialRect,
      rotation,
      positionDelta,
      newRect.size,
    );

    // Return a new Box with the repositioned top-left coordinates.
    return Box.fromLTWH(newPos.x, newPos.y, newRect.width, newRect.height);
  }
}
