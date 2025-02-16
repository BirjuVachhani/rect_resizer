part of 'resizer.dart';

/// Handles resizing for [ResizeMode.symmetric].
final class SymmetricResizer extends Resizer {
  /// A default constructor for [SymmetricResizer].
  const SymmetricResizer();

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
    final double horizontalMirrorRight =
        clampingRect.right - explodedRect.center.x;
    final double horizontalMirrorLeft =
        explodedRect.center.x - clampingRect.left;
    final double verticalMirrorTop = explodedRect.center.y - clampingRect.top;
    final double verticalMirrorBottom =
        clampingRect.bottom - explodedRect.center.y;

    Box area = Box.fromCenter(
      center: explodedRect.center,
      width: min(horizontalMirrorLeft, horizontalMirrorRight) * 2,
      height: min(verticalMirrorTop, verticalMirrorBottom) * 2,
    );

    if (!constraints.isUnconstrained) {
      final constrainedBox = Box.fromCenter(
        center: explodedRect.center,
        width: constraints.maxWidth,
        height: constraints.maxHeight,
      );

      area = Box.fromLTRB(
        max(area.left, constrainedBox.left),
        max(area.top, constrainedBox.top),
        min(area.right, constrainedBox.right),
        min(area.bottom, constrainedBox.bottom),
      );
    }

    final Box minRect = Box.fromCenter(
      center: explodedRect.center,
      width: constraints.isUnconstrained ? 0 : constraints.minWidth,
      height: constraints.isUnconstrained ? 0 : constraints.minHeight,
    );

    final Box newRect = Box.fromCenter(
      center: explodedRect.center,
      width: min(area.width, max(explodedRect.width, minRect.width)),
      height: min(area.height, max(explodedRect.height, minRect.height)),
    );

    return (rect: newRect, largest: area, hasValidFlip: true);
  }
}
