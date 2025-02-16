import 'dart:math' as math;

import 'package:vector_math/vector_math.dart';

import '../box_transform.dart';

/// Holds a set of constraints to apply to any [Dimension] or [Box].
class Constraints {
  /// The minimum width that the clamped object cannot be less than.
  final double minWidth;

  /// The maximum width that the clamped object cannot be greater than.
  final double maxWidth;

  /// The minimum height that the clamped object cannot be less than.
  final double minHeight;

  /// The maximum height that the clamped object cannot be greater than.
  final double maxHeight;

  /// Creates a new [Constraints] object.
  const Constraints({
    this.minWidth = 0.0,
    this.maxWidth = double.infinity,
    this.minHeight = 0.0,
    this.maxHeight = double.infinity,
  })  : assert(minWidth <= maxWidth),
        assert(minHeight <= maxHeight);

  /// Creates a new unconstrained [Constraints] object.
  const Constraints.unconstrained()
      : minWidth = double.infinity,
        maxWidth = double.infinity,
        minHeight = double.infinity,
        maxHeight = double.infinity;

  /// Whether the [minWidth] and [minHeight] are both zero.
  bool get goesToZero => minWidth == 0 && minHeight == 0;

  /// Whether this [Constraints] object represents no constraints.
  bool get isUnconstrained =>
      minWidth == double.infinity &&
      minHeight == double.infinity &&
      maxWidth == double.infinity &&
      maxHeight == double.infinity;

  /// A helper function that clamps a given [value] by [min] and [max].
  static num _clamp(num value, num min, num max) {
    return math.max(min, math.min(max, value));
  }

  /// Constrains a given [dimension] by the [minWidth], [maxWidth], [minHeight],
  /// and [maxHeight] values.
  Dimension constrainDimension(Dimension dimension) {
    if (isUnconstrained) return dimension;
    return Dimension(
      _clamp(dimension.width, minWidth, maxWidth).toDouble(),
      _clamp(dimension.height, minHeight, maxHeight).toDouble(),
    );
  }

  /// Constrains a given [rect] by the [minWidth], [maxWidth], [minHeight], and
  /// [maxHeight] values.
  ///
  /// If [absolute] is true, the [rect] will be constrained by the absolute
  /// values of its width and height.
  Box constrainRect(Box rect, {bool absolute = false}) {
    if (isUnconstrained) return rect;

    final double width = absolute ? rect.width.abs() : rect.width;
    final double height = absolute ? rect.height.abs() : rect.height;
    return Box.fromLTWH(
      rect.left,
      rect.top,
      _clamp(width, minWidth, maxWidth).toDouble(),
      _clamp(height, minHeight, maxHeight).toDouble(),
    );
  }

  @override
  String toString() {
    return 'Constraints(minWidth: $minWidth, maxWidth: $maxWidth, minHeight: $minHeight, maxHeight: $maxHeight)';
  }

  @override
  bool operator ==(Object other) {
    if (other is! Constraints) return false;
    return other.minWidth == minWidth &&
        other.maxWidth == maxWidth &&
        other.minHeight == minHeight &&
        other.maxHeight == maxHeight;
  }

  @override
  int get hashCode => Object.hash(minWidth, maxWidth, minHeight, maxHeight);
}

/// Linearly interpolate between two doubles.
///
/// Same as [lerpDouble] but specialized for non-null `double` type.
double _lerpDouble(double a, double b, double t) => a * (1.0 - t) + b * t;

/// A 2D size with [width] and [height].
class Dimension {
  /// The width of the [Dimension].
  final double width;

  /// The height of the [Dimension].
  final double height;

  /// Creates a [Dimension] with the given [width] and [height].
  const Dimension(this.width, this.height);

  /// Creates an instance of [Dimension] that has the same values as another.
  Dimension.copy(Dimension source)
      : width = source.width,
        height = source.height;

  /// Creates a square [Dimension] whose [width] and [height] are the given dimension.
  ///
  /// See also:
  ///
  ///  * [Dimension.fromRadius], which is more convenient when the available size
  ///    is the radius of a circle.
  const Dimension.square(double dimension)
      : width = dimension,
        height = dimension;

  /// Creates a [Dimension] with the given [width] and an infinite [height].
  const Dimension.fromWidth(this.width) : height = double.infinity;

  /// Creates a [Dimension] with the given [height] and an infinite [width].
  const Dimension.fromHeight(this.height) : width = double.infinity;

  /// Creates a square [Dimension] whose [width] and [height] are twice the given
  /// dimension.
  ///
  /// This is a square that contains a circle with the given radius.
  ///
  /// See also:
  ///
  ///  * [Dimension.square], which creates a square with the given dimension.
  const Dimension.fromRadius(double radius)
      : width = radius * 2.0,
        height = radius * 2.0;

  /// The aspect ratio of this size.
  ///
  /// This returns the [width] divided by the [height].
  ///
  /// If the [width] is zero, the result will be zero. If the [height] is zero
  /// (and the [width] is not), the result will be [double.infinity] or
  /// [double.negativeInfinity] as determined by the sign of [width].
  double get aspectRatio => switch (this) {
        _ when height != 0 => width / height,
        _ when width > 0 => double.infinity,
        _ when width < 0 => double.negativeInfinity,
        _ => 0,
      };

  /// An empty size, one with a zero width and a zero height.
  static const Dimension zero = Dimension(0.0, 0.0);

  /// A size whose [width] and [height] are infinite.
  ///
  /// See also:
  ///
  ///  * [isInfinite], which checks whether either dimension is infinite.
  ///  * [isFinite], which checks whether both dimensions are finite.
  static const Dimension infinite = Dimension(double.infinity, double.infinity);

  /// Removes [other] from this size.
  Dimension operator -(Dimension other) =>
      Dimension(width - other.width, height - other.height);

  /// Adds [other] to this size.
  Dimension operator +(Dimension other) =>
      Dimension(width + other.width, height + other.height);

  /// Multiplication operator.
  ///
  /// Returns a [Dimension] whose dimensions are the dimensions of the left-hand-side
  /// operand (a [Dimension]) multiplied by the scalar right-hand-side operand (a
  /// [double]).
  Dimension operator *(double operand) =>
      Dimension(width * operand, height * operand);

  /// Division operator.
  ///
  /// Returns a [Dimension] whose dimensions are the dimensions of the left-hand-side
  /// operand (a [Dimension]) divided by the scalar right-hand-side operand (a
  /// [double]).
  Dimension operator /(double operand) =>
      Dimension(width / operand, height / operand);

  /// Integer (truncating) division operator.
  ///
  /// Returns a [Dimension] whose dimensions are the dimensions of the left-hand-side
  /// operand (a [Dimension]) divided by the scalar right-hand-side operand (a
  /// [double]), rounded towards zero.
  Dimension operator ~/(double operand) =>
      Dimension((width ~/ operand).toDouble(), (height ~/ operand).toDouble());

  /// Modulo (remainder) operator.
  ///
  /// Returns a [Dimension] whose dimensions are the remainder of dividing the
  /// left-hand-side operand (a [Dimension]) by the scalar right-hand-side operand (a
  /// [double]).
  Dimension operator %(double operand) =>
      Dimension(width % operand, height % operand);

  /// The lesser of the magnitudes of the [width] and the [height].
  double get shortestSide => math.min(width.abs(), height.abs());

  /// The greater of the magnitudes of the [width] and the [height].
  double get longestSide => math.max(width.abs(), height.abs());

  // Convenience methods that do the equivalent of calling the similarly named
  // methods on a Box constructed from the given origin and this size.

  /// The Vector2 to the intersection of the top and left edges of the rectangle
  /// described by the given [Vector2] (which is interpreted as the top-left corner)
  /// and this [Dimension].
  ///
  /// See also [Box.topLeft].
  Vector2 topLeft(Vector2 origin) => origin;

  /// The Vector2 to the center of the top edge of the rectangle described by the
  /// given Vector2 (which is interpreted as the top-left corner) and this size.
  ///
  /// See also [Box.topCenter].
  Vector2 topCenter(Vector2 origin) =>
      Vector2(origin.x + width / 2.0, origin.y);

  /// The Vector2 to the intersection of the top and right edges of the rectangle
  /// described by the given Vector2 (which is interpreted as the top-left corner)
  /// and this size.
  ///
  /// See also [Box.topRight].
  Vector2 topRight(Vector2 origin) => Vector2(origin.x + width, origin.y);

  /// The Vector2 to the center of the left edge of the rectangle described by the
  /// given Vector2 (which is interpreted as the top-left corner) and this size.
  ///
  /// See also [Box.centerLeft].
  Vector2 centerLeft(Vector2 origin) =>
      Vector2(origin.x, origin.y + height / 2.0);

  /// The Vector2 to the point halfway between the left and right and the top and
  /// bottom edges of the rectangle described by the given Vector2 (which is
  /// interpreted as the top-left corner) and this size.
  ///
  /// See also [Box.center].
  Vector2 center(Vector2 origin) =>
      Vector2(origin.x + width / 2.0, origin.y + height / 2.0);

  /// The Vector2 to the center of the right edge of the rectangle described by the
  /// given Vector2 (which is interpreted as the top-left corner) and this size.
  ///
  /// See also [Box.centerLeft].
  Vector2 centerRight(Vector2 origin) =>
      Vector2(origin.x + width, origin.y + height / 2.0);

  /// The Vector2 to the intersection of the bottom and left edges of the
  /// rectangle described by the given Vector2 (which is interpreted as the
  /// top-left corner) and this size.
  ///
  /// See also [Box.bottomLeft].
  Vector2 bottomLeft(Vector2 origin) => Vector2(origin.x, origin.y + height);

  /// The Vector2 to the center of the bottom edge of the rectangle described by
  /// the given Vector2 (which is interpreted as the top-left corner) and this
  /// size.
  ///
  /// See also [Box.bottomLeft].
  Vector2 bottomCenter(Vector2 origin) =>
      Vector2(origin.x + width / 2.0, origin.y + height);

  /// The Vector2 to the intersection of the bottom and right edges of the
  /// rectangle described by the given Vector2 (which is interpreted as the
  /// top-left corner) and this size.
  ///
  /// See also [Box.bottomRight].
  Vector2 bottomRight(Vector2 origin) =>
      Vector2(origin.x + width, origin.y + height);

  /// Whether the point specified by the given Vector2 (which is assumed to be
  /// relative to the top left of the size) lies between the left and right and
  /// the top and bottom edges of a rectangle of this size.
  ///
  /// Boxes include their top and left edges but exclude their bottom and
  /// right edges.
  bool contains(Vector2 vec) =>
      vec.x >= 0.0 && vec.x < width && vec.y >= 0.0 && vec.y < height;

  /// Constrains this with given constraints.
  Dimension constrainBy(Constraints constraints) =>
      constraints.constrainDimension(this);

  /// A [Dimension] with the [width] and [height] swapped.
  Dimension get flipped => Dimension(height, width);

  /// Returns a new [Dimension] with the width and height rounded to the next
  /// largest integer values.
  Dimension ceil() => Dimension(width.ceilToDouble(), height.ceilToDouble());

  /// Returns a new [Dimension] with the width and height rounded to the next
  /// smallest integer values.
  Dimension floor() => Dimension(width.floorToDouble(), height.floorToDouble());

  /// Returns a [Vector2] representation of this [Dimension].
  Vector2 toVector() => Vector2(width, height);

  /// Linearly interpolate between two sizes
  ///
  /// If either size is null, this function interpolates from [Dimension.zero].
  ///
  /// The `t` argument represents position on the timeline, with 0.0 meaning
  /// that the interpolation has not started, returning `a` (or something
  /// equivalent to `a`), 1.0 meaning that the interpolation has finished,
  /// returning `b` (or something equivalent to `b`), and values in between
  /// meaning that the interpolation is at the relevant point on the timeline
  /// between `a` and `b`. The interpolation can be extrapolated beyond 0.0 and
  /// 1.0, so negative values and values greater than 1.0 are valid (and can
  /// easily be generated by curves such as [Curves.elasticInOut]).
  ///
  /// Values for `t` are usually obtained from an [Animation<double>], such as
  /// an [AnimationController].
  static Dimension? lerp(Dimension? a, Dimension? b, double t) {
    if (b == null) {
      if (a == null) {
        return null;
      } else {
        return a * (1.0 - t);
      }
    } else {
      if (a == null) {
        return b * t;
      } else {
        return Dimension(_lerpDouble(a.width, b.width, t),
            _lerpDouble(a.height, b.height, t));
      }
    }
  }

  /// Compares two Dimensions for equality.
  @override
  bool operator ==(Object other) {
    return other is Dimension && other.width == width && other.height == height;
  }

  @override
  int get hashCode => Object.hash(width, height);

  @override
  String toString() =>
      'Dimension(${width.toStringAsFixed(1)}, ${height.toStringAsFixed(1)})';
}

/// An immutable, 2D, axis-aligned, floating-point rectangle whose coordinates
/// are relative to a given origin.
///
/// A Box can be created with one its constructors or from an [Vector2] and a
/// [Dimension] using the `&` operator:
///
/// ```dart
/// Box myBox = const Vector2(1.0, 2.0) & const Dimension(3.0, 4.0);
/// ```
class Box {
  /// Construct a rectangle from its left, top, right, and bottom edges.
  const Box.fromLTRB(this.left, this.top, this.right, this.bottom);

  /// Construct a rectangle from its left and top edges, its width, and its
  /// height.
  ///
  /// To construct a [Box] from an [Vector2] and a [Dimension], you can use the
  /// rectangle constructor operator `&`. See [Vector2.&].
  const Box.fromLTWH(double left, double top, double width, double height)
      : this.fromLTRB(left, top, left + width, top + height);

  /// Construct a rectangle that bounds the given circle.
  ///
  /// The `center` argument is assumed to be an Vector2 from the origin.
  Box.fromCircle({required Vector2 center, required double radius})
      : this.fromCenter(
          center: center,
          width: radius * 2,
          height: radius * 2,
        );

  /// Constructs a rectangle from its center point, width, and height.
  ///
  /// The `center` argument is assumed to be an Vector2 from the origin.
  Box.fromCenter({
    required Vector2 center,
    required double width,
    required double height,
  }) : this.fromLTRB(
          center.x - width / 2,
          center.y - height / 2,
          center.x + width / 2,
          center.y + height / 2,
        );

  /// Construct the smallest rectangle that encloses the given Vector2s, treating
  /// them as vectors from the origin.
  Box.fromPoints(Vector2 a, Vector2 b)
      : this.fromLTRB(
          math.min(a.x, b.x),
          math.min(a.y, b.y),
          math.max(a.x, b.x),
          math.max(a.y, b.y),
        );

  /// Construct a rectangle from given handle and its origin.
  factory Box.fromHandle(
      Vector2 origin, HandlePosition handle, double width, double height) {
    return switch (handle) {
      HandlePosition.none =>
        throw ArgumentError('HandlePosition.none is not supported!'),
      HandlePosition.topLeft =>
        Box.fromLTWH(origin.x - width, origin.y - height, width, height),
      HandlePosition.topRight =>
        Box.fromLTWH(origin.x, origin.y - height, width, height),
      HandlePosition.bottomLeft =>
        Box.fromLTWH(origin.x - width, origin.y, width, height),
      HandlePosition.bottomRight =>
        Box.fromLTWH(origin.x, origin.y, width, height),
      HandlePosition.left =>
        Box.fromLTWH(origin.x - width, origin.y - height / 2, width, height),
      HandlePosition.top =>
        Box.fromLTWH(origin.x - width / 2, origin.y - height, width, height),
      HandlePosition.right =>
        Box.fromLTWH(origin.x, origin.y - height / 2, width, height),
      HandlePosition.bottom =>
        Box.fromLTWH(origin.x - width / 2, origin.y, width, height)
    };
  }

  /// The Vector2 of the left edge of this rectangle from the x axis.
  final double left;

  /// The Vector2 of the top edge of this rectangle from the y axis.
  final double top;

  /// The Vector2 of the right edge of this rectangle from the x axis.
  final double right;

  /// The Vector2 of the bottom edge of this rectangle from the y axis.
  final double bottom;

  /// The distance between the left and right edges of this rectangle.
  double get width => right - left;

  /// The distance between the top and bottom edges of this rectangle.
  double get height => bottom - top;

  /// The distance between the upper-left corner and the lower-right corner of
  /// this rectangle.
  Dimension get size => Dimension(width, height);

  /// Whether any of the dimensions are `NaN`.
  bool get hasNaN => left.isNaN || top.isNaN || right.isNaN || bottom.isNaN;

  /// A rectangle with left, top, right, and bottom edges all at zero.
  static const Box zero = Box.fromLTRB(0.0, 0.0, 0.0, 0.0);

  /// Used to construct the largest possible [Box] instance.
  static const double _giantScalar = 1.0E+9; // matches kGiantBox from layer.h

  /// A rectangle that covers the entire coordinate space.
  ///
  /// This covers the space from -1e9,-1e9 to 1e9,1e9.
  /// This is the space over which graphics operations are valid.
  static const Box largest =
      Box.fromLTRB(-_giantScalar, -_giantScalar, _giantScalar, _giantScalar);

  /// Whether any of the coordinates of this rectangle are equal to positive
  /// infinity.
  /// Included for consistency with Vector2 and Dimension
  bool get isInfinite =>
      left >= double.infinity ||
      top >= double.infinity ||
      right >= double.infinity ||
      bottom >= double.infinity;

  /// Whether all coordinates of this rectangle are finite.
  bool get isFinite =>
      left.isFinite && top.isFinite && right.isFinite && bottom.isFinite;

  /// Whether this rectangle encloses a non-zero area. Negative areas are
  /// considered empty.
  bool get isEmpty => left >= right || top >= bottom;

  /// Returns a new rectangle translated by the given Vector2.
  ///
  /// To translate a rectangle by separate x and y components rather than by an
  /// [Vector2], consider [translate].
  Box shift(Vector2 vec) =>
      Box.fromLTRB(left + vec.x, top + vec.y, right + vec.x, bottom + vec.y);

  /// Returns a new rectangle with translateX added to the x components and
  /// translateY added to the y components.
  ///
  /// To translate a rectangle by an [Vector2] rather than by separate x and y
  /// components, consider [shift].
  Box translate(double translateX, double translateY) => Box.fromLTRB(
        left + translateX,
        top + translateY,
        right + translateX,
        bottom + translateY,
      );

  /// Returns a new rectangle with edges moved outwards by the given delta.
  Box inflate(double delta) =>
      Box.fromLTRB(left - delta, top - delta, right + delta, bottom + delta);

  /// Returns a new rectangle with edges moved inwards by the given delta.
  Box deflate(double delta) => inflate(-delta);

  /// Returns a new rectangle that is the intersection of the given
  /// rectangle and this rectangle. The two rectangles must overlap
  /// for this to be meaningful. If the two rectangles do not overlap,
  /// then the resulting Box will have a negative width or height.
  Box intersect(Box other) => Box.fromLTRB(
      math.max(left, other.left),
      math.max(top, other.top),
      math.min(right, other.right),
      math.min(bottom, other.bottom));

  /// Returns a new rectangle which is the bounding box containing this
  /// rectangle and the given rectangle.
  Box expandToInclude(Box other) => Box.fromLTRB(
        math.min(left, other.left),
        math.min(top, other.top),
        math.max(right, other.right),
        math.max(bottom, other.bottom),
      );

  /// Whether `other` has a nonzero area of overlap with this rectangle.
  bool overlaps(Box other) {
    if (right <= other.left || other.right <= left) return false;
    if (bottom <= other.top || other.bottom <= top) return false;
    return true;
  }

  /// The lesser of the magnitudes of the [width] and the [height] of this
  /// rectangle.
  double get shortestSide => math.min(width.abs(), height.abs());

  /// The greater of the magnitudes of the [width] and the [height] of this
  /// rectangle.
  double get longestSide => math.max(width.abs(), height.abs());

  /// The Vector2 to the intersection of the top and left edges of this rectangle.
  ///
  /// See also [Dimension.topLeft].
  Vector2 get topLeft => Vector2(left, top);

  /// The Vector2 to the center of the top edge of this rectangle.
  ///
  /// See also [Dimension.topCenter].
  Vector2 get topCenter => Vector2(left + width / 2.0, top);

  /// The Vector2 to the intersection of the top and right edges of this rectangle.
  ///
  /// See also [Dimension.topRight].
  Vector2 get topRight => Vector2(right, top);

  /// The Vector2 to the center of the left edge of this rectangle.
  ///
  /// See also [Dimension.centerLeft].
  Vector2 get centerLeft => Vector2(left, top + height / 2.0);

  /// The Vector2 to the point halfway between the left and right and the top and
  /// bottom edges of this rectangle.
  ///
  /// See also [Dimension.center].
  Vector2 get center => Vector2(left + width / 2.0, top + height / 2.0);

  /// The Vector2 to the center of the right edge of this rectangle.
  ///
  /// See also [Dimension.centerLeft].
  Vector2 get centerRight => Vector2(right, top + height / 2.0);

  /// The Vector2 to the intersection of the bottom and left edges of this rectangle.
  ///
  /// See also [Dimension.bottomLeft].
  Vector2 get bottomLeft => Vector2(left, bottom);

  /// The Vector2 to the center of the bottom edge of this rectangle.
  ///
  /// See also [Dimension.bottomLeft].
  Vector2 get bottomCenter => Vector2(left + width / 2.0, bottom);

  /// The Vector2 to the intersection of the bottom and right edges of this rectangle.
  ///
  /// See also [Dimension.bottomRight].
  Vector2 get bottomRight => Vector2(right, bottom);

  /// Returns aspect ratio of this rectangle.
  double get aspectRatio => size.aspectRatio;

  /// Returns aspect ratio of this rectangle. Unlike [aspectRatio], it has a
  /// safe mechanism where if the width or height is zero, returns 1.
  double get safeAspectRatio => switch (size) {
        _ when width == 0 || height == 0 => 1,
        _ => size.aspectRatio,
      };

  /// Returns a list of the four corners of this rectangle.
  List<Vector2> get points => [
        topLeft,
        topRight,
        bottomRight,
        bottomLeft,
      ];

  /// Returns a map of the four corners of this rectangle mapped as
  /// a [Quadrant] to a [Vector2].
  Map<Quadrant, Vector2> get sidedPoints => {
        Quadrant.topLeft: topLeft,
        Quadrant.topRight: topRight,
        Quadrant.bottomRight: bottomRight,
        Quadrant.bottomLeft: bottomLeft,
      };

  /// Whether the point specified by the given Vector2 (which is assumed to be
  /// relative to the origin) lies between the left and right and the top and
  /// bottom edges of this rectangle.
  ///
  /// Boxes include their top and left edges but exclude their bottom and
  /// right edges.
  bool contains(Vector2 vec) =>
      vec.x >= left && vec.x < right && vec.y >= top && vec.y < bottom;

  /// Constrains this box instance to the given [constraints].
  ///
  /// [constraints] the constraints to apply to this box.
  ///
  /// [returns] a new box instance.
  Box constrainBy(Constraints constraints) => constraints.constrainRect(this);

  /// Constrains the given [child] box instance within the bounds of this box.
  /// This function will preserve the sign of the child's width and height.
  /// It will also maintain the aspect ratio of the child if the [aspectRatio]
  /// is specified.
  ///
  /// [child] the child box to clamp inside this box.
  Box containOther(Box child) {
    final double xSign = child.width.sign;
    final double ySign = child.height.sign;
    final double childWidth = child.width.abs();
    final double childHeight = child.height.abs();

    final double x = math.max(left, child.left);
    final double y = math.max(top, child.top);
    final double clampedLeft = math.min(x, right - childWidth);
    final double clampedTop = math.min(y, bottom - childHeight);

    final double newLeft = math.max(left, clampedLeft);
    final double newTop = math.max(top, clampedTop);
    final double newWidth = math.min(width, childWidth);
    final double newHeight = math.min(height, childHeight);

    return Box.fromLTWH(
      newLeft,
      newTop,
      newWidth * xSign,
      newHeight * ySign,
    );
  }

  /// Returns a new box with all the values ceiling rounded.
  Box ceil() => Box.fromLTRB(
        left.ceilToDouble(),
        top.ceilToDouble(),
        right.ceilToDouble(),
        bottom.ceilToDouble(),
      );

  /// Returns a new box with all the values floor rounded.
  Box floor() => Box.fromLTRB(
        left.floorToDouble(),
        top.floorToDouble(),
        right.floorToDouble(),
        bottom.floorToDouble(),
      );

  /// Returns the relevant corner of this [Box] based on the given [quadrant].
  Vector2 pointFromQuadrant(Quadrant quadrant) => switch (quadrant) {
        Quadrant.topLeft => topLeft,
        Quadrant.topRight => topRight,
        Quadrant.bottomRight => bottomRight,
        Quadrant.bottomLeft => bottomLeft,
      };

  /// Returns a value that represents the distances of the passed
  /// [point] relative to the closest edge of this [Box]. If the point is
  /// inside the box, the distance will be positive. If the point is outside
  /// the box, the distance will be negative.
  ///
  /// Returns the [side] that the point is closest to and the [distance] to that
  /// side.
  (Side side, double distance) closestSideTo(Vector2 point) {
    final double left = point.x - this.left;
    final double right = this.right - point.x;
    final double top = point.y - this.top;
    final double bottom = this.bottom - point.y;

    final double min = math.min(left, math.min(right, math.min(top, bottom)));

    if (min == left) return (Side.left, left);
    if (min == right) return (Side.right, right);
    if (min == top) return (Side.top, top);
    return (Side.bottom, bottom);
  }

  /// Linearly interpolate between two rectangles.
  ///
  /// If either rect is null, [Box.zero] is used as a substitute.
  ///
  /// The `t` argument represents position on the timeline, with 0.0 meaning
  /// that the interpolation has not started, returning `a` (or something
  /// equivalent to `a`), 1.0 meaning that the interpolation has finished,
  /// returning `b` (or something equivalent to `b`), and values in between
  /// meaning that the interpolation is at the relevant point on the timeline
  /// between `a` and `b`. The interpolation can be extrapolated beyond 0.0 and
  /// 1.0, so negative values and values greater than 1.0 are valid (and can
  /// easily be generated by curves such as [Curves.elasticInOut]).
  ///
  /// Values for `t` are usually obtained from an [Animation<double>], such as
  /// an [AnimationController].
  static Box? lerp(Box? a, Box? b, double t) {
    if (b == null) {
      if (a == null) {
        return null;
      } else {
        final double k = 1.0 - t;
        return Box.fromLTRB(a.left * k, a.top * k, a.right * k, a.bottom * k);
      }
    } else {
      if (a == null) {
        return Box.fromLTRB(b.left * t, b.top * t, b.right * t, b.bottom * t);
      } else {
        return Box.fromLTRB(
          _lerpDouble(a.left, b.left, t),
          _lerpDouble(a.top, b.top, t),
          _lerpDouble(a.right, b.right, t),
          _lerpDouble(a.bottom, b.bottom, t),
        );
      }
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    return other is Box &&
        other.left == left &&
        other.top == top &&
        other.right == right &&
        other.bottom == bottom;
  }

  @override
  int get hashCode => Object.hash(left, top, right, bottom);

  @override
  String toString() =>
      'Box.fromLTWH(${left.toStringAsFixed(1)}, ${top.toStringAsFixed(1)}, ${width.toStringAsFixed(1)}, ${height.toStringAsFixed(1)})';
}
