import 'package:ddi/module.dart';
import 'package:flare_flutter/flare_cache.dart';
import 'package:flare_flutter/provider/asset_flare.dart';
import 'package:flutter/services.dart';

class FlareCachingModule extends AbstractModule {
  @override
  void init() async {
    FlareCache.doesPrune = false;
    const files = [
      "assets/flares/effect_success_error.flr",
      "assets/flares/speech_listening.flr",
      "assets/flares/typing.flr",
    ];
    for (final filename in files) {
      await cachedActor(AssetFlare(
        bundle: rootBundle,
        name: filename,
      ));
    }
  }
}
