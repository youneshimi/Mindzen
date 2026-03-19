// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
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
  bool _starting = true;
  String? _error;

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

    _startCamera();
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

  void _stopCamera() {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              const _FaceGuideOverlay(),
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
  const _FaceGuideOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(child: CustomPaint(painter: _FaceGuidePainter()));
  }
}

class _FaceGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final faceRect = Rect.fromCenter(
      center: center,
      width: size.width * 0.38,
      height: size.height * 0.56,
    );

    final facePaint = Paint()
      ..color = AppColors.violet.withValues(alpha: 0.78)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final pointPaint = Paint()
      ..color = AppColors.stableGreen.withValues(alpha: 0.95)
      ..style = PaintingStyle.fill;

    final mouthPaint = Paint()
      ..color = AppColors.riskOrange.withValues(alpha: 0.92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final helperPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawOval(faceRect, facePaint);

    final eyeYOffset = faceRect.height * 0.14;
    final eyeXOffset = faceRect.width * 0.18;

    final leftEye = Offset(center.dx - eyeXOffset, center.dy - eyeYOffset);
    final rightEye = Offset(center.dx + eyeXOffset, center.dy - eyeYOffset);
    final mouthCenter = Offset(center.dx, center.dy + faceRect.height * 0.16);

    canvas.drawCircle(leftEye, 4, pointPaint);
    canvas.drawCircle(rightEye, 4, pointPaint);

    final mouthRect = Rect.fromCenter(
      center: mouthCenter,
      width: faceRect.width * 0.26,
      height: faceRect.height * 0.08,
    );
    canvas.drawArc(mouthRect, 0.18, 2.8, false, mouthPaint);

    canvas.drawLine(
      Offset(center.dx, faceRect.top),
      Offset(center.dx, faceRect.bottom),
      helperPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
