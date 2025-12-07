// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart' as _svg;
import 'package:vector_graphics/vector_graphics.dart' as _vg;

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/about_icon.svg
  SvgGenImage get aboutIcon => const SvgGenImage('assets/icons/about_icon.svg');

  /// File path: assets/icons/apple.svg
  SvgGenImage get apple => const SvgGenImage('assets/icons/apple.svg');

  /// File path: assets/icons/back_icon.svg
  SvgGenImage get backIcon => const SvgGenImage('assets/icons/back_icon.svg');

  /// File path: assets/icons/best_value.svg
  SvgGenImage get bestValue => const SvgGenImage('assets/icons/best_value.svg');

  /// File path: assets/icons/close_circle.svg
  SvgGenImage get closeCircle =>
      const SvgGenImage('assets/icons/close_circle.svg');

  /// File path: assets/icons/close_circle_filled.svg
  SvgGenImage get closeCircleFilled =>
      const SvgGenImage('assets/icons/close_circle_filled.svg');

  /// File path: assets/icons/email_outline.svg
  SvgGenImage get emailOutline =>
      const SvgGenImage('assets/icons/email_outline.svg');

  /// File path: assets/icons/envelope_open.svg
  SvgGenImage get envelopeOpen =>
      const SvgGenImage('assets/icons/envelope_open.svg');

  /// File path: assets/icons/facebook.svg
  SvgGenImage get facebook => const SvgGenImage('assets/icons/facebook.svg');

  /// File path: assets/icons/google.svg
  SvgGenImage get google => const SvgGenImage('assets/icons/google.svg');

  /// File path: assets/icons/instagram.svg
  SvgGenImage get instagram => const SvgGenImage('assets/icons/instagram.svg');

  /// File path: assets/icons/log_in_icon.svg
  SvgGenImage get logInIcon =>
      const SvgGenImage('assets/icons/log_in_icon.svg');

  /// File path: assets/icons/log_out_icon.svg
  SvgGenImage get logOutIcon =>
      const SvgGenImage('assets/icons/log_out_icon.svg');

  /// File path: assets/icons/notifications_icon.svg
  SvgGenImage get notificationsIcon =>
      const SvgGenImage('assets/icons/notifications_icon.svg');

  /// File path: assets/icons/profile_icon.svg
  SvgGenImage get profileIcon =>
      const SvgGenImage('assets/icons/profile_icon.svg');

  /// File path: assets/icons/terms_of_use_icon.svg
  SvgGenImage get termsOfUseIcon =>
      const SvgGenImage('assets/icons/terms_of_use_icon.svg');

  /// File path: assets/icons/tiktok.svg
  SvgGenImage get tiktok => const SvgGenImage('assets/icons/tiktok.svg');

  /// File path: assets/icons/twitter.svg
  SvgGenImage get twitter => const SvgGenImage('assets/icons/twitter.svg');

  /// File path: assets/icons/video.svg
  SvgGenImage get video => const SvgGenImage('assets/icons/video.svg');

  /// File path: assets/icons/youtube.svg
  SvgGenImage get youtube => const SvgGenImage('assets/icons/youtube.svg');

  /// List of all assets
  List<SvgGenImage> get values => [
        aboutIcon,
        apple,
        backIcon,
        bestValue,
        closeCircle,
        closeCircleFilled,
        emailOutline,
        envelopeOpen,
        facebook,
        google,
        instagram,
        logInIcon,
        logOutIcon,
        notificationsIcon,
        profileIcon,
        termsOfUseIcon,
        tiktok,
        twitter,
        video,
        youtube
      ];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/continue_with_apple.svg
  SvgGenImage get continueWithApple =>
      const SvgGenImage('assets/images/continue_with_apple.svg');

  /// File path: assets/images/continue_with_facebook.svg
  SvgGenImage get continueWithFacebook =>
      const SvgGenImage('assets/images/continue_with_facebook.svg');

  /// File path: assets/images/continue_with_google.svg
  SvgGenImage get continueWithGoogle =>
      const SvgGenImage('assets/images/continue_with_google.svg');

  /// File path: assets/images/continue_with_twitter.svg
  SvgGenImage get continueWithTwitter =>
      const SvgGenImage('assets/images/continue_with_twitter.svg');

  /// File path: assets/images/logo_dark.png
  AssetGenImage get logoDark =>
      const AssetGenImage('assets/images/logo_dark.png');

  /// File path: assets/images/logo_light.png
  AssetGenImage get logoLight =>
      const AssetGenImage('assets/images/logo_light.png');

  /// List of all assets
  List<dynamic> get values => [
        continueWithApple,
        continueWithFacebook,
        continueWithGoogle,
        continueWithTwitter,
        logoDark,
        logoLight
      ];
}

class Assets {
  const Assets._();

  static const String package = 'app_ui';

  static const $AssetsIconsGen icons = $AssetsIconsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  static const String package = 'app_ui';

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    @Deprecated('Do not specify package for a generated library asset')
    String? package = package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    @Deprecated('Do not specify package for a generated library asset')
    String? package = package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => 'packages/app_ui/$_assetName';
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}

class SvgGenImage {
  const SvgGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
  }) : _isVecFormat = false;

  const SvgGenImage.vec(
    this._assetName, {
    this.size,
    this.flavors = const {},
  }) : _isVecFormat = true;

  final String _assetName;
  final Size? size;
  final Set<String> flavors;
  final bool _isVecFormat;

  static const String package = 'app_ui';

  _svg.SvgPicture svg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    @Deprecated('Do not specify package for a generated library asset')
    String? package = package,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder? placeholderBuilder,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    _svg.SvgTheme? theme,
    _svg.ColorMapper? colorMapper,
    ColorFilter? colorFilter,
    Clip clipBehavior = Clip.hardEdge,
    @deprecated Color? color,
    @deprecated BlendMode colorBlendMode = BlendMode.srcIn,
    @deprecated bool cacheColorFilter = false,
  }) {
    final _svg.BytesLoader loader;
    if (_isVecFormat) {
      loader = _vg.AssetBytesLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
      );
    } else {
      loader = _svg.SvgAssetLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
        theme: theme,
        colorMapper: colorMapper,
      );
    }
    return _svg.SvgPicture(
      loader,
      key: key,
      matchTextDirection: matchTextDirection,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      colorFilter: colorFilter ??
          (color == null ? null : ColorFilter.mode(color, colorBlendMode)),
      clipBehavior: clipBehavior,
      cacheColorFilter: cacheColorFilter,
    );
  }

  String get path => _assetName;

  String get keyName => 'packages/app_ui/$_assetName';
}
