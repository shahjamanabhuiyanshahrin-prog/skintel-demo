import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/onboarding_service.dart';
import '../services/scan_service.dart';
import 'skin_result_screen.dart';

enum _CamState { intro, loading, ready, denied, blocked, notFound, failed }

class FaceScanScreen extends StatefulWidget {
  const FaceScanScreen({super.key});
  @override
  State<FaceScanScreen> createState() => _FaceScanScreenState();
}

class _FaceScanScreenState extends State<FaceScanScreen> {
  CameraController? _cam;
  _CamState _state = _CamState.intro;
  bool _busy = false;

  @override
  void dispose() {
    _cam?.dispose();
    super.dispose();
  }

  // Opens the camera. This is also what triggers the permission prompt.
  Future<void> _init() async {
    setState(() => _state = _CamState.loading);
    try {
      final cams = await availableCameras();
      if (cams.isEmpty) {
        if (mounted) setState(() => _state = _CamState.notFound);
        return;
      }
      final cam = cams.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
          orElse: () => cams.first);
      await _cam?.dispose();
      final c = CameraController(cam, ResolutionPreset.medium,
          enableAudio: false);
      await c.initialize();
      if (!mounted) return;
      setState(() {
        _cam = c;
        _state = _CamState.ready;
      });
    } on CameraException catch (e) {
      if (!mounted) return;
      switch (e.code) {
        case 'CameraAccessDenied':
        case 'cameraPermission':
          setState(() => _state = _CamState.denied);
          break;
        case 'CameraAccessDeniedWithoutPrompt':
        case 'CameraAccessRestricted':
          setState(() => _state = _CamState.blocked);
          break;
        default:
          setState(() => _state = _CamState.failed);
      }
    } catch (_) {
      if (mounted) setState(() => _state = _CamState.failed);
    }
  }

  // Skin type the user picked in onboarding (null if missing or not usable).
  Future<String?> _savedSkinType() async {
    try {
      final data = await OnboardingService.getOnboardingData();
      final t = data?['skin_type']?.toString();
      const usable = ['Dry', 'Oily', 'Normal', 'Combination'];
      return usable.contains(t) ? t : null;
    } catch (_) {
      return null;
    }
  }

  // Take a photo with the camera.
  Future<void> _scan() async {
    if (_busy || _cam == null) return;
    try {
      final photo = await _cam!.takePicture();
      await _process(photo);
    } catch (e) {
      _failed();
    }
  }

  // Choose a photo from the gallery (works when the camera does not).
  Future<void> _pickPhoto() async {
    if (_busy) return;
    try {
      final photo = await ImagePicker()
          .pickImage(source: ImageSource.gallery, imageQuality: 90);
      if (photo == null) return; // user cancelled
      await _process(photo);
    } catch (e) {
      _failed();
    }
  }

  void _failed() {
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scan failed. Please try again.')));
  }

  // Sends the photo to the backend and opens the result screen.
  Future<void> _process(XFile photo) async {
    if (!mounted) return;
    setState(() => _busy = true);
    try {
      final res = await ScanService.scanFace(photo);

      // If the light is not good, show a warning and no result
      if (res['light_ok'].toString() == 'false') {
        if (!mounted) return;
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'].toString()),
            duration: const Duration(seconds: 5),
          ),
        );
        return;
      }

      final scanType = res['skin_type'].toString();
      final notes = (res['notes'] ?? '').toString();
      final savedType = await _savedSkinType();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SkinResultScreen(
            scanType: scanType,
            savedType: savedType,
            notes: notes,
          ),
        ),
      );
    } catch (e) {
      _failed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ready = _state == _CamState.ready && _cam != null;
    return Scaffold(
      backgroundColor: ready ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: ready ? Colors.white : Colors.black,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: ready ? _scanner() : _statusView(),
    );
  }

  // ---------- Permission / status screens ----------
  Widget _statusView() {
    switch (_state) {
      case _CamState.loading:
        return const Center(child: CircularProgressIndicator());
      case _CamState.intro:
        return _message(
          Icons.camera_alt_outlined,
          'Camera access needed',
          'Skintel uses your camera to scan your face and detect your skin type. Your photo is only used for the scan.',
          'Allow camera',
        );
      case _CamState.denied:
        return _message(
          Icons.no_photography_outlined,
          'Camera permission denied',
          'We need camera access to scan your skin. Please allow it when asked.',
          'Try again',
        );
      case _CamState.blocked:
        return _message(
          Icons.block,
          'Camera access is blocked',
          'Camera access is turned off for this app. Enable it in your browser or device settings, then try again.',
          'Try again',
        );
      case _CamState.notFound:
        return _message(
          Icons.videocam_off_outlined,
          'No camera found',
          'We could not find a camera on this device.',
          'Try again',
        );
      default:
        return _message(
          Icons.error_outline,
          'Something went wrong',
          'We could not open the camera. Please try again.',
          'Try again',
        );
    }
  }

  Widget _message(IconData icon, String title, String text, String button) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 56, color: Colors.black87),
          const SizedBox(height: 16),
          Text(title,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _init,
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24))),
            child: Text(button),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _busy ? null : _pickPhoto,
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Choose a photo instead'),
          ),
          if (_busy) ...[
            const SizedBox(height: 12),
            const CircularProgressIndicator(),
            const SizedBox(height: 8),
            const Text('Analyzing your skin...'),
          ],
        ]),
      ),
    );
  }

  // ---------- Camera view ----------
  Widget _scanner() {
    return Stack(fit: StackFit.expand, children: [
      CameraPreview(_cam!),
      Center(
        child: Container(
          width: 240,
          height: 300,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(140)),
        ),
      ),
      const Positioned(
        top: 100,
        left: 24,
        right: 24,
        child: Text(
            'Face a window for soft light. No makeup or cream. Look straight at the camera.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 13)),
      ),
      Positioned(
        bottom: 40,
        left: 0,
        right: 0,
        child: Center(
          child: GestureDetector(
            onTap: _scan,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.white54, width: 6)),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 56,
        right: 32,
        child: IconButton(
          onPressed: _busy ? null : _pickPhoto,
          icon: const Icon(Icons.photo_library_outlined,
              color: Colors.white, size: 30),
          tooltip: 'Choose a photo',
        ),
      ),
      if (_busy)
        Container(
          color: Colors.black54,
          child: const Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 12),
            Text('Analyzing your skin...',
                style: TextStyle(color: Colors.white)),
          ])),
        ),
    ]);
  }
}