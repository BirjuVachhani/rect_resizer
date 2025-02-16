import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../flutter_box_transform.dart';

/// Default [ResizeModeResolver] implementation. This implementation
/// doesn't rely on the focus system .It resolves the [ResizeMode] based on
/// the pressed keys on the keyboard from the
/// [WidgetsBinding.keyboard.logicalKeysPressed] hence it only works on
/// hardware keyboards.
///
/// If you want to use it on soft keyboards, you can
/// implement your own [ResizeModeResolver] and pass it to the
/// [TransformableBoxController] constructor.
ResizeMode defaultResizeModeResolver() {
  final pressedKeys = WidgetsBinding.instance.keyboard.logicalKeysPressed;

  final isAltPressed = pressedKeys.contains(LogicalKeyboardKey.altLeft) ||
      pressedKeys.contains(LogicalKeyboardKey.altRight);

  final isShiftPressed = pressedKeys.contains(LogicalKeyboardKey.shiftLeft) ||
      pressedKeys.contains(LogicalKeyboardKey.shiftRight);

  if (isAltPressed && isShiftPressed) {
    return ResizeMode.symmetricScale;
  } else if (isAltPressed) {
    return ResizeMode.symmetric;
  } else if (isShiftPressed) {
    return ResizeMode.scale;
  } else {
    return ResizeMode.freeform;
  }
}

/// A controller class that is used to control the [TransformableBox] widget.
class TransformableBoxController extends ChangeNotifier {
  /// Creates a [TransformableBoxController] instance.
  TransformableBoxController({
    Rect? rect,
    Flip? flip,
    Rect? clampingRect,
    BoxConstraints? constraints,
    double? rotation,
    ValueGetter<ResizeMode>? resizeModeResolver,
    bool allowFlippingWhileResizing = true,
    BindingStrategy bindingStrategy = BindingStrategy.boundingBox,
  })  : _rect = rect ?? Rect.zero,
        _flip = flip ?? Flip.none,
        _clampingRect = clampingRect ?? Rect.largest,
        _constraints = constraints ?? const BoxConstraints(),
        _rotation = rotation ?? 0.0,
        _resizeModeResolver = resizeModeResolver ?? defaultResizeModeResolver,
        _allowFlippingWhileResizing = allowFlippingWhileResizing,
        _bindingStrategy = bindingStrategy {
    _boundingRect = BoxTransformer.calculateBoundingRect(
      rotation: _rotation,
      unrotatedBox: _rect.toBox(),
    ).toRect();
  }

  /// The callback function that is used to resolve the [ResizeMode] based on
  /// the pressed keys on the keyboard.
  ValueGetter<ResizeMode> _resizeModeResolver;

  /// The callback function that is used to resolve the [ResizeMode] based on
  /// the pressed keys on the keyboard.
  ValueGetter<ResizeMode> get resizeModeResolver => _resizeModeResolver;

  /// The current [Rect] of the [TransformableBox].
  Rect _rect = Rect.zero;

  /// The current [Rect] of the [TransformableBox].
  Rect get rect => _rect;

  Rect _boundingRect = Rect.zero;

  /// The current bounding [Rect] of the [TransformableBox] that contains
  /// all 4 vertices of the box, even when rotated.
  Rect get boundingRect => _boundingRect;

  double _initialRotation = 0.0;

  /// The initial [rotation] of the [TransformableBox] when the resizing starts.
  double get initialRotation => _initialRotation;

  double _rotation = 0.0;

  /// The current [rotation] of the [TransformableBox].
  double get rotation => _rotation;

  BindingStrategy _bindingStrategy = BindingStrategy.boundingBox;

  /// The current [BindingStrategy] of the [TransformableBox].
  BindingStrategy get bindingStrategy => _bindingStrategy;

  /// The current [Flip] of the [TransformableBox].
  Flip _flip = Flip.none;

  /// The current [Flip] of the [TransformableBox].
  Flip get flip => _flip;

  /// The initial [Offset] of the [TransformableBox] when the resizing starts.
  Offset _initialLocalPosition = Offset.zero;

  /// The initial [Offset] of the [TransformableBox] when the resizing starts.
  Offset get initialLocalPosition => _initialLocalPosition;

  /// The initial [Rect] of the [TransformableBox] when the resizing starts.
  Rect _initialRect = Rect.zero;

  /// The initial [Rect] of the [TransformableBox] when the resizing starts.
  Rect get initialRect => _initialRect;

  /// The initial [Flip] of the [TransformableBox] when the resizing starts.
  Flip _initialFlip = Flip.none;

  /// The initial [Flip] of the [TransformableBox] when the resizing starts.
  Flip get initialFlip => _initialFlip;

  /// The box that limits the dragging and resizing of the [TransformableBox] inside
  /// its bounds.
  Rect _clampingRect = Rect.largest;

  /// The box that limits the dragging and resizing of the [TransformableBox] inside
  /// its bounds.
  Rect get clampingRect => _clampingRect;

  /// Whether to allow flipping of the box while resizing. If this is set to
  /// true, the box will flip when the user drags the handles to opposite
  /// corners of the rect.
  bool _allowFlippingWhileResizing = false;

  /// Whether to allow flipping of the box while resizing. If this is set to
  /// true, the box will flip when the user drags the handles to opposite
  /// corners of the rect.
  bool get allowFlippingWhileResizing => _allowFlippingWhileResizing;

  /// The constraints that limits the resizing of the [TransformableBox] inside its
  /// bounds.
  BoxConstraints _constraints = const BoxConstraints.expand();

  /// The constraints that limits the resizing of the [TransformableBox] inside its
  /// bounds.
  BoxConstraints get constraints => _constraints;

  /// Sets the current [resizeModeResolver] of the [TransformableBox].
  void setResizeModeResolver(
    ValueGetter<ResizeMode> resizeModeResolver, {
    bool notify = true,
  }) {
    _resizeModeResolver = resizeModeResolver;

    if (notify) notifyListeners();
  }

  /// Sets the current [rect] of the [TransformableBox].
  void setRect(
    Rect rect, {
    bool notify = true,
    bool recalculate = true,
  }) {
    _rect = rect;

    if (recalculate) {
      this.recalculate(notify: false);
    }

    if (notify) notifyListeners();
  }

  /// Sets the current [flip] of the [TransformableBox].
  void setFlip(Flip flip, {bool notify = true}) {
    _flip = flip;

    if (notify) notifyListeners();
  }

  /// Sets the initial local position of the [TransformableBox].
  void setInitialLocalPosition(Offset initialLocalPosition,
      {bool notify = true}) {
    _initialLocalPosition = initialLocalPosition;

    if (notify) notifyListeners();
  }

  /// Sets the initial [rotation] of the [TransformableBox].
  void setInitialRotation(double initialRotation, {bool notify = true}) {
    _initialRotation = initialRotation;

    if (notify) notifyListeners();
  }

  /// Sets the initial [Rect] of the [TransformableBox].
  void setInitialRect(Rect initialRect, {bool notify = true}) {
    _initialRect = initialRect;

    if (notify) notifyListeners();
  }

  /// Sets the initial [Flip] of the [TransformableBox].
  void setInitialFlip(Flip initialFlip, {bool notify = true}) {
    _initialFlip = initialFlip;

    if (notify) notifyListeners();
  }

  /// Sets the current [clampingRect] of the [TransformableBox].
  void setClampingRect(
    Rect clampingRect, {
    bool notify = true,
    bool recalculate = true,
  }) {
    _clampingRect = clampingRect;

    if (recalculate) {
      this.recalculate(notify: false);
    }

    if (notify) notifyListeners();
  }

  /// Sets the current [constraints] of the [TransformableBox].
  void setConstraints(BoxConstraints constraints, {bool notify = true}) {
    _constraints = constraints;

    if (notify) notifyListeners();
  }

  /// Sets the current [rotation] of the [TransformableBox].
  void setRotation(double rotation, {bool notify = true}) {
    _rotation = rotation;

    if (notify) notifyListeners();
  }

  /// Sets the current [bindingStrategy] of the [TransformableBox].
  void setBindingStrategy(BindingStrategy bindingStrategy,
      {bool notify = true}) {
    _bindingStrategy = bindingStrategy;

    if (notify) notifyListeners();
  }

  /// Whether to allow flipping of the box while resizing. If this is set to
  /// true, the box will flip when the user drags the handles to opposite
  /// corners of the rect.
  void setAllowFlippingWhileResizing(bool allowFlippingWhileResizing,
      {bool notify = true}) {
    _allowFlippingWhileResizing = allowFlippingWhileResizing;

    if (notify) notifyListeners();
  }

  /// Called when dragging of the [TransformableBox] starts.
  ///
  /// [localPosition] is the position of the pointer relative to the
  ///               [TransformableBox] when the dragging starts.
  void onDragStart(Offset localPosition) {
    _initialLocalPosition = localPosition;
    _initialRect = rect;
  }

  /// Called when the [TransformableBox] is dragged.
  ///
  /// [localPosition] is the position of the pointer relative to the
  ///                [TransformableBox].
  ///
  /// [notify] is a boolean value that determines whether to notify the
  ///          listeners or not. It is set to `true` by default.
  ///          If you want to update the [TransformableBox] without notifying
  ///          the listeners, you can set it to `false`.
  UIMoveResult onDragUpdate(
    Offset localPosition, {
    bool notify = true,
  }) {
    final UIMoveResult result = UIBoxTransform.move(
      initialRect: initialRect,
      initialLocalPosition: initialLocalPosition,
      localPosition: localPosition,
      clampingRect: clampingRect,
      rotation: rotation,
      bindingStrategy: bindingStrategy,
    );

    _rect = result.rect;
    _boundingRect = result.boundingRect;

    if (notify) notifyListeners();

    return result;
  }

  /// Called when the dragging of the [TransformableBox] ends.
  void onDragEnd({bool notify = true}) {
    _initialLocalPosition = Offset.zero;
    _initialRect = Rect.zero;

    if (notify) notifyListeners();
  }

  /// Called when the dragging of the [TransformableBox] is cancelled.
  void onDragCancel({bool notify = true}) => onDragEnd(notify: notify);

  /// Called when the rotation of the [TransformableBox] starts.
  void onRotateStart(Offset localPosition) {
    _initialLocalPosition = localPosition;
    _initialRect = rect;
    _initialRotation = rotation;
  }

  /// Called when the [TransformableBox] is being rotated.
  UIRotateResult onRotateUpdate(
    Offset localPosition,
    HandlePosition handle, {
    bool notify = true,
  }) {
    final UIRotateResult result = UIBoxTransform.rotate(
      rect: initialRect,
      initialLocalPosition: initialLocalPosition,
      initialRotation: initialRotation,
      localPosition: localPosition,
      clampingRect: clampingRect,
      bindingStrategy: bindingStrategy,
    );

    _rotation = result.rotation;
    _boundingRect = result.boundingRect;

    if (notify) notifyListeners();

    return result;
  }

  /// Called when the rotation of the [TransformableBox] ends.
  void onRotateEnd({bool notify = true}) {
    _initialLocalPosition = Offset.zero;
    _initialRect = Rect.zero;
    _initialRotation = 0.0;

    if (notify) notifyListeners();
  }

  /// Called when the rotation of the [TransformableBox] is cancelled.
  void onRotateCancel({bool notify = true}) => onRotateEnd(notify: notify);

  /// Called when the resizing starts on [TransformableBox].
  ///
  /// [localPosition] is the position of the pointer relative to the
  ///               [TransformableBox] when the resizing starts.
  void onResizeStart(Offset localPosition) {
    _initialLocalPosition = localPosition;
    _initialRect = rect;
    _initialFlip = flip;
  }

  /// Called when the [TransformableBox] is being resized.
  ///
  /// [localPosition] is the position of the pointer relative to the
  /// [TransformableBox] when the resizing starts.
  /// It is used to calculate the new [Rect] of the [TransformableBox].
  ///
  /// [handle] is the handle that is being dragged.
  ///
  /// [notify] is a boolean value that determines whether to notify the
  /// listeners or not. It is set to `true` by default.
  ///
  /// [resizeModeResolver] is a callback function that is used to resolve the
  /// [ResizeMode] based on the pressed keys on the keyboard. It can be
  /// optionally passed to override the default [resizeModeResolver] of this
  /// [TransformableBoxController].
  UIResizeResult onResizeUpdate(
    Offset localPosition,
    HandlePosition handle, {
    bool notify = true,
    ValueGetter<ResizeMode>? resizeModeResolver,
  }) {
    // Calculate the new rect based on the initial rect, initial local position,
    final UIResizeResult result = UIBoxTransform.resize(
      localPosition: localPosition,
      handle: handle,
      initialRect: initialRect,
      initialLocalPosition: initialLocalPosition,
      rotation: rotation,
      resizeMode: resizeModeResolver?.call() ?? this.resizeModeResolver(),
      initialFlip: initialFlip,
      clampingRect: clampingRect,
      constraints: constraints,
      allowFlipping: allowFlippingWhileResizing,
      bindingStrategy: bindingStrategy,
    );

    _rect = result.rect;
    _flip = result.flip;
    _boundingRect = result.boundingRect;

    if (notify) notifyListeners();
    return result;
  }

  /// Called when the resizing ends on [TransformableBox].
  void onResizeEnd({bool notify = true}) {
    _initialLocalPosition = Offset.zero;
    _initialRect = Rect.zero;
    _initialFlip = Flip.none;

    if (notify) notifyListeners();
  }

  /// Called when the resizing of the [TransformableBox] is cancelled.
  void onResizeCancel({bool notify = true}) => onResizeEnd(notify: notify);

  /// Recalculates the current state of this [rect] to ensure the position is
  /// correct in case of extreme jumps of the [TransformableBox].
  void recalculatePosition({bool notify = true}) {
    final UIMoveResult result = UIBoxTransform.move(
      initialRect: rect,
      initialLocalPosition: initialLocalPosition,
      localPosition: initialLocalPosition,
      clampingRect: clampingRect,
      rotation: rotation,
      bindingStrategy: bindingStrategy,
    );

    _rect = result.rect;
    _boundingRect = result.boundingRect;

    if (notify) notifyListeners();
  }

  /// Recalculates the current state of this [rect] to ensure the position is
  /// correct in case of extreme jumps of the [TransformableBox].
  void recalculateSize({bool notify = true}) {
    final UIResizeResult result = UIBoxTransform.resize(
      initialRect: rect,
      initialLocalPosition: initialLocalPosition,
      localPosition: initialLocalPosition,
      clampingRect: clampingRect,
      rotation: rotation,
      handle: HandlePosition.bottomRight,
      resizeMode: ResizeMode.freeform,
      initialFlip: initialFlip,
      constraints: constraints,
      allowFlipping: allowFlippingWhileResizing,
      bindingStrategy: bindingStrategy,
    );

    _rect = result.rect;
    _boundingRect = result.boundingRect;

    if (notify) notifyListeners();
  }

  /// Recalculates the current state of this [rect] to ensure the position and
  /// size are correct in case of extreme jumps of the [TransformableBox].
  /// This is a combination of [recalculatePosition] and [recalculateSize] for
  /// convenience.
  void recalculate({bool notify = true}) {
    recalculatePosition(notify: false);
    recalculateSize(notify: false);

    if (notify) notifyListeners();
  }

  /// Notifies the listeners of this [ChangeNotifier].
  void notify() {
    notifyListeners();
  }
}
