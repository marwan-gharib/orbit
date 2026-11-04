import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/interactions/presentation/constants/interaction_layout_constants.dart';

import '../../test_helpers.dart';

void main() {
  group('InteractionLayoutConstants', () {
    testWidgets('all constants are positive and finite', (tester) async {
      await pumpWidget(tester, const SizedBox());

      expect(InteractionLayoutConstants.typeIconSize, greaterThan(0));
      expect(InteractionLayoutConstants.typeIconGap, greaterThan(0));
      expect(InteractionLayoutConstants.contentGap, greaterThan(0));
      expect(InteractionLayoutConstants.tileVerticalPadding, greaterThan(0));
      expect(InteractionLayoutConstants.tileHorizontalPadding, greaterThan(0));
      expect(InteractionLayoutConstants.chipHeight, greaterThan(0));
      expect(InteractionLayoutConstants.chipHorizontalPadding, greaterThan(0));
      expect(InteractionLayoutConstants.swipeActionWidth, greaterThan(0));
      expect(InteractionLayoutConstants.swipeIconSize, greaterThan(0));
      expect(InteractionLayoutConstants.groupHeaderPadding, greaterThan(0));
      expect(InteractionLayoutConstants.groupHeaderTopGap, greaterThan(0));
      expect(InteractionLayoutConstants.skeletonRowGap, greaterThan(0));
      expect(InteractionLayoutConstants.timelineConnectorWidth, greaterThan(0));
      expect(InteractionLayoutConstants.timelineNodeSize, greaterThan(0));
      expect(InteractionLayoutConstants.timelineGap, greaterThan(0));
      expect(InteractionLayoutConstants.sheetFieldGap, greaterThan(0));
      expect(
        InteractionLayoutConstants.minTapTarget,
        equals(kMinInteractiveDimension),
      );
    });

    testWidgets('skeleton constants are in valid ranges', (tester) async {
      await pumpWidget(tester, const SizedBox());

      expect(InteractionLayoutConstants.skeletonRows, greaterThan(0));
      expect(InteractionLayoutConstants.skeletonTypeIconWidth, greaterThan(0));
      expect(InteractionLayoutConstants.skeletonTypeIconWidth, lessThan(1));
      expect(InteractionLayoutConstants.skeletonSubjectWidth, greaterThan(0));
      expect(InteractionLayoutConstants.skeletonSubjectWidth, lessThan(1));
      expect(
        InteractionLayoutConstants.skeletonDescriptionWidth,
        greaterThan(0),
      );
      expect(InteractionLayoutConstants.skeletonDescriptionWidth, lessThan(1));
      expect(InteractionLayoutConstants.skeletonDateWidth, greaterThan(0));
      expect(InteractionLayoutConstants.skeletonDateWidth, lessThan(1));
    });

    testWidgets('sheet line bounds are valid', (tester) async {
      await pumpWidget(tester, const SizedBox());

      expect(InteractionLayoutConstants.sheetMinLines, greaterThanOrEqualTo(1));
      expect(
        InteractionLayoutConstants.sheetMaxLines,
        greaterThanOrEqualTo(InteractionLayoutConstants.sheetMinLines),
      );
    });
  });
}
