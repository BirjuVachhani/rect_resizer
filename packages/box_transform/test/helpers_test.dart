import 'package:box_transform/box_transform.dart';
import 'package:test/test.dart';
import 'package:vector_math/vector_math.dart';

void main() {
  group('getLargestIntersectionDelta', () {
    test('no intersection', () {
      final rect = Box.fromLTRB(500, 500, 800, 800);
      final clampingRect = Box.fromLTRB(100, 100, 1100, 1100);

      final (:amount, :side, :singleIntersection) =
          getLargestIntersectionDelta(rect, clampingRect);

      expect(amount, 0);
      expect(side, Side.bottom);
      expect(singleIntersection, true);
    });

    test('bottom intersection', () {
      final rect = Box.fromLTRB(500, 500, 800, 1200);
      final clampingRect = Box.fromLTRB(100, 100, 1100, 1100);

      final (:amount, :side, :singleIntersection) =
          getLargestIntersectionDelta(rect, clampingRect);

      expect(amount, 100);
      expect(side, Side.bottom);
      expect(singleIntersection, true);
    });

    test('right intersection', () {
      final rect = Box.fromLTRB(500, 500, 1200, 800);
      final clampingRect = Box.fromLTRB(100, 100, 1100, 1100);

      final (:amount, :side, :singleIntersection) =
          getLargestIntersectionDelta(rect, clampingRect);

      expect(amount, 100);
      expect(side, Side.right);
      expect(singleIntersection, true);
    });

    test('top intersection', () {
      final rect = Box.fromLTRB(500, 0, 800, 800);
      final clampingRect = Box.fromLTRB(100, 100, 1100, 1100);

      final (:amount, :side, :singleIntersection) =
          getLargestIntersectionDelta(rect, clampingRect);

      expect(amount, 100);
      expect(side, Side.top);
      expect(singleIntersection, true);
    });

    test('left intersection', () {
      final rect = Box.fromLTRB(0, 500, 800, 800);
      final clampingRect = Box.fromLTRB(100, 100, 1100, 1100);

      final (:amount, :side, :singleIntersection) =
          getLargestIntersectionDelta(rect, clampingRect);

      expect(amount, 100);
      expect(side, Side.left);
      expect(singleIntersection, true);
    });

    test('top right intersection - top', () {
      final rect = Box.fromLTRB(-99, -100, 1200, 800);
      final clampingRect = Box.fromLTRB(100, 100, 1100, 1100);

      final (:amount, :side, :singleIntersection) =
          getLargestIntersectionDelta(rect, clampingRect);

      expect(amount, 200);
      expect(side, Side.top);
      expect(singleIntersection, false);
    });

    test('top right intersection - right', () {
      final rect = Box.fromLTRB(500, -99, 1300, 800);
      final clampingRect = Box.fromLTRB(100, 100, 1100, 1100);

      final (:amount, :side, :singleIntersection) =
          getLargestIntersectionDelta(rect, clampingRect);

      expect(amount, 200);
      expect(side, Side.right);
      expect(singleIntersection, false);
    });

    test('top left intersection - top', () {
      final rect = Box.fromLTRB(-99, -100, 800, 800);
      final clampingRect = Box.fromLTRB(100, 100, 1100, 1100);

      final (:amount, :side, :singleIntersection) =
          getLargestIntersectionDelta(rect, clampingRect);

      expect(amount, 200);
      expect(side, Side.top);
      expect(singleIntersection, false);
    });

    test('top left intersection - left', () {
      final rect = Box.fromLTRB(-100, -99, 800, 800);
      final clampingRect = Box.fromLTRB(100, 100, 1100, 1100);

      final (:amount, :side, :singleIntersection) =
          getLargestIntersectionDelta(rect, clampingRect);

      expect(amount, 200);
      expect(side, Side.left);
      expect(singleIntersection, false);
    });

    test('bottom right intersection - bottom', () {
      final rect = Box.fromLTRB(500, 500, 1299, 1300);
      final clampingRect = Box.fromLTRB(100, 100, 1100, 1100);

      final (:amount, :side, :singleIntersection) =
          getLargestIntersectionDelta(rect, clampingRect);

      expect(amount, 200);
      expect(side, Side.bottom);
      expect(singleIntersection, false);
    });

    test('bottom right intersection - right', () {
      final rect = Box.fromLTRB(500, 500, 1300, 1299);
      final clampingRect = Box.fromLTRB(100, 100, 1100, 1100);

      final (:amount, :side, :singleIntersection) =
          getLargestIntersectionDelta(rect, clampingRect);

      expect(amount, 200);
      expect(side, Side.right);
      expect(singleIntersection, false);
    });

    test('bottom left intersection - bottom', () {
      final rect = Box.fromLTRB(-99, 500, 800, 1300);
      final clampingRect = Box.fromLTRB(100, 100, 1100, 1100);

      final (:amount, :side, :singleIntersection) =
          getLargestIntersectionDelta(rect, clampingRect);

      expect(amount, 200);
      expect(side, Side.bottom);
      expect(singleIntersection, false);
    });

    test('bottom left intersection - left', () {
      final rect = Box.fromLTRB(-100, 500, 800, 1299);
      final clampingRect = Box.fromLTRB(100, 100, 1100, 1100);

      final (:amount, :side, :singleIntersection) =
          getLargestIntersectionDelta(rect, clampingRect);

      expect(amount, 200);
      expect(side, Side.left);
      expect(singleIntersection, false);
    });
  });

  group('stopRectAtClampingRect', () {
    test('no intersection', () {
      final rect = Box.fromLTRB(500, 500, 800, 800);
      final clampingRect = Box.fromLTRB(100, 100, 1100, 1100);

      final correctiveDelta = BoxTransformer.stopRectAtClampingRect(
        rect: rect,
        clampingRect: clampingRect,
        rotation: 0,
      );

      expect(correctiveDelta, Vector2.zero());
    });

    test('bottom intersection', () {
      final rect = Box.fromLTRB(500, 500, 800, 1200);
      final clampingRect = Box.fromLTRB(100, 100, 1100, 1100);

      final correctiveDelta = BoxTransformer.stopRectAtClampingRect(
        rect: rect,
        clampingRect: clampingRect,
        rotation: 0,
      );

      expect(correctiveDelta, Vector2(0, -100));
    });

    test('right intersection', () {
      final rect = Box.fromLTRB(500, 500, 1200, 800);
      final clampingRect = Box.fromLTRB(100, 100, 1100, 1100);

      final correctiveDelta = BoxTransformer.stopRectAtClampingRect(
        rect: rect,
        clampingRect: clampingRect,
        rotation: 0,
      );

      expect(correctiveDelta, Vector2(-100, 0));
    });

    test('top intersection', () {
      final rect = Box.fromLTRB(500, 0, 800, 800);
      final clampingRect = Box.fromLTRB(100, 100, 1100, 1100);

      final correctiveDelta = BoxTransformer.stopRectAtClampingRect(
        rect: rect,
        clampingRect: clampingRect,
        rotation: 0,
      );

      expect(correctiveDelta, Vector2(0, 100));
    });

    test('left intersection', () {
      final rect = Box.fromLTRB(0, 500, 800, 800);
      final clampingRect = Box.fromLTRB(100, 100, 1100, 1100);

      final correctiveDelta = BoxTransformer.stopRectAtClampingRect(
        rect: rect,
        clampingRect: clampingRect,
        rotation: 0,
      );

      expect(correctiveDelta, Vector2(100, 0));
    });

    test('top right intersection - top', () {
      final rect = Box.fromLTRB(500, -100, 1150, 800);
      final clampingRect = Box.fromLTRB(100, 100, 1100, 1100);

      final correctiveDelta = BoxTransformer.stopRectAtClampingRect(
        rect: rect,
        clampingRect: clampingRect,
        rotation: 0,
      );

      expect(correctiveDelta, Vector2(-50, 200));
    });

    test('top right intersection - right', () {
      final rect = Box.fromLTRB(500, -50, 1300, 800); // 0.727272 * 800 =581.8176
      final clampingRect = Box.fromLTRB(100, 100, 1100, 1100);

      final correctiveDelta = BoxTransformer.stopRectAtClampingRect(
        rect: rect,
        clampingRect: clampingRect,
        rotation: 0,
      );

      expect(correctiveDelta, Vector2(-200, 150));
    });

    test('bottom right intersection - bottom', () {
      final rect = Box.fromLTRB(500, 500, 1300, 1200);
      final clampingRect = Box.fromLTRB(100, 100, 1100, 1100);

      final correctiveDelta = BoxTransformer.stopRectAtClampingRect(
        rect: rect,
        clampingRect: clampingRect,
        rotation: 0,
      );

      expect(correctiveDelta, Vector2(-200, -100));
    });

  });

  group('flipBox tests', () {
    test('flipBox test with bottom-right handle', () {
      final box = Box.fromLTWH(500, 500, 400, 300);

      Box flipped = flipRect(box, Flip.none, HandlePosition.bottomRight);
      expect(box, flipped);

      flipped = flipRect(box, Flip.horizontal, HandlePosition.bottomRight);
      expect(flipped.topLeft, Vector2(100, 500));

      flipped = flipRect(box, Flip.vertical, HandlePosition.bottomRight);
      expect(flipped.topLeft, Vector2(500, 200));

      flipped = flipRect(box, Flip.diagonal, HandlePosition.bottomRight);
      expect(flipped.topLeft, Vector2(100, 200));
    });

    test('flipBox test with top-right handle', () {
      final box = Box.fromLTWH(500, 500, 400, 300);

      Box flipped = flipRect(box, Flip.none, HandlePosition.topRight);
      expect(box, flipped);

      flipped = flipRect(box, Flip.horizontal, HandlePosition.topRight);
      expect(flipped.topLeft, Vector2(100, 500));

      flipped = flipRect(box, Flip.vertical, HandlePosition.topRight);
      expect(flipped.topLeft, Vector2(500, 800));

      flipped = flipRect(box, Flip.diagonal, HandlePosition.topRight);
      expect(flipped.topLeft, Vector2(100, 800));
    });

    test('flipBox test with top-left handle', () {
      final box = Box.fromLTWH(500, 500, 400, 300);

      Box flipped = flipRect(box, Flip.none, HandlePosition.topLeft);
      expect(box, flipped);

      flipped = flipRect(box, Flip.horizontal, HandlePosition.topLeft);
      expect(flipped.topLeft, Vector2(900, 500));

      flipped = flipRect(box, Flip.vertical, HandlePosition.topLeft);
      expect(flipped.topLeft, Vector2(500, 800));

      flipped = flipRect(box, Flip.diagonal, HandlePosition.topLeft);
      expect(flipped.topLeft, Vector2(900, 800));
    });

    test('flipBox test with bottom-left handle', () {
      final box = Box.fromLTWH(500, 500, 400, 300);

      Box flipped = flipRect(box, Flip.none, HandlePosition.bottomLeft);
      expect(box, flipped);

      flipped = flipRect(box, Flip.horizontal, HandlePosition.bottomLeft);
      expect(flipped.topLeft, Vector2(900, 500));

      flipped = flipRect(box, Flip.vertical, HandlePosition.bottomLeft);
      expect(flipped.topLeft, Vector2(500, 200));

      flipped = flipRect(box, Flip.diagonal, HandlePosition.bottomLeft);
      expect(flipped.topLeft, Vector2(900, 200));
    });
  });

  group('getFlipForBox tests', () {
    test('getFlipForBox test for bottom-right handle', () {
      final box = Box.fromLTWH(500, 500, 400, 300);

      Flip flip = getFlipForRect(
        box,
        Vector2(-500, -400),
        HandlePosition.bottomRight,
        ResizeMode.freeform,
      );
      expect(flip, Flip.diagonal);

      flip = getFlipForRect(
        box,
        Vector2(-500, 10),
        HandlePosition.bottomRight,
        ResizeMode.freeform,
      );
      expect(flip, Flip.horizontal);

      flip = getFlipForRect(
        box,
        Vector2(10, -400),
        HandlePosition.bottomRight,
        ResizeMode.freeform,
      );
      expect(flip, Flip.vertical);

      flip = getFlipForRect(
        box,
        Vector2(10, 10),
        HandlePosition.bottomRight,
        ResizeMode.freeform,
      );
      expect(flip, Flip.none);

      flip = getFlipForRect(
        box,
        Vector2(500, 500),
        HandlePosition.topLeft,
        ResizeMode.freeform,
      );
      expect(flip, Flip.diagonal);

      flip = getFlipForRect(
        box,
        Vector2(500, -10),
        HandlePosition.topLeft,
        ResizeMode.freeform,
      );
      expect(flip, Flip.horizontal);

      flip = getFlipForRect(
        box,
        Vector2(-10, 500),
        HandlePosition.topLeft,
        ResizeMode.freeform,
      );
      expect(flip, Flip.vertical);

      flip = getFlipForRect(
        box,
        Vector2(-10, -10),
        HandlePosition.topLeft,
        ResizeMode.freeform,
      );
      expect(flip, Flip.none);

      flip = getFlipForRect(
        box,
        Vector2(10, -10),
        HandlePosition.topRight,
        ResizeMode.freeform,
      );
      expect(flip, Flip.none);

      flip = getFlipForRect(
        box,
        Vector2(10, 500),
        HandlePosition.topRight,
        ResizeMode.freeform,
      );
      expect(flip, Flip.vertical);

      flip = getFlipForRect(
        box,
        Vector2(-500, 500),
        HandlePosition.topRight,
        ResizeMode.freeform,
      );
      expect(flip, Flip.diagonal);

      flip = getFlipForRect(
        box,
        Vector2(-500, -10),
        HandlePosition.topRight,
        ResizeMode.freeform,
      );
      expect(flip, Flip.horizontal);

      flip = getFlipForRect(
        box,
        Vector2(500, 10),
        HandlePosition.bottomLeft,
        ResizeMode.freeform,
      );
      expect(flip, Flip.horizontal);

      flip = getFlipForRect(
        box,
        Vector2(-10, 10),
        HandlePosition.bottomLeft,
        ResizeMode.freeform,
      );
      expect(flip, Flip.none);

      flip = getFlipForRect(
        box,
        Vector2(-10, -500),
        HandlePosition.bottomLeft,
        ResizeMode.freeform,
      );
      expect(flip, Flip.vertical);

      flip = getFlipForRect(
        box,
        Vector2(500, -500),
        HandlePosition.bottomLeft,
        ResizeMode.freeform,
      );
      expect(flip, Flip.diagonal);
    });

    test('getFlipForBox test for top-left handle', () {
      final box = Box.fromLTWH(0, 0, 400, 300);

      Flip flip = getFlipForRect(
        box,
        Vector2(500, 500),
        HandlePosition.topLeft,
        ResizeMode.freeform,
      );
      expect(flip, Flip.diagonal);

      flip = getFlipForRect(
        box,
        Vector2(500, -10),
        HandlePosition.topLeft,
        ResizeMode.freeform,
      );
      expect(flip, Flip.horizontal);

      flip = getFlipForRect(
        box,
        Vector2(-10, 500),
        HandlePosition.topLeft,
        ResizeMode.freeform,
      );
      expect(flip, Flip.vertical);

      flip = getFlipForRect(
        box,
        Vector2(-10, -10),
        HandlePosition.topLeft,
        ResizeMode.freeform,
      );
      expect(flip, Flip.none);

      flip = getFlipForRect(
        box,
        Vector2(-10, -10),
        HandlePosition.topLeft,
        ResizeMode.scale,
      );
      expect(flip, Flip.none);

      flip = getFlipForRect(
        box,
        Vector2(500, 500),
        HandlePosition.topLeft,
        ResizeMode.scale,
      );
      expect(flip, Flip.diagonal);

      flip = getFlipForRect(
        box,
        Vector2(500, -10),
        HandlePosition.topLeft,
        ResizeMode.scale,
      );
      expect(flip, Flip.horizontal);

      flip = getFlipForRect(
        box,
        Vector2(-10, 500),
        HandlePosition.topLeft,
        ResizeMode.scale,
      );
      expect(flip, Flip.vertical);

      flip = getFlipForRect(
        box,
        Vector2(-10, -10),
        HandlePosition.topLeft,
        ResizeMode.symmetric,
      );
      expect(flip, Flip.none);

      flip = getFlipForRect(
        box,
        Vector2(300, 200),
        HandlePosition.topLeft,
        ResizeMode.symmetric,
      );
      expect(flip, Flip.diagonal);

      flip = getFlipForRect(
        box,
        Vector2(800, -10),
        HandlePosition.topLeft,
        ResizeMode.symmetric,
      );
      expect(flip, Flip.horizontal);

      flip = getFlipForRect(
        box,
        Vector2(-10, 500),
        HandlePosition.topLeft,
        ResizeMode.symmetric,
      );
      expect(flip, Flip.vertical);

      flip = getFlipForRect(
        box,
        Vector2(-10, -10),
        HandlePosition.topLeft,
        ResizeMode.symmetricScale,
      );
      expect(flip, Flip.none);

      flip = getFlipForRect(
        box,
        Vector2(800, 500),
        HandlePosition.topLeft,
        ResizeMode.symmetricScale,
      );
      expect(flip, Flip.diagonal);

      flip = getFlipForRect(
        box,
        Vector2(300, 0),
        HandlePosition.topLeft,
        ResizeMode.symmetricScale,
      );
      expect(flip, Flip.horizontal);

      flip = getFlipForRect(
        box,
        Vector2(0, 200),
        HandlePosition.topLeft,
        ResizeMode.symmetricScale,
      );
      expect(flip, Flip.vertical);
    });

    test('getFlipForBox test for top-right handle', () {
      final box = Box.fromLTWH(0, 0, 400, 300);

      Flip flip = getFlipForRect(
        box,
        Vector2(500, 500),
        HandlePosition.topRight,
        ResizeMode.freeform,
      );
      expect(flip, Flip.vertical);

      flip = getFlipForRect(
        box,
        Vector2(-500, 500),
        HandlePosition.topRight,
        ResizeMode.freeform,
      );
      expect(flip, Flip.diagonal);

      flip = getFlipForRect(
        box,
        Vector2(-500, 0),
        HandlePosition.topRight,
        ResizeMode.freeform,
      );
      expect(flip, Flip.horizontal);

      flip = getFlipForRect(
        box,
        Vector2(-10, -10),
        HandlePosition.topRight,
        ResizeMode.freeform,
      );
      expect(flip, Flip.none);

      flip = getFlipForRect(
        box,
        Vector2(-10, -10),
        HandlePosition.topRight,
        ResizeMode.scale,
      );
      expect(flip, Flip.none);

      flip = getFlipForRect(
        box,
        Vector2(500, 500),
        HandlePosition.topRight,
        ResizeMode.scale,
      );
      expect(flip, Flip.vertical);

      flip = getFlipForRect(
        box,
        Vector2(-500, 500),
        HandlePosition.topRight,
        ResizeMode.scale,
      );
      expect(flip, Flip.diagonal);

      flip = getFlipForRect(
        box,
        Vector2(-500, 0),
        HandlePosition.topRight,
        ResizeMode.scale,
      );
      expect(flip, Flip.horizontal);

      flip = getFlipForRect(
        box,
        Vector2(-10, -10),
        HandlePosition.topRight,
        ResizeMode.symmetric,
      );
      expect(flip, Flip.none);

      flip = getFlipForRect(
        box,
        Vector2(100, 200),
        HandlePosition.topRight,
        ResizeMode.symmetric,
      );
      expect(flip, Flip.vertical);

      flip = getFlipForRect(
        box,
        Vector2(-300, 200),
        HandlePosition.topRight,
        ResizeMode.symmetric,
      );
      expect(flip, Flip.diagonal);

      flip = getFlipForRect(
        box,
        Vector2(-500, 0),
        HandlePosition.topRight,
        ResizeMode.symmetric,
      );
      expect(flip, Flip.horizontal);

      flip = getFlipForRect(
        box,
        Vector2(-10, -10),
        HandlePosition.topRight,
        ResizeMode.symmetricScale,
      );
      expect(flip, Flip.none);

      flip = getFlipForRect(
        box,
        Vector2(500, 500),
        HandlePosition.topRight,
        ResizeMode.symmetricScale,
      );
      expect(flip, Flip.vertical);

      flip = getFlipForRect(
        box,
        Vector2(-500, 0),
        HandlePosition.topRight,
        ResizeMode.symmetricScale,
      );
      expect(flip, Flip.horizontal);

      flip = getFlipForRect(
        box,
        Vector2(-20, 20),
        HandlePosition.topRight,
        ResizeMode.symmetricScale,
      );
      expect(flip, Flip.none);
    });

    test('getFlipForBox test for bottom-left handle', () {
      final box = Box.fromLTWH(0, 0, 400, 300);

      Flip flip = getFlipForRect(
        box,
        Vector2(500, -400),
        HandlePosition.bottomLeft,
        ResizeMode.freeform,
      );
      expect(flip, Flip.diagonal);

      flip = getFlipForRect(
        box,
        Vector2(500, 500),
        HandlePosition.bottomLeft,
        ResizeMode.freeform,
      );
      expect(flip, Flip.horizontal);

      flip = getFlipForRect(
        box,
        Vector2(0, -400),
        HandlePosition.bottomLeft,
        ResizeMode.freeform,
      );
      expect(flip, Flip.vertical);

      flip = getFlipForRect(
        box,
        Vector2(20, -20),
        HandlePosition.bottomLeft,
        ResizeMode.freeform,
      );
      expect(flip, Flip.none);

      flip = getFlipForRect(
        box,
        Vector2(20, -20),
        HandlePosition.bottomLeft,
        ResizeMode.scale,
      );
      expect(flip, Flip.none);

      flip = getFlipForRect(
        box,
        Vector2(500, -400),
        HandlePosition.bottomLeft,
        ResizeMode.scale,
      );
      expect(flip, Flip.diagonal);

      flip = getFlipForRect(
        box,
        Vector2(500, 500),
        HandlePosition.bottomLeft,
        ResizeMode.scale,
      );
      expect(flip, Flip.horizontal);

      flip = getFlipForRect(
        box,
        Vector2(0, -400),
        HandlePosition.bottomLeft,
        ResizeMode.scale,
      );
      expect(flip, Flip.vertical);

      flip = getFlipForRect(
        box,
        Vector2(20, -20),
        HandlePosition.bottomLeft,
        ResizeMode.symmetric,
      );
      expect(flip, Flip.none);

      flip = getFlipForRect(
        box,
        Vector2(300, -200),
        HandlePosition.bottomLeft,
        ResizeMode.symmetric,
      );
      expect(flip, Flip.diagonal);

      flip = getFlipForRect(
        box,
        Vector2(800, 500),
        HandlePosition.bottomLeft,
        ResizeMode.symmetric,
      );
      expect(flip, Flip.horizontal);

      flip = getFlipForRect(
        box,
        Vector2(0, -200),
        HandlePosition.bottomLeft,
        ResizeMode.symmetric,
      );
      expect(flip, Flip.vertical);

      flip = getFlipForRect(
        box,
        Vector2(20, -20),
        HandlePosition.bottomLeft,
        ResizeMode.symmetricScale,
      );
      expect(flip, Flip.none);

      flip = getFlipForRect(
        box,
        Vector2(300, -200),
        HandlePosition.bottomLeft,
        ResizeMode.symmetricScale,
      );
      expect(flip, Flip.diagonal);

      flip = getFlipForRect(
        box,
        Vector2(800, 500),
        HandlePosition.bottomLeft,
        ResizeMode.symmetricScale,
      );
      expect(flip, Flip.horizontal);

      flip = getFlipForRect(
        box,
        Vector2(0, -200),
        HandlePosition.bottomLeft,
        ResizeMode.symmetricScale,
      );
      expect(flip, Flip.vertical);
    });
  });

  test('getAvailableAreaForHandle tests', () {
    final Box clampingRect = Box.fromLTRB(100, 100, 1000, 1000);
    final Box rect = Box.fromLTRB(400, 600, 400, 300);

    expect(
      getAvailableAreaForHandle(
          rect: rect,
          clampingRect: clampingRect,
          handle: HandlePosition.bottomRight),
      Box.fromPoints(rect.topLeft, clampingRect.bottomRight),
    );

    expect(
      getAvailableAreaForHandle(
          rect: rect,
          clampingRect: clampingRect,
          handle: HandlePosition.topLeft),
      Box.fromPoints(clampingRect.topLeft, rect.bottomRight),
    );

    expect(
      getAvailableAreaForHandle(
          rect: rect,
          clampingRect: clampingRect,
          handle: HandlePosition.bottomLeft),
      Box.fromLTRB(
          clampingRect.left, rect.top, rect.right, clampingRect.bottom),
    );

    expect(
      getAvailableAreaForHandle(
          rect: rect,
          clampingRect: clampingRect,
          handle: HandlePosition.topRight),
      Box.fromLTRB(
          rect.left, clampingRect.top, clampingRect.right, rect.bottom),
    );

    expect(
      getAvailableAreaForHandle(
          rect: rect,
          clampingRect: clampingRect,
          handle: HandlePosition.bottom),
      Box.fromLTRB(
          clampingRect.left, rect.top, clampingRect.right, clampingRect.bottom),
    );

    expect(
      getAvailableAreaForHandle(
          rect: rect, clampingRect: clampingRect, handle: HandlePosition.right),
      Box.fromLTRB(
          rect.left, clampingRect.top, clampingRect.right, clampingRect.bottom),
    );

    expect(
      getAvailableAreaForHandle(
          rect: rect, clampingRect: clampingRect, handle: HandlePosition.left),
      Box.fromLTRB(
          clampingRect.left, clampingRect.top, rect.right, clampingRect.bottom),
    );
  });

  test('getClosestEdge tests', () {
    Box rect = Box.fromLTWH(200, 300, 400, 300);
    Box clampingRect = Box.fromLTWH(100, 100, 1000, 1000);

    expect(getClosestEdge(rect, clampingRect), HandlePosition.left);

    rect = Box.fromLTWH(200, 150, 400, 300);
    expect(getClosestEdge(rect, clampingRect), HandlePosition.top);

    rect = Box.fromLTWH(200, 900, 400, 300);
    expect(getClosestEdge(rect, clampingRect), HandlePosition.bottom);

    rect = Box.fromLTWH(900, 300, 400, 300);
    expect(getClosestEdge(rect, clampingRect), HandlePosition.right);

    rect = Box.fromLTWH(900, 900, 400, 300);
    expect(getClosestEdge(rect, clampingRect), HandlePosition.right);

    rect = Box.fromLTWH(900, 150, 400, 300);
    expect(getClosestEdge(rect, clampingRect), HandlePosition.right);
  });
}
