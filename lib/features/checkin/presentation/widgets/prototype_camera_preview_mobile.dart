import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show lerpDouble;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

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
  bool _isInitializing = false;
  bool _hasError = false;
  String? _errorMessage;

  bool _isProcessingImage = false;
  int _frameCounter = 0;
  int _noFaceFrames = 0;
  String _trackingMode = 'Initialisation tracking';

  final ValueNotifier<_TrackedFaceModel> _trackedFace = ValueNotifier(
    const _TrackedFaceModel.initial(),
  );

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
      enableLandmarks: true,
      enableContours: false,
      enableClassification: false,
      minFaceSize: 0.12,
    ),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _releaseCamera();
      return;
    }

    if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    if (_isInitializing) {
      return;
    }

    final existing = _controller;
    if (existing != null && existing.value.isInitialized) {
      return;
    }

    _isInitializing = true;

    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        if (!mounted) {
          return;
        }
        setState(() {
          _hasError = true;
          _errorMessage = 'Aucune caméra trouvée sur cet appareil.';
        });
        return;
      }

      CameraDescription selectedCamera;
      try {
        selectedCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
        );
      } catch (_) {
        selectedCamera = cameras.first;
      }

      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();
      await controller.startImageStream(_processCameraImage);

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _isCameraInitialized = true;
        _hasError = false;
        _errorMessage = null;
      });
      _setTrackingMode('Suivi visage actif');
    } catch (e) {
      if (!mounted) {
        return;
      }

      var errorMsg = 'Erreur lors de l\'initialisation de la caméra';
      final text = e.toString();

      if (text.contains('Permission')) {
        errorMsg =
            'Permission caméra refusée. Veuillez vérifier les paramètres.';
      } else if (text.contains('socket')) {
        errorMsg = 'Caméra indisponible. Redémarrez l\'app.';
      } else {
        final safeText = text.length > 80 ? text.substring(0, 80) : text;
        errorMsg = 'Erreur: $safeText';
      }

      setState(() {
        _hasError = true;
        _errorMessage = errorMsg;
        _isCameraInitialized = false;
      });
      _setTrackingMode('Tracking indisponible');
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> _releaseCamera() async {
    final controller = _controller;
    _controller = null;

    if (controller != null) {
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
      await controller.dispose();
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isCameraInitialized = false;
    });
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (!mounted || _isProcessingImage) {
      return;
    }

    _frameCounter += 1;
    if (_frameCounter.isOdd) {
      return;
    }

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    _isProcessingImage = true;

    try {
      final inputImage = _buildInputImage(image, controller);
      if (inputImage == null) {
        _setTrackingMode('Mode approximation');
        return;
      }

      final faces = await _faceDetector.processImage(inputImage);
      if (faces.isEmpty) {
        _noFaceFrames += 1;
        if (_noFaceFrames > 6) {
          _setTrackingMode('Aucun visage detecte');
        }
        return;
      }

      _noFaceFrames = 0;
      final primaryFace = _selectPrimaryFace(faces);
      final tracked = _trackedFromFace(
        primaryFace,
        inputImage.metadata!,
        controller.description.lensDirection,
      );

      _smoothTo(tracked, alpha: 0.28);
      _setTrackingMode('Suivi visage actif');
    } catch (_) {
      _setTrackingMode('Mode approximation');
    } finally {
      _isProcessingImage = false;
    }
  }

  InputImage? _buildInputImage(CameraImage image, CameraController controller) {
    final rotation = _rotationFromController(controller);
    final format = InputImageFormatValue.fromRawValue(image.format.raw);

    if (format == null ||
        (format != InputImageFormat.yuv420 &&
            format != InputImageFormat.bgra8888)) {
      return null;
    }

    final bytes = _concatenatePlanes(image.planes);
    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      format: format,
      bytesPerRow: image.planes.first.bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final builder = BytesBuilder(copy: false);
    for (final plane in planes) {
      builder.add(plane.bytes);
    }
    return builder.toBytes();
  }

  InputImageRotation _rotationFromController(CameraController controller) {
    final camera = controller.description;
    var rotationCompensation = 0;

    switch (controller.value.deviceOrientation) {
      case DeviceOrientation.portraitUp:
        rotationCompensation = 0;
      case DeviceOrientation.landscapeLeft:
        rotationCompensation = 90;
      case DeviceOrientation.portraitDown:
        rotationCompensation = 180;
      case DeviceOrientation.landscapeRight:
        rotationCompensation = 270;
    }

    int rotation;
    if (camera.lensDirection == CameraLensDirection.front) {
      rotation = (camera.sensorOrientation + rotationCompensation) % 360;
    } else {
      rotation = (camera.sensorOrientation - rotationCompensation + 360) % 360;
    }

    return InputImageRotationValue.fromRawValue(rotation) ??
        InputImageRotation.rotation0deg;
  }

  Face _selectPrimaryFace(List<Face> faces) {
    Face primary = faces.first;
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

  double _faceArea(Face face) {
    return face.boundingBox.width * face.boundingBox.height;
  }

  _TrackedFaceModel _trackedFromFace(
    Face face,
    InputImageMetadata metadata,
    CameraLensDirection lensDirection,
  ) {
    final bbox = face.boundingBox;

    final topLeft = _mapToNormalized(
      Offset(bbox.left, bbox.top),
      metadata.size,
      metadata.rotation,
      lensDirection,
    );
    final topRight = _mapToNormalized(
      Offset(bbox.right, bbox.top),
      metadata.size,
      metadata.rotation,
      lensDirection,
    );
    final bottomLeft = _mapToNormalized(
      Offset(bbox.left, bbox.bottom),
      metadata.size,
      metadata.rotation,
      lensDirection,
    );
    final bottomRight = _mapToNormalized(
      Offset(bbox.right, bbox.bottom),
      metadata.size,
      metadata.rotation,
      lensDirection,
    );

    final xs = [topLeft.x, topRight.x, bottomLeft.x, bottomRight.x];
    final ys = [topLeft.y, topRight.y, bottomLeft.y, bottomRight.y];

    final minX = xs.reduce(math.min);
    final maxX = xs.reduce(math.max);
    final minY = ys.reduce(math.min);
    final maxY = ys.reduce(math.max);

    final centerX = ((minX + maxX) / 2).clamp(0.12, 0.88).toDouble();
    final centerY = ((minY + maxY) / 2).clamp(0.16, 0.86).toDouble();
    final faceWidth = (maxX - minX).clamp(0.10, 0.78).toDouble();
    final scale = (faceWidth / 0.38).clamp(0.72, 1.48).toDouble();

    final leftEyePoint = face.landmarks[FaceLandmarkType.leftEye]?.position;
    final rightEyePoint = face.landmarks[FaceLandmarkType.rightEye]?.position;
    final mouthBottom = face.landmarks[FaceLandmarkType.bottomMouth]?.position;

    var leftEyeX = centerX - (0.18 * 0.38 * scale);
    var leftEyeY = centerY - (0.14 * 0.56 * scale);
    var rightEyeX = centerX + (0.18 * 0.38 * scale);
    var rightEyeY = centerY - (0.14 * 0.56 * scale);
    var mouthX = centerX;
    var mouthY = centerY + (0.15 * 0.56 * scale);

    if (leftEyePoint != null) {
      final p = _mapToNormalized(
        Offset(leftEyePoint.x.toDouble(), leftEyePoint.y.toDouble()),
        metadata.size,
        metadata.rotation,
        lensDirection,
      );
      leftEyeX = p.x;
      leftEyeY = p.y;
    }

    if (rightEyePoint != null) {
      final p = _mapToNormalized(
        Offset(rightEyePoint.x.toDouble(), rightEyePoint.y.toDouble()),
        metadata.size,
        metadata.rotation,
        lensDirection,
      );
      rightEyeX = p.x;
      rightEyeY = p.y;
    }

    if (mouthBottom != null) {
      final p = _mapToNormalized(
        Offset(mouthBottom.x.toDouble(), mouthBottom.y.toDouble()),
        metadata.size,
        metadata.rotation,
        lensDirection,
      );
      mouthX = p.x;
      mouthY = p.y;
    }

    return _TrackedFaceModel(
      centerX: centerX,
      centerY: centerY,
      scale: scale,
      leftEyeX: leftEyeX.clamp(0.04, 0.96).toDouble(),
      leftEyeY: leftEyeY.clamp(0.04, 0.96).toDouble(),
      rightEyeX: rightEyeX.clamp(0.04, 0.96).toDouble(),
      rightEyeY: rightEyeY.clamp(0.04, 0.96).toDouble(),
      mouthX: mouthX.clamp(0.04, 0.96).toDouble(),
      mouthY: mouthY.clamp(0.04, 0.96).toDouble(),
    );
  }

  _NormPoint _mapToNormalized(
    Offset source,
    Size imageSize,
    InputImageRotation rotation,
    CameraLensDirection lensDirection,
  ) {
    final rotated = _rotatePoint(source, imageSize, rotation);
    final orientedSize = _orientedSize(imageSize, rotation);

    var x = (rotated.dx / orientedSize.width).clamp(0.0, 1.0).toDouble();
    final y = (rotated.dy / orientedSize.height).clamp(0.0, 1.0).toDouble();

    if (lensDirection == CameraLensDirection.front) {
      x = 1 - x;
    }

    return _NormPoint(
      x: x.clamp(0.02, 0.98).toDouble(),
      y: y.clamp(0.02, 0.98).toDouble(),
    );
  }

  Offset _rotatePoint(
    Offset point,
    Size imageSize,
    InputImageRotation rotation,
  ) {
    switch (rotation) {
      case InputImageRotation.rotation0deg:
        return point;
      case InputImageRotation.rotation90deg:
        return Offset(point.dy, imageSize.width - point.dx);
      case InputImageRotation.rotation180deg:
        return Offset(imageSize.width - point.dx, imageSize.height - point.dy);
      case InputImageRotation.rotation270deg:
        return Offset(imageSize.height - point.dy, point.dx);
    }
  }

  Size _orientedSize(Size imageSize, InputImageRotation rotation) {
    switch (rotation) {
      case InputImageRotation.rotation90deg:
      case InputImageRotation.rotation270deg:
        return Size(imageSize.height, imageSize.width);
      case InputImageRotation.rotation0deg:
      case InputImageRotation.rotation180deg:
        return imageSize;
    }
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

  void _setTrackingMode(String value) {
    if (_trackingMode == value || !mounted) {
      return;
    }
    setState(() {
      _trackingMode = value;
    });
  }

  double _previewAspectRatio() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return 3 / 4;
    }

    final previewSize = controller.value.previewSize;
    if (previewSize != null &&
        previewSize.width > 0 &&
        previewSize.height > 0) {
      return previewSize.height / previewSize.width;
    }

    final ratio = controller.value.aspectRatio;
    if (ratio <= 0) {
      return 3 / 4;
    }

    return 1 / ratio;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _releaseCamera();
    _trackedFace.dispose();
    _faceDetector.close();
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
          aspectRatio: _previewAspectRatio(),
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
                    'Camera indisponible',
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
          aspectRatio: _previewAspectRatio(),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 34,
                  height: 34,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.violet),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Initialisation camera...',
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
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    final aspectRatio = _previewAspectRatio();
    final isDegraded =
        _trackingMode.toLowerCase().contains('approximation') ||
        _trackingMode.toLowerCase().contains('aucun visage');

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ColoredBox(
          color: Colors.black,
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(controller),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.08),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.06),
                      ],
                    ),
                  ),
                ),
                ValueListenableBuilder<_TrackedFaceModel>(
                  valueListenable: _trackedFace,
                  builder: (context, trackedFace, _) {
                    return CustomPaint(
                      painter: _FaceGuidePainter(trackedFace: trackedFace),
                    );
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
                        color: Colors.white.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isDegraded
                              ? Icons.track_changes_outlined
                              : Icons.face_retouching_natural,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _trackingMode,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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

    final faceGlowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = AppColors.violet.withValues(alpha: 0.22);
    final facePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = AppColors.violet.withValues(alpha: 0.9);

    final eyePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.stableGreen.withValues(alpha: 0.96);

    final mouthPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = AppColors.riskOrange.withValues(alpha: 0.95);

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: faceRect.width * 1.06,
        height: faceRect.height * 1.06,
      ),
      faceGlowPaint,
    );
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

    final eyeRadius = math.max(3.3, faceRect.width * 0.033);
    canvas.drawCircle(leftEye, eyeRadius, eyePaint);
    canvas.drawCircle(rightEye, eyeRadius, eyePaint);

    final mouthRect = Rect.fromCenter(
      center: mouthCenter,
      width: faceRect.width * 0.30,
      height: faceRect.height * 0.10,
    );
    canvas.drawArc(mouthRect, 0.18, 2.78, false, mouthPaint);
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
