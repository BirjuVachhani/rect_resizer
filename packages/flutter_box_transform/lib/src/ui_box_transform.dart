import 'dart:ui' as ui;

import 'package:box_transform/box_transform.dart' as transform;
import 'package:flutter/rendering.dart' as widgets;

import '../flutter_box_transform.dart';

/// A Flutter translation of [transform.BoxTransformer].
class UIBoxTransform {
  /// A private constructor to prevent instantiation.
  const UIBoxTransform._();

  /// The Flutter wrapper for [transform.BoxTransformer.resize].
  static UIResizeResult resize({
    required ui.Rect initialRect,
    required ui.Offset initialLocalPosition,
    required ui.Offset localPosition,
    required double rotation,
    required transform.HandlePosition handle,
    required transform.ResizeMode resizeMode,
    required transform.Flip initialFlip,
    ui.Rect clampingRect = ui.Rect.largest,
    widgets.BoxConstraints constraints = const widgets.BoxConstraints(),
    bool allowFlipping = true,
    BindingStrategy bindingStrategy = BindingStrategy.boundingBox,
  }) =>
      transform.BoxTransformer.resize(
        initialRect: initialRect.toBox(),
        initialLocalPosition: initialLocalPosition.toVector2(),
        localPosition: localPosition.toVector2(),
        rotation: rotation,
        handle: handle,
        resizeMode: resizeMode,
        initialFlip: initialFlip,
        clampingRect: clampingRect.toBox(),
        constraints: constraints.toConstraints(),
        allowFlipping: allowFlipping,
        bindingStrategy: bindingStrategy,
      ).toUI();

  /// The Flutter wrapper for [transform.BoxTransformer.move].
  static UIMoveResult move({
    required ui.Rect initialRect,
    required ui.Offset initialLocalPosition,
    required ui.Offset localPosition,
    required double rotation,
    ui.Rect clampingRect = ui.Rect.largest,
    BindingStrategy bindingStrategy = BindingStrategy.boundingBox,
  }) =>
      transform.BoxTransformer.move(
        initialRect: initialRect.toBox(),
        initialLocalPosition: initialLocalPosition.toVector2(),
        localPosition: localPosition.toVector2(),
        rotation: rotation,
        clampingRect: clampingRect.toBox(),
        bindingStrategy: bindingStrategy,
      ).toUI();

  /// The Flutter wrapper for [transform.BoxTransformer.rotate].
  static UIRotateResult rotate({
    required ui.Rect rect,
    required ui.Offset initialLocalPosition,
    required ui.Offset localPosition,
    required double initialRotation,
    ui.Rect clampingRect = ui.Rect.largest,
    BindingStrategy bindingStrategy = BindingStrategy.boundingBox,
  }) =>
      transform.BoxTransformer.rotate(
        rect: rect.toBox(),
        initialLocalPosition: initialLocalPosition.toVector2(),
        localPosition: localPosition.toVector2(),
        clampingRect: clampingRect.toBox(),
        bindingStrategy: bindingStrategy,
        initialRotation: initialRotation,
      ).toUI();
}
