import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class PrototypeCameraPreview extends StatefulWidget {
  const PrototypeCameraPreview({super.key});

  @override
  State<PrototypeCameraPreview> createState() => _PrototypeCameraPreviewState();
}

class _PrototypeCameraPreviewState extends State<PrototypeCameraPreview>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    if (_isCameraInitialized) {
      return;
    }

    try {
      // Get available cameras
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Aucune caméra trouvée sur cet appareil.';
        });
        return;
      }

      // Find front camera (preferred for facial tracking)
      CameraDescription? frontCamera;
      try {
        frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
        );
      } catch (_) {
        // Fallback to first camera if front is not found
        frontCamera = cameras.first;
      }

      // Create and initialize controller
      _controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
        _hasError = false;
      });
    } catch (e) {
      if (!mounted) return;

      String errorMsg = 'Erreur lors de l\'initialisation de la caméra';

      if (e.toString().contains('Permission')) {
        errorMsg =
            'Permission caméra refusée. Veuillez vérifier les paramètres.';
      } else if (e.toString().contains('socket')) {
        errorMsg = 'Caméra indisponible. Redémarrez l\'app.';
      } else {
        errorMsg = 'Erreur: ${e.toString().substring(0, 60)}...';
      }

      setState(() {
        _hasError = true;
        _errorMessage = errorMsg;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorState();
    }

    if (!_isCameraInitialized || _controller == null) {
      return _buildLoadingState();
    }

    return _buildCameraPreview();
  }

  Widget _buildErrorState() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFEAE7DE),
          border: Border.all(color: AppColors.border),
        ),
        child: AspectRatio(
          aspectRatio: 16 / 10,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.videocam_off_outlined,
                    size: 42,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Caméra indisponible',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFEAE7DE),
          border: Border.all(color: AppColors.border),
        ),
        child: AspectRatio(
          aspectRatio: 16 / 10,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.violet),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Initialisation caméra...',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Camera preview - use FittedBox to avoid compression
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.previewSize!.width,
                height: _controller!.value.previewSize!.height,
                child: CameraPreview(_controller!),
              ),
            ),
            // Static facial overlay (centered, non-tracking)
            Center(
              child: CustomPaint(
                painter: _SimpleFaceOverlayPainter(),
                size: Size.infinite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple static facial overlay for mobile (non-tracking)
class _SimpleFaceOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Scale oval to fit the canvas
    final ovalWidth = size.width * 0.4;
    final ovalHeight = size.height * 0.5;

    // Draw face contour (oval)
    final facePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = const Color(0xFF7C3AED); // violet

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: ovalWidth,
        height: ovalHeight,
      ),
      facePaint,
    );

    // Draw left eye
    final eyePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFF10B981); // green

    final eyeRadius = size.width * 0.04;
    final eyeOffsetX = ovalWidth * 0.25;
    final eyeOffsetY = ovalHeight * 0.25;

    canvas.drawCircle(
      Offset(centerX - eyeOffsetX, centerY - eyeOffsetY),
      eyeRadius,
      eyePaint,
    );

    // Draw right eye
    canvas.drawCircle(
      Offset(centerX + eyeOffsetX, centerY - eyeOffsetY),
      eyeRadius,
      eyePaint,
    );

    // Draw mouth (simple arc)
    final mouthPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFFFB923C); // orange

    final mouthRect = Rect.fromCenter(
      center: Offset(centerX, centerY + eyeOffsetY + size.height * 0.05),
      width: size.width * 0.15,
      height: size.width * 0.1,
    );

    canvas.drawArc(mouthRect, 0, 3.14159, false, mouthPaint);
  }

  @override
  bool shouldRepaint(_SimpleFaceOverlayPainter oldDelegate) => false;
}
