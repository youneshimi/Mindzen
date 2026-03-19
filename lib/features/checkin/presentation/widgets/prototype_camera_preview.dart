// Conditional export based on platform
// Web platform: use FaceDetector API with real-time tracking
// Mobile (Android/iOS): use camera package with static overlay
// Other platforms: use mobile stub

export 'prototype_camera_preview_mobile.dart'
    if (dart.library.html) 'prototype_camera_preview_web.dart';
