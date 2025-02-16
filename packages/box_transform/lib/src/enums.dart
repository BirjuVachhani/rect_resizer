import 'package:vector_math/vector_math.dart';

import '../box_transform.dart';
import 'geometry.dart';

/// Represents a cardinal side of a quadrilateral.
enum Side {
  /// The top side of the rect.
  top,

  /// The right side of the rect.
  right,

  /// The bottom side of the rect.
  bottom,

  /// The left side of the rect.
  left;

  /// Whether the side is top or not.
  bool get isTop => this == Side.top;

  /// Whether the side is right or not.
  bool get isRight => this == Side.right;

  /// Whether the side is bottom or not.
  bool get isBottom => this == Side.bottom;

  /// Whether the side is left or not.
  bool get isLeft => this == Side.left;

  /// Returns the handle position of the side.
  HandlePosition get handlePosition => switch (this) {
        Side.top => HandlePosition.top,
        Side.right => HandlePosition.right,
        Side.bottom => HandlePosition.bottom,
        Side.left => HandlePosition.left,
      };

  /// Returns the opposite side of the given side.
  Side get opposite => switch (this) {
        Side.top => Side.bottom,
        Side.right => Side.left,
        Side.bottom => Side.top,
        Side.left => Side.right,
      };

  /// Returns the side that is clockwise to the given side.
  Side get clockWise => switch (this) {
        Side.top => Side.right,
        Side.right => Side.bottom,
        Side.bottom => Side.left,
        Side.left => Side.top,
      };

  /// Returns the side that is counter-clockwise to the given side.
  Side get counterClockWise => switch (this) {
        Side.top => Side.left,
        Side.right => Side.top,
        Side.bottom => Side.right,
        Side.left => Side.bottom,
      };

  /// Whether the side is horizontal or not.
  bool get isHorizontal => this == Side.left || this == Side.right;

  /// Whether the side is vertical or not.
  bool get isVertical => this == Side.top || this == Side.bottom;

  /// Returns the length of the [rect] along the side.
  double getLengthOf(Box rect) => switch (this) {
        Side.top || Side.bottom => rect.height,
        Side.left || Side.right => rect.width,
      };
}

/// Represents the different quadrants of a rectangle.
enum Quadrant {
  /// The top left quadrant.
  topLeft,

  /// The top right quadrant.
  topRight,

  /// The bottom left quadrant.
  bottomLeft,

  /// The bottom right quadrant.
  bottomRight,
}

/// Represents a resizing handle on corners.
enum HandlePosition {
  /// Represents no handle. An empty resize operation.
  none,

  /// Represents the left side of the rect.
  left,

  /// Represents the top side of the rect.
  top,

  /// Represents the right side of the rect.
  right,

  /// Represents the bottom side of the rect.
  bottom,

  /// Represents the top left corner of the rect.
  topLeft,

  /// Represents the top right corner of the rect.
  topRight,

  /// Represents the bottom left corner of the rect.
  bottomLeft,

  /// Represents the bottom right corner of the rect.
  bottomRight;

  /// Whether the handle is none or not.
  bool get isNone => this == HandlePosition.none;

  /// Whether the handle is on the left side of the rect.
  bool get influencesLeft =>
      this == topLeft || this == bottomLeft || this == left;

  /// Whether the handle is on the right side of the rect.
  bool get influencesRight =>
      this == topRight || this == bottomRight || this == right;

  /// Whether the handle is on the top side of the rect.
  bool get influencesTop => this == topLeft || this == topRight || this == top;

  /// Whether the handle is on the bottom side of the rect.
  bool get influencesBottom =>
      this == bottomLeft || this == bottomRight || this == bottom;

  /// Whether the handle is either on the left or top side of the rect.
  bool get influencesTopOrLeft =>
      this == topLeft || this == top || this == left;

  /// Whether the handle is either on the right or top side of the rect.
  bool get influencesTopOrRight =>
      this == topRight || this == top || this == right;

  /// Whether the handle is either on the left or bottom side of the rect.
  bool get influencesBottomOrLeft =>
      this == bottomLeft || this == bottom || this == left;

  /// Whether the handle is either on the right or bottom side of the rect.
  bool get influencesBottomOrRight =>
      this == bottomRight || this == bottom || this == right;

  /// Whether the handle is either on the left or right, or any diagonal side
  /// of the rect.
  bool get influencesHorizontal => isHorizontal || isDiagonal;

  /// Whether the handle is either on the top or bottom, or any diagonal side
  /// of the rect.
  bool get influencesVertical => isVertical || isDiagonal;

  /// Whether the handle is on the corner of the rect.
  bool get isDiagonal =>
      this == topLeft ||
      this == topRight ||
      this == bottomLeft ||
      this == bottomRight;

  /// Whether the handle is on the cardinal side of the rect.
  bool get isSide =>
      this == top || this == bottom || this == left || this == right;

  /// Whether the handle is horizontal or not.
  bool get isHorizontal => this == left || this == right;

  /// Whether the handle is vertical or not.
  bool get isVertical => this == top || this == bottom;

  /// Returns a list of all the handles that are on the corners of the rect.
  static const List<HandlePosition> corners = [
    HandlePosition.topLeft,
    HandlePosition.topRight,
    HandlePosition.bottomLeft,
    HandlePosition.bottomRight,
  ];

  /// Returns a list of all the handles that are on the sides of the rect.
  static const List<HandlePosition> sides = [
    HandlePosition.top,
    HandlePosition.bottom,
    HandlePosition.left,
    HandlePosition.right,
  ];

  /// returns the quadrant of a corner handle.
  Quadrant get quadrant => switch (this) {
        HandlePosition.topLeft => Quadrant.topLeft,
        HandlePosition.topRight => Quadrant.topRight,
        HandlePosition.bottomLeft => Quadrant.bottomLeft,
        HandlePosition.bottomRight => Quadrant.bottomRight,
        _ => throw Exception('Invalid handle position. Corners only.'),
      };

  /// Returns the opposite handle position on the horizontal axis.
  HandlePosition flipY() {
    switch (this) {
      case HandlePosition.top:
        return HandlePosition.bottom;
      case HandlePosition.bottom:
        return HandlePosition.top;
      case HandlePosition.topLeft:
        return HandlePosition.bottomLeft;
      case HandlePosition.topRight:
        return HandlePosition.bottomRight;
      case HandlePosition.bottomLeft:
        return HandlePosition.topLeft;
      case HandlePosition.bottomRight:
        return HandlePosition.topRight;
      default:
        return this;
    }
  }

  /// Returns the opposite handle position on the vertical axis.
  HandlePosition flipX() {
    switch (this) {
      case HandlePosition.left:
        return HandlePosition.right;
      case HandlePosition.right:
        return HandlePosition.left;
      case HandlePosition.topLeft:
        return HandlePosition.topRight;
      case HandlePosition.topRight:
        return HandlePosition.topLeft;
      case HandlePosition.bottomLeft:
        return HandlePosition.bottomRight;
      case HandlePosition.bottomRight:
        return HandlePosition.bottomLeft;
      default:
        return this;
    }
  }

  /// Returns the opposite handle position on the given [flip] state.
  HandlePosition flip(Flip flip) {
    switch (flip) {
      case Flip.none:
        return this;
      case Flip.horizontal:
        return flipX();
      case Flip.vertical:
        return flipY();
      case Flip.diagonal:
        return flipX().flipY();
    }
  }

  /// Gets the opposite handle position.
  HandlePosition get opposite {
    switch (this) {
      case HandlePosition.top:
        return HandlePosition.bottom;
      case HandlePosition.bottom:
        return HandlePosition.top;
      case HandlePosition.left:
        return HandlePosition.right;
      case HandlePosition.right:
        return HandlePosition.left;
      case HandlePosition.topLeft:
        return HandlePosition.bottomRight;
      case HandlePosition.topRight:
        return HandlePosition.bottomLeft;
      case HandlePosition.bottomLeft:
        return HandlePosition.topRight;
      case HandlePosition.bottomRight:
        return HandlePosition.topLeft;
      default:
        return this;
    }
  }

  /// Gets the anchor point for the handle. Anchor point is the point on the
  /// opposite handle.
  Vector2 anchor(Box rect) {
    switch (this) {
      case HandlePosition.topLeft:
        return rect.bottomRight;
      case HandlePosition.top:
        return rect.bottomCenter;
      case HandlePosition.topRight:
        return rect.bottomLeft;
      case HandlePosition.left:
        return rect.centerRight;
      case HandlePosition.right:
        return rect.centerLeft;
      case HandlePosition.bottomLeft:
        return rect.topRight;
      case HandlePosition.bottom:
        return rect.topCenter;
      case HandlePosition.bottomRight:
        return rect.topLeft;
      case HandlePosition.none:
        throw ArgumentError('HandlePosition.none is not supported!');
    }
  }

  /// Displayable representation of the [HandlePosition] value.
  String get prettify {
    switch (this) {
      case HandlePosition.topLeft:
        return 'Top Left';
      case HandlePosition.top:
        return 'Top';
      case HandlePosition.topRight:
        return 'Top Right';
      case HandlePosition.left:
        return 'Left';
      case HandlePosition.right:
        return 'Right';
      case HandlePosition.bottomLeft:
        return 'Bottom Left';
      case HandlePosition.bottom:
        return 'Bottom';
      case HandlePosition.bottomRight:
        return 'Bottom Right';
      case HandlePosition.none:
        return 'None';
    }
  }
}

/// Represents the flip state of a rectangle, or, in other words, if the
/// box is flipped horizontally, vertically, or diagonally.
enum Flip {
  /// No flipping, the rect stays as it is, not allowing any flipping.
  none,

  /// Flipped horizontally. When a rect is flipped on x-axis, the left side
  /// becomes right and vice versa.
  horizontal,

  /// Flipped vertically. When a rect is flipped on y-axis, the top side
  /// becomes bottom and vice versa.
  vertical,

  /// Flipped diagonally. When a rect is flipped on both axis, the top left
  /// becomes bottom right and vice versa.
  ///
  /// This flip is uniform, meaning that flipping top-left with bottom-right
  /// will result in the same rect as flipping bottom-left with top-right.
  diagonal;

  /// Creates a [Flip] from the given [horizontal] and [vertical] values.
  /// The values itself are not used, only their sign is used to determine
  /// the flip state.
  factory Flip.fromValue(num horizontal, num vertical) {
    if (horizontal.isNegative && vertical.isNegative) {
      return Flip.diagonal;
    } else if (horizontal.isNegative) {
      return Flip.horizontal;
    } else if (vertical.isNegative) {
      return Flip.vertical;
    } else {
      return Flip.none;
    }
  }

  /// Whether it is flipped or not.
  bool get isFlipped => this != Flip.none;

  /// Whether it is not flipped or is.
  bool get isNotFlipped => this == Flip.none;

  /// Whether the flip is horizontal.
  bool get isHorizontal => this == Flip.horizontal || this == Flip.diagonal;

  /// Whether the flip is vertical.
  bool get isVertical => this == Flip.vertical || this == Flip.diagonal;

  /// Whether the flip is diagonal.
  bool get isDiagonal => this == Flip.diagonal;

  /// Whether the flip is on x-axis, meaning that it is either horizontal
  /// or diagonal.
  bool get isFlippingOnX => this == Flip.horizontal || this == Flip.diagonal;

  /// Whether the flip is on y-axis, meaning that it is either vertical
  /// or diagonal.
  bool get isFlippingOnY => this == Flip.vertical || this == Flip.diagonal;

  /// The horizontal value of the flip. Negative if it is flipped horizontally,
  /// positive otherwise.
  double get horizontalValue => isHorizontal ? -1 : 1;

  /// The vertical value of the flip. Negative if it is flipped vertically,
  /// positive otherwise.
  double get verticalValue => isVertical ? -1 : 1;

  /// Creates a new [Flip] by combining this [Flip] with the given.
  /// See [influencedBy] for more details.
  operator *(Flip other) => influencedBy(other);

  /// Creates a new [Flip] by combining this [Flip] with the given
  /// [other] flip making the resulting flip influenced by [other].
  Flip influencedBy(Flip other) {
    if (other == Flip.none) return this;
    if (this == Flip.none) return other;
    return Flip.fromValue(
      horizontalValue * other.horizontalValue,
      verticalValue * other.verticalValue,
    );
  }

  /// Displayable representation of the [Flip] value.
  String get prettify {
    switch (this) {
      case Flip.none:
        return 'None';
      case Flip.horizontal:
        return 'Horizontal';
      case Flip.vertical:
        return 'Vertical';
      case Flip.diagonal:
        return 'Diagonal';
    }
  }
}

/// Represents different types resizing modes. These are used to determine
/// how the rect should be resized.
///
/// For example,
///
/// [ResizeMode.freeform] is the default mode where the rect can be resized
/// freely without any constraints.
///
/// [ResizeMode.symmetric] is like [ResizeMode.freeform] but it is symmetric
/// w.r.t the center. So if you resize the rect from right edge, it will also
/// resize from left edge. This is useful when you want to resize the rect
/// from the center.
///
/// [ResizeMode.scale] is like [ResizeMode.freeform] but it preserves
/// aspect ratio. So if you resize the rect from right edge, it will also
/// resize from left edge but the aspect ratio will be preserved.
///
/// [ResizeMode.symmetricScale] is like [ResizeMode.scale] but it is symmetric
/// w.r.t the center. So if you resize the rect from right edge, it will also
/// resize from left edge but the aspect ratio will be preserved.
///
/// See also:
/// * [ResizeMode.freeform]
/// * [ResizeMode.symmetric]
/// * [ResizeMode.scale]
/// * [ResizeMode.symmetricScale]
enum ResizeMode {
  /// Freeform resizing without any constraints.
  ///
  /// Usually with no modifier keys pressed.
  freeform,

  /// This is like [ResizeMode.freeform] Resizing w.r.t the center.
  ///
  /// This means moving right edge 10 pixels inwards will move left edge
  /// 10 pixels inwards as well. So if you reduce width 10 pixels from right
  /// edge, you will also reduce width 10 pixels from left edge reducing 20
  /// pixels effectively.
  ///
  /// Usually with ALT pressed.
  symmetric,

  /// This is like [ResizeMode.freeform] but preserves aspect ratio making
  /// it look like it is scaling up/down.
  ///
  /// Usually with SHIFT pressed.
  scale,

  /// This is like [ResizeMode.scale] but with rules of [ResizeMode.symmetric]
  /// applied. So it would scale up/down symmetrically w.r.t the center.
  ///
  /// This means moving bottom-right corner 10 pixels inwards will move top-left
  /// corner 10 pixels inwards as well while preserving aspect ratio. So if
  /// you reduce width 10 pixels from bottom-right corner, you will also reduce
  /// width 10 pixels from top-left corner reducing 20 pixels effectively.
  ///
  /// Usually with ALT + SHIFT pressed.
  symmetricScale;

  /// Whether the [ResizeMode] is [ResizeMode.freeform].
  bool get isFreeform => this == ResizeMode.freeform;

  /// Whether the [ResizeMode] is [ResizeMode.symmetric].
  bool get isSymmetric => this == ResizeMode.symmetric;

  /// Whether the [ResizeMode] is [ResizeMode.scale].
  bool get isScale => this == ResizeMode.scale;

  /// Whether the [ResizeMode] is [ResizeMode.symmetricScale].
  bool get isSymmetricScale => this == ResizeMode.symmetricScale;

  /// Whether the [ResizeMode] is scalable.
  /// i.e. [ResizeMode.scale] or [ResizeMode.symmetricScale].
  /// Used to determine whether the aspect ratio should be preserved.
  bool get isScalable => isScale || isSymmetricScale;

  /// Whether the [ResizeMode] is symmetric.
  /// i.e. [ResizeMode.symmetric] or [ResizeMode.symmetricScale].
  /// Used to determine whether the resize should be symmetric and
  /// w.r.t the center.
  bool get hasSymmetry => isSymmetric || isSymmetricScale;
}

/// An enum that defines how a box should be constrained and/or clamped when
/// undergoing a box transformation operation.
enum BindingStrategy {
  /// When a box transformation occurs, clamps and constraints are considered
  /// on the original unrotated dimensions of the box. Rotation is not
  /// considered with this strategy, and therefore, if a box is rotated,
  /// its vertices may leak out of its terminal dimensions and positions.
  originalBox,

  /// When a box transformation occurs, clamps and constraints are considered
  /// on the entire bounding box of the box. The bounding box is the smallest
  /// box that can contain all the vertices of its rotated box.
  ///
  /// This is the default strategy to ensure that the box does not
  /// leak out of its terminal dimensions and positions.
  boundingBox,
}
