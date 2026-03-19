// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;
import 'dart:ui' show lerpDouble;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class PrototypeCameraPreview extends StatefulWidget {
  const PrototypeCameraPreview({super.key});

  @override
  State<PrototypeCameraPreview> createState() => _PrototypeCameraPreviewState();
}

class _PrototypeCameraPreviewState extends State<PrototypeCameraPreview> {
  late final String _viewType;
  html.VideoElement? _videoElement;
  html.MediaStream? _stream;

  html.FaceDetector? _faceDetector;
  bool _detectorReady = false;
  bool _detecting = false;
  int _noFaceFrames = 0;

  Timer? _trackingTimer;
  bool _starting = true;
  String? _error;
  String _trackingMode = 'Initialisation tracking';

  final ValueNotifier<_TrackedFaceModel> _trackedFace = ValueNotifier(
    const _TrackedFaceModel.initial(),
  );

  @override
  void initState() {
    super.initState();
    _viewType = 'mindzen-camera-${DateTime.now().microsecondsSinceEpoch}';

    ui_web.platformViewRegistry.registerViewFactory(_viewType, (viewId) {
      final video = html.VideoElement()
        ..autoplay = true
        ..muted = true
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover'
        ..setAttribute('playsinline', 'true')
        ..setAttribute('aria-label', 'Apercu webcam prototype MindZen');
      _videoElement = video;
      return video;
    });

    _initDetector();
    _startCamera();
  }

  void _initDetector() {
    try {
      _faceDetector = html.FaceDetector({
        'fastMode': true,
        'maxDetectedFaces': 1,
      });
      _detectorReady = true;
      _setTrackingMode('Suivi visage');
    } catch (_) {
      _faceDetector = null;
      _detectorReady = false;
      _setTrackingMode('Mode degrade: FaceDetector indisponible');
    }
  }

  Future<void> _startCamera() async {
    setState(() {
      _starting = true;
      _error = null;
    });

    try {
      final mediaDevices = html.window.navigator.mediaDevices;
      if (mediaDevices == null) {
        throw StateError('API mediaDevices indisponible');
      }

      final stream = await mediaDevices.getUserMedia({
        'video': {
          'facingMode': 'user',
          'width': {'ideal': 1280},
          'height': {'ideal': 720},
        },
        'audio': false,
      });

      _stream = stream;
      _videoElement?.srcObject = stream;
      await _videoElement?.play();

      _startTrackingLoop();

      if (!mounted) {
        return;
      }
      setState(() {
        _starting = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _starting = false;
        _error = 'Camera non disponible ou permission refusee.';
      });
    }
  }

  void _startTrackingLoop() {
    _trackingTimer?.cancel();
    _trackingTimer = Timer.periodic(const Duration(milliseconds: 55), (_) {
      _tickTracking();
    });
  }

  Future<void> _tickTracking() async {
    if (!mounted || _videoElement == null || _starting || _detecting) {
      return;
    }

    final video = _videoElement!;
    final vw = video.videoWidth;
    final vh = video.videoHeight;

    if (vw <= 0 || vh <= 0) {
      return;
    }

    if (!_detectorReady || _faceDetector == null) {
      _setTrackingMode('Mode degrade: tracking indisponible');
      return;
    }

    _detecting = true;
    try {
      final faces = await _faceDetector!.detect(video);

      if (faces.isEmpty) {
        _noFaceFrames += 1;
        if (_noFaceFrames > 6) {
          _setTrackingMode('Mode degrade: aucun visage detecte');
        }
        return;
      }

      final primaryFace = _selectPrimaryFace(faces);
      final tracked = _trackedFromFaceObject(
        primaryFace,
        vw.toDouble(),
        vh.toDouble(),
      );
      if (tracked == null) {
        _noFaceFrames += 1;
        if (_noFaceFrames > 6) {
          _setTrackingMode('Mode degrade: landmarks indisponibles');
        }
        return;
      }

      _noFaceFrames = 0;
      _setTrackingMode('Suivi visage');
      _smoothTo(tracked, alpha: 0.24);
    } catch (_) {
      _setTrackingMode('Mode degrade: erreur detecteur');
    } finally {
      _detecting = false;
    }
  }

  _TrackedFaceModel? _trackedFromFaceObject(
    dynamic face,
    double videoWidth,
    double videoHeight,
  ) {
    if (face == null) {
      return null;
    }

    final dynamic bbox = face.boundingBox;
    if (bbox == null) {
      return null;
    }

    final x = bbox.left.toDouble();
    final y = bbox.top.toDouble();
    final w = bbox.width.toDouble();
    final h = bbox.height.toDouble();

    if (w <= 1 || h <= 1) {
      return null;
    }

    final centerX = ((x + (w / 2)) / videoWidth).clamp(0.18, 0.82).toDouble();
    final centerY = ((y + (h / 2)) / videoHeight).clamp(0.20, 0.80).toDouble();
    final scale = ((w / videoWidth) / 0.38).clamp(0.78, 1.35).toDouble();

    final landmarks = face.landmarks as List?;

    double leftEyeX = centerX - (0.18 * 0.38 * scale);
    double leftEyeY = centerY - (0.14 * 0.56 * scale);
    double rightEyeX = centerX + (0.18 * 0.38 * scale);
    double rightEyeY = centerY - (0.14 * 0.56 * scale);
    double mouthX = centerX;
    double mouthY = centerY + (0.16 * 0.56 * scale);

    if (landmarks != null && landmarks.isNotEmpty) {
      _NormPoint? leftEye;
      _NormPoint? rightEye;
      _NormPoint? mouth;
      var genericEyeCount = 0;

      for (final landmark in landmarks) {
        if (landmark == null) {
          continue;
        }

        final dynamic landmarkDyn = landmark;
        final type = (landmarkDyn.type?.toString() ?? '').toLowerCase();
        final locations = landmarkDyn.locations as List?;
        final point = _averagePointFromLocations(
          locations,
          videoWidth: videoWidth,
          videoHeight: videoHeight,
        );
        if (point == null) {
          continue;
        }

        if (type.contains('left') && type.contains('eye')) {
          leftEye = point;
          continue;
        }
        if (type.contains('right') && type.contains('eye')) {
          rightEye = point;
          continue;
        }
        if (type.contains('mouth')) {
          mouth = point;
          continue;
        }
        if (type.contains('eye')) {
          if (genericEyeCount == 0) {
            leftEye = point;
          } else if (genericEyeCount == 1) {
            rightEye = point;
          }
          genericEyeCount += 1;
        }
      }

      if (leftEye != null) {
        leftEyeX = leftEye.x;
        leftEyeY = leftEye.y;
      }
      if (rightEye != null) {
        rightEyeX = rightEye.x;
        rightEyeY = rightEye.y;
      }
      if (mouth != null) {
        mouthX = mouth.x;
        mouthY = mouth.y;
      }
    }

    return _TrackedFaceModel(
      centerX: centerX,
      centerY: centerY,
      scale: scale,
      leftEyeX: leftEyeX,
      leftEyeY: leftEyeY,
      rightEyeX: rightEyeX,
      rightEyeY: rightEyeY,
      mouthX: mouthX,
      mouthY: mouthY,
    );
  }

  dynamic _selectPrimaryFace(List<dynamic> faces) {
    dynamic primary = faces.first;
    var primaryArea = _faceArea(primary);

    for (final face in faces.skip(1)) {
      final area = _faceArea(face);
      if (area > primaryArea) {
        primary = face;
        primaryArea = area;
      }
    }

    return primary;
  }

  double _faceArea(dynamic face) {
    if (face == null) {
      return 0;
    }
    final dynamic bbox = face.boundingBox;
    if (bbox == null) {
      return 0;
    }

    final width = (bbox.width as num?)?.toDouble() ?? 0;
    final height = (bbox.height as num?)?.toDouble() ?? 0;
    return width * height;
  }

  _NormPoint? _averagePointFromLocations(
    List? locations, {
    required double videoWidth,
    required double videoHeight,
  }) {
    if (locations == null || locations.isEmpty) {
      return null;
    }

    var sumX = 0.0;
    var sumY = 0.0;
    var count = 0;

    for (final item in locations) {
      if (item == null) {
        continue;
      }
      final dynamic pointDyn = item;
      final x = (pointDyn.x as num?)?.toDouble() ?? 0.0;
      final y = (pointDyn.y as num?)?.toDouble() ?? 0.0;
      if (x <= 0 && y <= 0) {
        continue;
      }
      sumX += x;
      sumY += y;
      count += 1;
    }

    if (count == 0) {
      return null;
    }

    return _NormPoint(
      x: (sumX / count / videoWidth).clamp(0.05, 0.95).toDouble(),
      y: (sumY / count / videoHeight).clamp(0.05, 0.95).toDouble(),
    );
  }

  void _setTrackingMode(String value) {
    if (_trackingMode == value || !mounted) {
      return;
    }
    setState(() {
      _trackingMode = value;
    });
  }

  void _smoothTo(_TrackedFaceModel target, {required double alpha}) {
    final current = _trackedFace.value;
    _trackedFace.value = _TrackedFaceModel(
      centerX: lerpDouble(current.centerX, target.centerX, alpha)!,
      centerY: lerpDouble(current.centerY, target.centerY, alpha)!,
      scale: lerpDouble(current.scale, target.scale, alpha)!,
      leftEyeX: lerpDouble(current.leftEyeX, target.leftEyeX, alpha)!,
      leftEyeY: lerpDouble(current.leftEyeY, target.leftEyeY, alpha)!,
      rightEyeX: lerpDouble(current.rightEyeX, target.rightEyeX, alpha)!,
      rightEyeY: lerpDouble(current.rightEyeY, target.rightEyeY, alpha)!,
      mouthX: lerpDouble(current.mouthX, target.mouthX, alpha)!,
      mouthY: lerpDouble(current.mouthY, target.mouthY, alpha)!,
    );
  }

  void _stopCamera() {
    _trackingTimer?.cancel();
    _trackingTimer = null;

    final tracks = _stream?.getTracks() ?? const <html.MediaStreamTrack>[];
    for (final track in tracks) {
      track.stop();
    }

    _stream = null;
    _videoElement?.srcObject = null;
  }

  @override
  void dispose() {
    _stopCamera();
    _trackedFace.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDegraded = _trackingMode.toLowerCase().contains('mode degrade');

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          color: const Color(0xFFEAE7DE),
        ),
        child: AspectRatio(
          aspectRatio: 16 / 10,
          child: Stack(
            fit: StackFit.expand,
            children: [
              HtmlElementView(viewType: _viewType),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.12),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.1),
                    ],
                  ),
                ),
              ),
              ValueListenableBuilder<_TrackedFaceModel>(
                valueListenable: _trackedFace,
                builder: (context, trackedFace, _) {
                  return _FaceGuideOverlay(trackedFace: trackedFace);
                },
              ),
              Positioned(
                left: 10,
                top: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.24),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isDegraded
                            ? Icons.warning_amber_rounded
                            : Icons.face_retouching_natural,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _trackingMode,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isDegraded)
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.52),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Mode degrade actif: tracking facial indisponible sur ce navigateur.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              if (_starting)
                const Center(
                  child: SizedBox(
                    height: 26,
                    width: 26,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  ),
                ),
              if (_error != null)
                Center(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.58),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaceGuideOverlay extends StatelessWidget {
  const _FaceGuideOverlay({required this.trackedFace});

  final _TrackedFaceModel trackedFace;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(painter: _FaceGuidePainter(trackedFace: trackedFace)),
    );
  }
}

class _FaceGuidePainter extends CustomPainter {
  const _FaceGuidePainter({required this.trackedFace});

  final _TrackedFaceModel trackedFace;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width * trackedFace.centerX,
      size.height * trackedFace.centerY,
    );

    final faceWidth = size.width * 0.38 * trackedFace.scale;
    final faceHeight = size.height * 0.56 * trackedFace.scale;

    final faceRect = Rect.fromCenter(
      center: center,
      width: faceWidth,
      height: faceHeight,
    );

    final facePaint = Paint()
      ..color = AppColors.violet.withValues(alpha: 0.78)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final eyePaint = Paint()
      ..color = AppColors.stableGreen.withValues(alpha: 0.95)
      ..style = PaintingStyle.fill;

    final mouthPaint = Paint()
      ..color = AppColors.riskOrange.withValues(alpha: 0.92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final helperPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.68)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawOval(faceRect, facePaint);

    final leftEye = Offset(
      size.width * trackedFace.leftEyeX,
      size.height * trackedFace.leftEyeY,
    );
    final rightEye = Offset(
      size.width * trackedFace.rightEyeX,
      size.height * trackedFace.rightEyeY,
    );
    final mouthCenter = Offset(
      size.width * trackedFace.mouthX,
      size.height * trackedFace.mouthY,
    );

    canvas.drawCircle(leftEye, 4.2, eyePaint);
    canvas.drawCircle(rightEye, 4.2, eyePaint);

    final mouthRect = Rect.fromCenter(
      center: mouthCenter,
      width: faceRect.width * 0.28,
      height: faceRect.height * 0.09,
    );
    canvas.drawArc(mouthRect, 0.20, 2.75, false, mouthPaint);

    canvas.drawLine(
      Offset(center.dx, faceRect.top),
      Offset(center.dx, faceRect.bottom),
      helperPaint,
    );
    canvas.drawLine(
      Offset(faceRect.left, center.dy),
      Offset(faceRect.right, center.dy),
      helperPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _FaceGuidePainter oldDelegate) {
    return oldDelegate.trackedFace != trackedFace;
  }
}

class _TrackedFaceModel {
  const _TrackedFaceModel({
    required this.centerX,
    required this.centerY,
    required this.scale,
    required this.leftEyeX,
    required this.leftEyeY,
    required this.rightEyeX,
    required this.rightEyeY,
    required this.mouthX,
    required this.mouthY,
  });

  const _TrackedFaceModel.initial()
    : centerX = 0.5,
      centerY = 0.5,
      scale = 1.0,
      leftEyeX = 0.43,
      leftEyeY = 0.42,
      rightEyeX = 0.57,
      rightEyeY = 0.42,
      mouthX = 0.5,
      mouthY = 0.58;

  final double centerX;
  final double centerY;
  final double scale;
  final double leftEyeX;
  final double leftEyeY;
  final double rightEyeX;
  final double rightEyeY;
  final double mouthX;
  final double mouthY;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is _TrackedFaceModel &&
        other.centerX == centerX &&
        other.centerY == centerY &&
        other.scale == scale &&
        other.leftEyeX == leftEyeX &&
        other.leftEyeY == leftEyeY &&
        other.rightEyeX == rightEyeX &&
        other.rightEyeY == rightEyeY &&
        other.mouthX == mouthX &&
        other.mouthY == mouthY;
  }

  @override
  int get hashCode => Object.hash(
    centerX,
    centerY,
    scale,
    leftEyeX,
    leftEyeY,
    rightEyeX,
    rightEyeY,
    mouthX,
    mouthY,
  );
}

class _NormPoint {
  const _NormPoint({required this.x, required this.y});

  final double x;
  final double y;
}
