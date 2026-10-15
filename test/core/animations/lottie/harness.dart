import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/constants/app_lottie_assets.dart';

/// A minimal parseable Lottie composition: one static rectangle, one second
/// at 60fps. Lets the wrapper tests exercise real playback without design
/// files in `assets/animations/`.
const String _testComposition =
    '{"v":"5.7.4","fr":60,"ip":0,"op":60,"w":100,"h":100,"nm":"test","ddd":0,'
    '"assets":[],"layers":[{"ddd":0,"ind":1,"ty":4,"nm":"rect","sr":1,'
    '"ks":{"o":{"a":0,"k":100},"r":{"a":0,"k":0},"p":{"a":0,"k":[50,50,0]},'
    '"a":{"a":0,"k":[0,0,0]},"s":{"a":0,"k":[100,100,100]}},'
    '"ao":0,"shapes":[{"ty":"gr","it":['
    '{"ty":"rc","d":1,"s":{"a":0,"k":[40,40]},"p":{"a":0,"k":[0,0]},'
    '"r":{"a":0,"k":0}},'
    '{"ty":"fl","c":{"a":0,"k":[0,0,0,1]},"o":{"a":0,"k":100},"r":1,"bm":0}'
    ']}],"ip":0,"op":60,"st":0,"bm":0}]}';

/// Asset bundle the Lottie widgets read in tests: resolves the keys in
/// [servedLottieAssets] and fails every other one, so playback and the
/// fallback path are both testable without real files.
class FakeLottieAssets extends CachingAssetBundle {
  /// Keys this bundle resolves; anything else throws.
  static const Set<String> servedLottieAssets = {
    AppLottieAssets.success,
    AppLottieAssets.loading,
  };

  /// Every key the widget asked for, in order.
  final List<String> requestedAssets = <String>[];

  @override
  Future<ByteData> load(String key) async {
    requestedAssets.add(key);
    if (!servedLottieAssets.contains(key)) {
      throw FlutterError('FakeLottieAssets has no asset "$key"');
    }
    return ByteData.sublistView(utf8.encode(_testComposition));
  }
}

/// Pumps [child] under the theme, media query, text direction and asset
/// bundle the Lottie widgets read, without a whole [MaterialApp].
Future<void> pumpLottie(
  WidgetTester tester,
  Widget child, {
  bool disableAnimations = false,
  TextDirection direction = TextDirection.ltr,
  FakeLottieAssets? assets,
}) {
  return tester.pumpWidget(
    Theme(
      data: ThemeData(),
      child: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: Directionality(
          textDirection: direction,
          child: DefaultAssetBundle(
            bundle: assets ?? FakeLottieAssets(),
            child: child,
          ),
        ),
      ),
    ),
  );
}

/// Pumps short frames until the composition has been parsed and handed to
/// the widget. The load resolves entirely in microtasks, so a handful of
/// frames is enough.
Future<void> pumpLottieLoad(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
  await tester.pump();
  await tester.pump();
}
