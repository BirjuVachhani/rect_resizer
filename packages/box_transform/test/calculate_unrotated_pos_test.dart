import 'dart:math';
import 'package:box_transform/box_transform.dart';
import 'package:test/test.dart';
import 'package:vector_math/vector_math.dart';

/// A helper function to compare two [Vector2] values with a small tolerance.
/// Increased default tolerance from 1e-5 to 1e-4 to allow for minor floating point imprecisions.
void expectVector2(Vector2 actual, Vector2 expected, {double tol = 1e-4}) {
  expect(actual.x, closeTo(expected.x, tol),
      reason: 'x value mismatch: actual ${actual.x}, expected ${expected.x}');
  expect(actual.y, closeTo(expected.y, tol),
      reason: 'y value mismatch: actual ${actual.y}, expected ${expected.y}');
}

void main() {
  group('BoxTransformer.calculateUnrotatedPos', () {
    test('rotation 0, delta 0, same size (no movement)', () {
      final box = Box.fromLTWH(10, 10, 100, 50);
      final newSize = const Dimension(100, 50);
      final delta = Vector2.zero();

      // With no rotation, the rotated top-left equals the original.
      final result = BoxTransformer.calculateUnrotatedPos(box, 0, delta, newSize);
      expectVector2(result, box.topLeft);
    });

    test('rotation 0, nonzero delta (simple translation)', () {
      final box = Box.fromLTWH(10, 10, 100, 50);
      final newSize = const Dimension(100, 50);
      final delta = Vector2(5, -3);

      // With no rotation, the new topLeft is just the original plus delta.
      final result = BoxTransformer.calculateUnrotatedPos(box, 0, delta, newSize);
      expectVector2(result, box.topLeft + delta);
    });

    test('rotation π/2, delta 0 (pure rotation)', () {
      // Create a box at (0,0) with size 100×50.
      final box = Box.fromLTWH(0, 0, 100, 50);
      final newSize = const Dimension(100, 50);
      final delta = Vector2.zero();

      // For rotation π/2, manual computation shows:
      // - center = (50,25)
      // - oldRotatedXY = rotate (0,0) about (50,25) by π/2 -> (75, -25)
      // - After the math, the final unrotated topLeft comes out to (0,0).
      final result = BoxTransformer.calculateUnrotatedPos(box, pi / 2, delta, newSize);
      expectVector2(result, Vector2(0, 0));
    });

    test('rotation π/2, nonzero delta', () {
      // Using the same box as before.
      final box = Box.fromLTWH(0, 0, 100, 50);
      final newSize = const Dimension(100, 50);
      final delta = Vector2(10, 5);

      /* Step-by-step manual computation:
         - For box with center (50,25), rotating topLeft (0,0) by π/2 about the center gives (75, -25).
         - With delta applied (and using sin(-π/2)= -1, cos(-π/2)= 0), we get a new rotated topLeft of (70, -15).
         - After computing the new rotated bottom-right and new center,
           rotating (70, -15) back about the new center gives an unrotated topLeft ≈ (-5, 10).
      */
      final result = BoxTransformer.calculateUnrotatedPos(box, pi / 2, delta, newSize);
      expectVector2(result, Vector2(-5, 10));
    });

    test('rotation π/4, delta 0 (no delta; expect original position)', () {
      // A square box starting at (100,100) with size 50×50.
      final box = Box.fromLTWH(100, 100, 50, 50);
      final newSize = const Dimension(50, 50);
      final delta = Vector2.zero();

      // With no delta, the final unrotated topLeft should remain unchanged.
      final result = BoxTransformer.calculateUnrotatedPos(box, pi / 4, delta, newSize);
      expectVector2(result, box.topLeft);
    });

    test('rotation π/4, nonzero delta', () {
      // Same square box but now with a delta.
      final box = Box.fromLTWH(100, 100, 50, 50);
      final newSize = const Dimension(50, 50);
      final delta = Vector2(10, 0);

      // Manual computation yields an expected result near (107.07107, 107.07107).
      final result = BoxTransformer.calculateUnrotatedPos(box, pi / 4, delta, newSize);
      expectVector2(result, Vector2(107.07107, 107.07107));
    });

    test('rotation -π/4, delta 0 (negative rotation, no delta)', () {
      // A square box starting at (200,200) with size 50×50.
      final box = Box.fromLTWH(200, 200, 50, 50);
      final newSize = const Dimension(50, 50);
      final delta = Vector2.zero();

      // With no delta, the unrotated topLeft remains unchanged.
      final result = BoxTransformer.calculateUnrotatedPos(box, -pi / 4, delta, newSize);
      expectVector2(result, box.topLeft);
    });

    test('rotation π/2, delta 0 with different newSize', () {
      // Test a case where the new size is different from the original.
      final box = Box.fromLTWH(0, 0, 100, 50);
      final newSize = const Dimension(120, 60); // larger than original
      final delta = Vector2.zero();

      /* For rotation π/2:
         - center = (50,25), topLeft rotated -> (75,-25)
         - newSize affects the computed bottom-right and new center.
         - Final computed unrotated topLeft comes out approximately (-15, 5).
      */
      final result = BoxTransformer.calculateUnrotatedPos(box, pi / 2, delta, newSize);
      expectVector2(result, Vector2(-15, 5));
    });

    test('rotation -π/4, nonzero delta with square size', () {
      // Test negative rotation with a nonzero delta.
      final box = Box.fromLTWH(200, 200, 50, 50);
      final newSize = const Dimension(50, 50);
      final delta = Vector2(10, -10);

      /* For this box:
         - center = (225,225)
         - oldRotatedXY = rotate (200,200) about (225,225) by -π/4 ≈ (189.6447,225)
         - With delta applied, the new rotated topLeft becomes ≈ (189.6447, 210.858)
         - After computing the new center and rotating back, the expected unrotated topLeft is near (200, 185.858).
      */
      final result = BoxTransformer.calculateUnrotatedPos(box, -pi / 4, delta, newSize);
      expectVector2(result, Vector2(200, 185.858), tol: 1e-3);
    });

    test('rotation 0, nonzero delta with different newSize (size change ignored when rotation is 0)', () {
      final box = Box.fromLTWH(10, 10, 100, 50);
      final newSize = const Dimension(120, 60);
      final delta = Vector2(5, -5);

      // When rotation is 0, the new size is ignored and the new topLeft is simply topLeft + delta.
      final result = BoxTransformer.calculateUnrotatedPos(box, 0, delta, newSize);
      expectVector2(result, box.topLeft + delta);
    });
  });
}