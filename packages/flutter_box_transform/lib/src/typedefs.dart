import 'package:box_transform/box_transform.dart';
import 'package:flutter/widgets.dart';

import 'ui_result.dart';

typedef GestureRotationStartCallback = GestureDragStartCallback;
typedef GestureRotationUpdateCallback = GestureDragUpdateCallback;
typedef GestureRotationEndCallback = GestureDragEndCallback;
typedef GestureRotationCancelCallback = GestureDragCancelCallback;

/// A callback that expects a [Widget] that represents any of the handles.
/// The [handle] is the current position and size of the handle.
typedef HandleBuilder = Widget Function(
  BuildContext context,
  HandlePosition handle,
);

/// A callback that expects a [Widget] that represents the content of the box.
/// The [rect] is the current position and size of the box.
/// The [flip] is the current flip state of the box.
typedef TransformableChildBuilder = Widget Function(
  BuildContext context,
  Rect rect,
  Flip flip,
);

/// A callback that is called when the box is moved or resized.
typedef RectChangeEvent = void Function(
  UITransformResult result,
  DragUpdateDetails event,
);

/// A callback that is called when the box begins a drag operation.
typedef RectDragStartEvent = void Function(
  DragStartDetails event,
);

/// A callback that is called when the box is being dragged.
typedef RectDragUpdateEvent = void Function(
  UIMoveResult result,
  DragUpdateDetails event,
);

/// A callback that is called when the box ends a drag operation.
typedef RectDragEndEvent = void Function(
  DragEndDetails event,
);

/// A callback that is called when the box cancels a drag operation.
typedef RectDragCancelEvent = void Function();

/// A callback that is called when the box begins a resize operation.
typedef RectResizeStartEvent = void Function(
  HandlePosition handle,
  DragStartDetails event,
);

/// A callback that is called when the box is being resized.
typedef RectResizeUpdateEvent = void Function(
  UIResizeResult result,
  DragUpdateDetails event,
);

/// A callback that is called when the box ends a resize operation.
typedef RectResizeEndEvent = void Function(
  HandlePosition handle,
  DragEndDetails event,
);

/// A callback that is called when the box cancels a resize operation.
typedef RectResizeCancelEvent = void Function(
  HandlePosition handle,
);

/// A callback that is called when the box begins a rotation operation.
typedef RectRotateStartEvent = void Function(
  HandlePosition handle,
  DragStartDetails event,
);

/// A callback that is called when the box is being rotated.
typedef RectRotateUpdateEvent = void Function(
  UIRotateResult result,
  DragUpdateDetails event,
);

/// A callback that is called when the box ends a rotation operation.
typedef RectRotateEndEvent = void Function(
  HandlePosition handle,
  DragEndDetails event,
);

/// A callback that is called when the box cancels a rotation operation.
typedef RectRotateCancelEvent = void Function(
  HandlePosition handle,
);

/// A callback that is called when the box reaches a terminal edge when
/// resizing.
typedef TerminalEdgeEvent = void Function(
  bool reached,
);

/// A callback that is called when the box reaches a minimum or maximum size
/// when resizing a specific axis.
typedef TerminalAxisEvent = void Function(
  bool reachedMin,
  bool reachedMax,
);

/// A callback that is called when the box reaches a minimum or maximum size
/// when resizing.
typedef TerminalEvent = void Function(
  bool reachedMinWidth,
  bool reachedMaxWidth,
  bool reachedMinHeight,
  bool reachedMaxHeight,
);
