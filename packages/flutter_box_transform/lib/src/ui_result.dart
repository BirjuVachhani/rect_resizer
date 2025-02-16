import 'dart:ui';

import 'package:box_transform/box_transform.dart';

/// A convenient type alias for a [ResizeResult] with Flutter's [Rect], [Offset]
/// and [Size] types.
typedef UIMoveResult = MoveResult<Rect, Offset, Size>;

/// A convenient type alias for a [MoveResult] with Flutter's [Rect], [Offset]
/// and [Size] types.
typedef UIResizeResult = ResizeResult<Rect, Offset, Size>;

/// A convenient type alias for a [TransformResult] with Flutter's [Rect],
/// [Offset] and [Size] types.
typedef UITransformResult = TransformResult<Rect, Offset, Size>;

/// A convenient type alias for a [RotateResult] with Flutter's [Rect], [Offset]
/// and [Size] types.
typedef UIRotateResult = RotateResult<Rect, Offset, Size>;
