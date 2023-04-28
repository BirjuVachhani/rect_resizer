import 'dart:math';

import 'package:vector_math/vector_math.dart';

import 'enums.dart';
import 'geometry.dart';

/// Flips the given [rect] with given [flip] with [handle] being the
/// pivot point.
Box flipBox(Box rect, Flip flip, HandlePosition handle) {
  switch (handle) {
    case HandlePosition.none:
      return rect;
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
Flip getFlipForBox(
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

/// Returns a clamping box for [ResizeMode.scaledSymmetric].
Box scaledSymmetricClampingBox(Box initialRect, Box clampingRect) {
  final closestHandle = getClosestEdge(initialRect, clampingRect);

  final initialAspectRatio = initialRect.width / initialRect.height;

  double width;
  double height;
  switch (closestHandle) {
    case HandlePosition.top:
      height = (initialRect.center.y - clampingRect.top) * 2;
      width = height * initialAspectRatio;
      break;
    case HandlePosition.right:
      width = (clampingRect.right - initialRect.center.x) * 2;
      height = width / initialAspectRatio;
      break;
    case HandlePosition.bottom:
      height = (clampingRect.bottom - initialRect.center.y) * 2;
      width = height * initialAspectRatio;
      break;
    case HandlePosition.left:
      width = (initialRect.center.x - clampingRect.left) * 2;
      height = width / initialAspectRatio;
      break;
    default:
      throw Exception('Unknown handle');
  }

  return Box.fromCenter(
    center: initialRect.center,
    width: width,
    height: height,
  );
}

/// Returns the handle/edge of the [initialRect] that is closest to one of the
/// edge of [clampingRect] for [ResizeMode.scale].
HandlePosition getClosestEdge(
  Box initialRect,
  Box clampingRect, {
  HandlePosition? excludeHandle,
}) {
  return intersectionBetweenRects(
    outerRect: clampingRect,
    innerRect: initialRect,
    excludeHandle: excludeHandle,
  );
}

/// Returns a clamping rect for given side handle that preserves aspect ratio.
Box getClampingRectForSideHandle({
  required Box initialRect,
  required Box availableArea,
  required HandlePosition handle,
}) {
  final closestEdge = getClosestEdge(
    initialRect,
    availableArea,
    excludeHandle: handle.opposite,
  );

  final initialAspectRatio = initialRect.width / initialRect.height;

  double width;
  double height;

  switch (closestEdge) {
    case HandlePosition.left:
      width = (initialRect.center.x - availableArea.left) * 2;
      height = width / initialAspectRatio;
      break;
    case HandlePosition.top:
      height = (initialRect.center.y - availableArea.top) * 2;
      width = height * initialAspectRatio;
      break;
    case HandlePosition.right:
      width = (availableArea.right - initialRect.center.x) * 2;
      height = width / initialAspectRatio;
      break;
    case HandlePosition.bottom:
      height = (availableArea.bottom - initialRect.center.y) * 2;
      width = height * initialAspectRatio;
      break;
    case HandlePosition.topLeft:
    case HandlePosition.topRight:
    case HandlePosition.bottomLeft:
    case HandlePosition.bottomRight:
    case HandlePosition.none:
      throw Exception('Unsupported handle');
  }

  switch (handle) {
    case HandlePosition.none:
      return availableArea;
    case HandlePosition.left:
      final maxWidth = min(width, initialRect.right - availableArea.left);
      final maxHeight = maxWidth / initialAspectRatio;
      return Box.fromLTWH(
        initialRect.right - maxWidth,
        initialRect.center.y - maxHeight / 2,
        maxWidth,
        maxHeight,
      );
    case HandlePosition.top:
      final maxHeight = min(height, initialRect.bottom - availableArea.top);
      final maxWidth = maxHeight * initialAspectRatio;
      return Box.fromLTWH(
        initialRect.center.x - maxWidth / 2,
        initialRect.bottom - maxHeight,
        maxWidth,
        maxHeight,
      );
    case HandlePosition.right:
      final maxWidth = min(width, availableArea.right - initialRect.left);
      final maxHeight = maxWidth / initialAspectRatio;

      return Box.fromLTWH(
        initialRect.centerLeft.x,
        initialRect.centerLeft.y - maxHeight / 2,
        maxWidth,
        maxHeight,
      );
    case HandlePosition.bottom:
      final maxHeight = min(height, availableArea.bottom - initialRect.top);
      final maxWidth = maxHeight * initialAspectRatio;
      return Box.fromLTWH(
        initialRect.center.x - maxWidth / 2,
        initialRect.top,
        maxWidth,
        maxHeight,
      );
    case HandlePosition.topLeft:
    case HandlePosition.topRight:
    case HandlePosition.bottomLeft:
    case HandlePosition.bottomRight:
      throw Exception('Unsupported handle');
  }
}

/// Returns a vector of the point of intersection between two given lines.
/// First two vectors [p1] and [p2] are the first line, and the second two
/// vectors [p3] and [p4] are the second line.
///
/// [returns] The point of intersection. IF there is no intersection, then
/// the function returns null.
Vector2? intersectionBetweenTwoLines(
    Vector2 p1, Vector2 p2, Vector2 p3, Vector2 p4) {
  final double t =
      ((p1.x - p3.x) * (p3.y - p4.y) - (p1.y - p3.y) * (p3.x - p4.x)) /
          ((p1.x - p2.x) * (p3.y - p4.y) - (p1.y - p2.y) * (p3.x - p4.x));
  final double u =
      ((p1.x - p3.x) * (p1.y - p2.y) - (p1.y - p3.y) * (p1.x - p2.x)) /
          ((p1.x - p2.x) * (p3.y - p4.y) - (p1.y - p2.y) * (p3.x - p4.x));

  if (0 <= t && t <= 1 && 0 <= u && u <= 1) {
    return Vector2(p1.x + t * (p2.x - p1.x), p1.y + t * (p2.y - p1.y));
  } else {
    return null;
  }
}

/// Returns
HandlePosition intersectionBetweenLineAndRect(
  Vector2 inner,
  Vector2 outer,
  Box rect,
  Box initialRect, {
  HandlePosition? excludeHandle,
}) {
  final Vector2 topLeft = rect.topLeft;
  final Vector2 topRight = rect.topRight;
  final Vector2 bottomLeft = rect.bottomLeft;
  final Vector2 bottomRight = rect.bottomRight;

  // final Vector2? result = extend2(rect, inner, outer);

  final Vector2? top =
      intersectionBetweenTwoLines(inner, outer, topLeft, topRight);
  final Vector2? bottom =
      intersectionBetweenTwoLines(inner, outer, bottomLeft, bottomRight);
  final Vector2? left =
      intersectionBetweenTwoLines(inner, outer, topLeft, bottomLeft);
  final Vector2? right =
      intersectionBetweenTwoLines(inner, outer, topRight, bottomRight);

  final sides = {
    HandlePosition.top: top,
    HandlePosition.bottom: bottom,
    HandlePosition.left: left,
    HandlePosition.right: right,
  };

  sides.remove(excludeHandle);

  final closest = sides.entries
      .where((element) => element.value != null)
      .reduce((value, element) {
    final valueDistance = value.value!.distanceToSquared(initialRect.center);
    final elementDistance =
        element.value!.distanceToSquared(initialRect.center);

    if (valueDistance < elementDistance) {
      return value;
    } else {
      return element;
    }
  });

  return closest.key;
}

/// Extends given line to the given rectangle such that it touches the
/// rectangle.
List<Vector2>? extendLineToRect(Box rect, Vector2 p1, Vector2 p2) {
  final result = extendLinePointsToRectPoints(
      rect.left, rect.top, rect.right, rect.bottom, p1.x, p1.y, p2.x, p2.y);

  if (result == null) return null;

  return [Vector2(result[0], result[1]), Vector2(result[2], result[3])];
}

/// Extends given line to the given rectangle such that it touches the
/// rectangle points.
List<double>? extendLinePointsToRectPoints(
  double left,
  double top,
  double right,
  double bottom,
  double x1,
  double y1,
  double x2,
  double y2,
) {
  if (y1 == y2) {
    return [left, y1, right, y1];
  }
  if (x1 == x2) {
    return [x1, top, x1, bottom];
  }

  double yForLeft = y1 + (y2 - y1) * (left - x1) / (x2 - x1);
  double yForRight = y1 + (y2 - y1) * (right - x1) / (x2 - x1);

  double xForTop = x1 + (x2 - x1) * (top - y1) / (y2 - y1);
  double xForBottom = x1 + (x2 - x1) * (bottom - y1) / (y2 - y1);

  if (top <= yForLeft &&
      yForLeft <= bottom &&
      top <= yForRight &&
      yForRight <= bottom) {
    return [left, yForLeft, right, yForRight];
  } else if (top <= yForLeft && yForLeft <= bottom) {
    if (left <= xForBottom && xForBottom <= right) {
      return [left, yForLeft, xForBottom, bottom];
    } else if (left <= xForTop && xForTop <= right) {
      return [left, yForLeft, xForTop, top];
    }
  } else if (top <= yForRight && yForRight <= bottom) {
    if (left <= xForTop && xForTop <= right) {
      return [xForTop, top, right, yForRight];
    }
    if (left <= xForBottom && xForBottom <= right) {
      return [xForBottom, bottom, right, yForRight];
    }
  } else if (left <= xForTop &&
      xForTop <= right &&
      left <= xForBottom &&
      xForBottom <= right) {
    return [xForTop, top, xForBottom, bottom];
  }
  return null;
}

/// Returns the intersection between the given rectangles with assumption that
/// [innerRect] is completely inside [outerRect]. The intersection is calculated
/// using the center of the [innerRect] and the corners of the [outerRect].
/// Returns the closest edge/handle of [outerRect] to the [innerRect].
HandlePosition intersectionBetweenRects({
  required Box outerRect,
  required Box innerRect,
  HandlePosition? excludeHandle,
}) {
  final line1 =
      extendLineToRect(outerRect, innerRect.center, innerRect.bottomRight)!;

  final line2 =
      extendLineToRect(outerRect, innerRect.center, innerRect.topRight)!;

  final intersections1 = findLineIntersection(
    line1[0],
    line1[1],
    outerRect,
    innerRect,
  );

  intersections1.remove(excludeHandle);

  final intersections2 = findLineIntersection(
    line2[0],
    line2[1],
    outerRect,
    innerRect,
  );

  intersections2.remove(excludeHandle);

  final List<MapEntry<HandlePosition, Vector2>> intersections = [
    ...intersections1.entries,
    ...intersections2.entries,
  ];

  final closest = intersections.reduce((value, element) {
    final valueDistance = value.value.distanceToSquared(innerRect.center);
    final elementDistance = element.value.distanceToSquared(innerRect.center);

    if (valueDistance < elementDistance) {
      return value;
    } else {
      return element;
    }
  });

  return closest.key;
}

/// Finds the intersection between the given line and the given rectangle and
/// returns distance between the intersection and the [inner] point.
Map<HandlePosition, Vector2> findLineIntersection(
    Vector2 inner, Vector2 outer, Box rect, Box initialRect) {
  final Vector2 topLeft = rect.topLeft;
  final Vector2 topRight = rect.topRight;
  final Vector2 bottomLeft = rect.bottomLeft;
  final Vector2 bottomRight = rect.bottomRight;

  final Vector2? top =
      intersectionBetweenTwoLines(inner, outer, topLeft, topRight);
  final Vector2? bottom =
      intersectionBetweenTwoLines(inner, outer, bottomLeft, bottomRight);
  final Vector2? left =
      intersectionBetweenTwoLines(inner, outer, topLeft, bottomLeft);
  final Vector2? right =
      intersectionBetweenTwoLines(inner, outer, topRight, bottomRight);

  final Map<HandlePosition, Vector2?> sides = {
    HandlePosition.top: top,
    HandlePosition.bottom: bottom,
    HandlePosition.left: left,
    HandlePosition.right: right,
  };

  return {
    for (final entry in sides.entries)
      if (entry.value != null) entry.key: entry.value!
  };
}

/// Returns the available area for the given handle.
Box getAvailableAreaForHandle({
  required Box rect,
  required Box clampingRect,
  required HandlePosition handle,
}) {
  return Box.fromLTRB(
    handle.influencesLeft ? clampingRect.left : rect.left,
    handle.influencesTop ? clampingRect.top : rect.top,
    handle.influencesRight ? clampingRect.right : rect.right,
    handle.influencesBottom ? clampingRect.bottom : rect.bottom,
  );
}

/// Returns the clamping rect for the given handle for [ResizeMode.scale].
Box getClampingRectForHandle({
  required Box initialRect,
  required Box availableArea,
  required HandlePosition handle,
}) {
  switch (handle) {
    case HandlePosition.none:
      return availableArea;
    case HandlePosition.topLeft:
    case HandlePosition.topRight:
    case HandlePosition.bottomLeft:
    case HandlePosition.bottomRight:
      return getClampingRectForCornerHandle(
        initialRect: initialRect,
        availableArea: availableArea,
        handle: handle,
      );
    case HandlePosition.left:
    case HandlePosition.top:
    case HandlePosition.right:
    case HandlePosition.bottom:
      return getClampingRectForSideHandle(
        initialRect: initialRect,
        availableArea: availableArea,
        handle: handle,
      );
  }
}

/// Returns the clamping rect for the given corner handle for [ResizeMode.scale].
Box getClampingRectForCornerHandle({
  required Box initialRect,
  required Box availableArea,
  required HandlePosition handle,
}) {
  if (handle == HandlePosition.none) {
    handle = HandlePosition.bottomRight;
  }

  final initialAspectRatio = initialRect.aspectRatio;

  final double areaAspectRatio = availableArea.aspectRatio;

  double maxWidth;
  double maxHeight;

  if (areaAspectRatio > 1) {
    // Clamping area:    Landscape
    // Box:              Landscape
    // Limiting factor:  Width
    if (initialAspectRatio > areaAspectRatio) {
      maxWidth = availableArea.width;
      maxHeight = maxWidth / initialAspectRatio;
    } else {
      // Clamping area:    Landscape
      // Box:              Portrait
      // Limiting factor:  Height
      maxHeight = availableArea.height;
      maxWidth = maxHeight * initialAspectRatio;
    }
  } else {
    // Clamping area:    Portrait
    // Box:              Landscape
    // Limiting factor:  Width
    if (initialAspectRatio > areaAspectRatio) {
      maxWidth = availableArea.width;
      maxHeight = maxWidth / initialAspectRatio;
    } else {
      // Clamping area:    Portrait
      // Box:              Portrait
      // Limiting factor:  Height
      maxHeight = availableArea.height;
      maxWidth = maxHeight * initialAspectRatio;
    }
  }

  return Box.fromHandle(
    handle.anchor(initialRect),
    handle,
    maxWidth,
    maxHeight,
  );
}