import 'package:box_transform/box_transform.dart';
import 'package:test/test.dart';
import 'package:vector_math/vector_math.dart';

void main() {
  test('RawTransformResult extension tests', () {
    final result = RawTransformResult(
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

    expect(result.size, result.rect.size);
    expect(result.position, result.rect.topLeft);
    expect(result.oldSize, result.oldRect.size);
    expect(result.oldPosition, result.oldRect.topLeft);
  });
}
