import 'dart:math';

import 'package:box_transform/box_transform.dart';
import 'package:test/test.dart';

void main() {
  group('stopRectAtClampingRect', () {
    test('returns zero delta when rect is fully inside clampingRect (rotation 0)', () {
      final rect = Box.fromLTWH(150, 150, 200, 200);
      final clampingRect = Box.fromLTWH(100, 100, 400, 400);
      final delta = BoxTransformer.stopRectAtClampingRect(
        rect: rect,
        clampingRect: clampingRect,
        rotation: 0,
      );
      expect(delta.x, closeTo(0, 0.001));
      expect(delta.y, closeTo(0, 0.001));
    });

    test('returns horizontal correction for left violation (rotation 0)', () {
      // The left edge of rect is at 80 while clampingRect starts at 100.
      final rect = Box.fromLTWH(80, 150, 200, 200); // left = 80
      final clampingRect = Box.fromLTWH(100, 100, 400, 400); // left = 100
      final delta = BoxTransformer.stopRectAtClampingRect(
        rect: rect,
        clampingRect: clampingRect,
        rotation: 0,
      );
      // Expect a correction that shifts the violating side by 20 pixels.
      expect(delta.x, closeTo(20, 0.001));
      expect(delta.y, closeTo(0, 0.001));
    });

    test('returns horizontal correction for right violation (rotation 0)', () {
      // The right edge of rect is at 350 while clampingRect ends at 300.
      final rect = Box.fromLTWH(150, 150, 200, 200); // right = 350
      // clampingRect from (100,100) with width 200 has right = 300.
      final clampingRect = Box.fromLTWH(100, 100, 200, 400);
      final delta = BoxTransformer.stopRectAtClampingRect(
        rect: rect,
        clampingRect: clampingRect,
        rotation: 0,
      );
      // For a right violation the delta.x comes out as -50.
      expect(delta.x, closeTo(-50, 0.001));
      expect(delta.y, closeTo(0, 0.001));
    });

    test('returns vertical correction for top violation (rotation 0)', () {
      // The top edge of rect is at 80 while clampingRect starts at 100.
      final rect = Box.fromLTWH(150, 80, 200, 200); // top = 80
      final clampingRect = Box.fromLTWH(100, 100, 400, 400); // top = 100
      final delta = BoxTransformer.stopRectAtClampingRect(
        rect: rect,
        clampingRect: clampingRect,
        rotation: 0,
      );
      expect(delta.x, closeTo(0, 0.001));
      expect(delta.y, closeTo(20, 0.001));
    });

    test('returns vertical correction for bottom violation (rotation 0)', () {
      // The bottom edge of rect is at 350 while clampingRect ends at 300.
      final rect = Box.fromLTWH(150, 150, 200, 200); // bottom = 350
      // clampingRect from (100,100) with height 200 has bottom = 300.
      final clampingRect = Box.fromLTWH(100, 100, 400, 200);
      final delta = BoxTransformer.stopRectAtClampingRect(
        rect: rect,
        clampingRect: clampingRect,
        rotation: 0,
      );
      expect(delta.x, closeTo(0, 0.001));
      expect(delta.y, closeTo(-50, 0.001));
    });

    test('returns combined correction for top-left violation (rotation 0)', () {
      // Both left and top edges are out-of-bound.
      final rect = Box.fromLTWH(80, 80, 200, 200); // left = 80, top = 80
      final clampingRect = Box.fromLTWH(100, 100, 400, 400);
      final delta = BoxTransformer.stopRectAtClampingRect(
        rect: rect,
        clampingRect: clampingRect,
        rotation: 0,
      );
      expect(delta.x, closeTo(20, 0.001));
      expect(delta.y, closeTo(20, 0.001));
    });

    test('returns combined correction for bottom-right violation (rotation 0)', () {
      // Both right and bottom edges are out-of-bound.
      final rect = Box.fromLTWH(150, 150, 200, 200); // right = 350, bottom = 350
      final clampingRect = Box.fromLTWH(100, 100, 200, 200); // right = 300, bottom = 300
      final delta = BoxTransformer.stopRectAtClampingRect(
        rect: rect,
        clampingRect: clampingRect,
        rotation: 0,
      );
      expect(delta.x, closeTo(-50, 0.001));
      expect(delta.y, closeTo(-50, 0.001));
    });

    test('returns zero delta when rect is inside clampingRect (non-zero rotation)', () {
      final rect = Box.fromLTWH(150, 150, 200, 200);
      final clampingRect = Box.fromLTWH(100, 100, 400, 400);
      final delta = BoxTransformer.stopRectAtClampingRect(
        rect: rect,
        clampingRect: clampingRect,
        rotation: 0.5,
      );

      // When the rect is fully inside even after rotation, no correction is needed.
      expect(delta.x, closeTo(0, 0.001));
      expect(delta.y, closeTo(0, 0.001));
    });

    test('handles non-zero positive rotation with violation', () {
      // With a small positive rotation, the rotated rect still violates the left boundary.
      final rect = Box.fromLTWH(80, 150, 200, 200);
      final clampingRect = Box.fromLTWH(100, 100, 400, 400);
      final rotation = 0.2;
      final delta = BoxTransformer.stopRectAtClampingRect(
        rect: rect,
        clampingRect: clampingRect,
        rotation: rotation,
      );

      // For rect starting at (80,150) and rotated by 0.2, the left side violation is reduced
      // from 20 pixels to about 18.01 pixels. Rotating this correction back by -0.2 radians
      // yields an expected delta of approximately (17.65, -3.57).
      expect(delta.x, closeTo(17.65, 0.001));
      expect(delta.y, closeTo(-3.57, 0.001));
    });

    test('handles non-zero negative rotation with violation', () {
      // With a small negative rotation, the rotated rect violates the top boundary.
      final rect = Box.fromLTWH(150, 80, 200, 200);
      final clampingRect = Box.fromLTWH(100, 100, 400, 400);
      final rotation = -0.2;
      final delta = BoxTransformer.stopRectAtClampingRect(
        rect: rect,
        clampingRect: clampingRect,
        rotation: rotation,
      );

      // For rect starting at (150,80) and rotated by -0.2, the top side violation is roughly 18.01 pixels.
      // Rotating this correction back by 0.2 radians yields an expected delta of about (-3.57, 17.65).
      expect(delta.x, closeTo(-3.57, 0.001));
      expect(delta.y, closeTo(17.65, 0.001));
    });

    test('does not reset horizontal delta when rect width increases (rotation ~32.37°)', () {
      // Use a clamping rect that will be exceeded on the right.
      final clampingRect = Box.fromLTWH(100, 100, 200, 200);
      // 32.37 degrees in radians.
      final rotation = 32.37 * (pi / 180);

      // We start with a width that barely violates the right boundary and increase it.
      bool sawNegative = false;
      bool deltaReset = false;
      double? previousDeltaX;

      for (double width = 150; width <= 300; width += 10) {
        // Create a rect with fixed top/left and varying width.
        final rect = Box.fromLTWH(150, 150, width, 200);
        final delta = BoxTransformer.stopRectAtClampingRect(
          rect: rect,
          clampingRect: clampingRect,
          rotation: rotation,
        );

        // Once a negative correction is observed, it should remain negative.
        if (delta.x < 0) {
          sawNegative = true;
          if (previousDeltaX != null && previousDeltaX >= 0 && delta.x < 0) {
            // first time negative: ok.
          } else if (previousDeltaX != null && previousDeltaX < 0 && delta.x >= 0) {
            // delta.x jumped back to zero (or positive): error.
            deltaReset = true;
          }
        }
        previousDeltaX = delta.x;
      }
      expect(sawNegative, isTrue, reason: 'A negative delta.x should be observed.');
      expect(deltaReset, isFalse,
          reason: 'Once negative, delta.x should not reset back to zero as width increases.');
    });
  });
}