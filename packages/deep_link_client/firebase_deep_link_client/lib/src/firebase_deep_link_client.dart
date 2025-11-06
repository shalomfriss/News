// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:deep_link_client/deep_link_client.dart';
// Firebase Dynamic Links was deprecated and removed from Firebase SDK
// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

/// {@template firebase_deep_link_client}
/// A FirebaseDynamicLinks implementation of [DeepLinkClient].
/// Note: Firebase Dynamic Links has been shut down. This is a stub implementation.
/// {@endtemplate}
class FirebaseDeepLinkClient implements DeepLinkClient {
  /// {@macro firebase_deep_link_client}
  FirebaseDeepLinkClient({dynamic firebaseDynamicLinks});
      // : _firebaseDynamicLinks = firebaseDynamicLinks;

  // final FirebaseDynamicLinks _firebaseDynamicLinks;

  @override
  Stream<Uri> get deepLinkStream => const Stream.empty();
      // _firebaseDynamicLinks.onLink.map((event) => event.link);

  @override
  Future<Uri?> getInitialLink() async {
    return null;
    // final deepLink = await _firebaseDynamicLinks.getInitialLink();
    // return deepLink?.link;
  }
}
