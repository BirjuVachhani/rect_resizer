import 'package:box_transform/box_transform.dart';
import 'package:test/test.dart';
import 'package:vector_math/vector_math.dart';

void main() {
  test('RawTransformResult equality tests', () {
    final result1 = RawTransformResult(
      rect: Box.fromLTRB(100, 100, 500, 400),
      boundingRect: Box.fromLTRB(100, 100, 500, 400),
      handle: HandlePosition.bottomRight,
      flip: Flip.none,
      maxHeightReached: false,
      maxWidthReached: false,
      minHeightReached: false,
      minWidthReached: false,
      oldRect: Box.fromLTRB(100, 100, 300, 200),
      oldBoundingRect: Box.fromLTRB(100, 100, 300, 200),
      resizeMode: ResizeMode.freeform,
      largestRect: Box.fromLTRB(100, 100, 1000, 1000),
      rawSize: Dimension(400, 300),
      delta: Vector2(200, 200),
      rotation: 0,
    );

    final result2 = RawTransformResult(
      rect: Box.fromLTRB(100, 100, 500, 400),
      boundingRect: Box.fromLTRB(100, 100, 500, 400),
      handle: HandlePosition.bottomRight,
      flip: Flip.none,
      maxHeightReached: false,
      maxWidthReached: false,
      minHeightReached: false,
      minWidthReached: false,
      oldRect: Box.fromLTRB(100, 100, 300, 200),
      oldBoundingRect: Box.fromLTRB(100, 100, 300, 200),
      resizeMode: ResizeMode.freeform,
      largestRect: Box.fromLTRB(100, 100, 1000, 1000),
      rawSize: Dimension(400, 300),
      delta: Vector2(200, 200),
      rotation: 0,
    );

    expect(result1, result2);
    expect(result1.toString(), result2.toString());
    expect(result1.hashCode, result2.hashCode);
    expect(result1 == result2, isTrue);
  });

  test('RawResizeResult equality tests', () {
    final result1 = RawResizeResult(
      rect: Box.fromLTRB(100, 100, 500, 400),
      boundingRect: Box.fromLTRB(100, 100, 500, 400),
      handle: HandlePosition.bottomRight,
      flip: Flip.none,
      maxHeightReached: false,
      maxWidthReached: false,
      minHeightReached: false,
      minWidthReached: false,
      oldRect: Box.fromLTRB(100, 100, 300, 200),
      oldBoundingRect: Box.fromLTRB(100, 100, 300, 200),
      resizeMode: ResizeMode.freeform,
      largestRect: Box.fromLTRB(100, 100, 1000, 1000),
      rawSize: Dimension(400, 300),
      delta: Vector2(200, 200),
    );

    final result2 = RawResizeResult(
      rect: Box.fromLTRB(100, 100, 500, 400),
      boundingRect: Box.fromLTRB(100, 100, 500, 400),
      handle: HandlePosition.bottomRight,
      flip: Flip.none,
      maxHeightReached: false,
      maxWidthReached: false,
      minHeightReached: false,
      minWidthReached: false,
      oldRect: Box.fromLTRB(100, 100, 300, 200),
      oldBoundingRect: Box.fromLTRB(100, 100, 300, 200),
      resizeMode: ResizeMode.freeform,
      largestRect: Box.fromLTRB(100, 100, 1000, 1000),
      rawSize: Dimension(400, 300),
      delta: Vector2(200, 200),
    );

    expect(result1, result2);
    expect(result1.toString(), result2.toString());
    expect(result1.hashCode, result2.hashCode);
    expect(result1 == result2, isTrue);
  });

  test('RawMoveResult equality tests', () {
    final result1 = RawMoveResult(
      rect: Box.fromLTRB(100, 100, 500, 400),
      boundingRect: Box.fromLTRB(100, 100, 500, 400),
      oldRect: Box.fromLTRB(100, 100, 300, 200),
      oldBoundingRect: Box.fromLTRB(100, 100, 300, 200),
      largestRect: Box.fromLTRB(100, 100, 1000, 1000),
      rawSize: Dimension(400, 300),
      delta: Vector2(200, 200),
    );

    final result2 = RawMoveResult(
      rect: Box.fromLTRB(100, 100, 500, 400),
      boundingRect: Box.fromLTRB(100, 100, 500, 400),
      oldRect: Box.fromLTRB(100, 100, 300, 200),
      oldBoundingRect: Box.fromLTRB(100, 100, 300, 200),
      largestRect: Box.fromLTRB(100, 100, 1000, 1000),
      rawSize: Dimension(400, 300),
      delta: Vector2(200, 200),
    );

    expect(result1, result2);
    expect(result1.toString(), result2.toString());
    expect(result1.hashCode, result2.hashCode);
    expect(result1 == result2, isTrue);
  });

  test('InternalResizeResult equality tests', () {
    final result1 = (
      Box.fromLTRB(100, 100, 500, 400),
      Box.fromLTRB(100, 100, 1000, 1000),
      true,
    );

    final result2 = (
      Box.fromLTRB(100, 100, 500, 400),
      Box.fromLTRB(100, 100, 1000, 1000),
      true,
    );

    expect(result1, result2);
    expect(result1.toString(), result2.toString());
    expect(result1.hashCode, result2.hashCode);
    expect(result1 == result2, isTrue);
  });
}
