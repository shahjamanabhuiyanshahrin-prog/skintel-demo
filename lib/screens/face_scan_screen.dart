import 'dart:convert';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:camera/camera.dart' show XFile;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:web/web.dart' as web;

import '../services/onboarding_service.dart';
import '../services/scan_service.dart';
import 'skin_result_screen.dart';

enum _CamState { intro, loading, ready, failed }

int _viewCounter = 0;

class FaceScanScreen extends StatefulWidget {
  const FaceScanScreen({super.key});
  @override
  State<FaceScanScreen> createState() => _FaceScanScreenState();
}

class _FaceScanScreenState extends State<FaceScanScreen> {
  web.MediaStream? _stream;
  web.HTMLVideoElement? _video;
  String _viewType = '';
  _CamState _state = _CamState.intro;
  bool _busy = false;
  String _err = '';

  @override
  void dispose() {
    _stopCamera();
    super.dispose();
  }

  void _stopCamera() {
    try {
      final s = _stream;
      if (s != null) {
        for (final t in s.getTracks().toDart) {
          t.stop();
        }
      }
    } catch (_) {}
    _stream = null;
    _video = null;
  }

  // Opens the camera using the browser directly.
  Future<void> _init() async {
    setState(() {
      _state = _CamState.loading;
      _err = '';
    });
    _stopCamera();

    try {
      final constraints = web.MediaStreamConstraints(
        video: true.toJS,
        audio: false.toJS,
      );
      final stream = await web.window.navigator.mediaDevices
          .getUserMedia(constraints)
          .toDart;

      final video =
          web.document.createElement('video') as web.HTMLVideoElement;
      video.autoplay = true;
      video.muted = true;
      video.setAttribute('playsinline', 'true');
      video.srcObject = stream;
      video.style.setProperty('width', '100%');
      video.style.setProperty('height', '100%');
      video.style.setProperty('object-fit', 'cover');
      video.style.setProperty('transform', 'scaleX(-1)');

      _viewCounter++;
      final viewType = 'skintel-camera-$_viewCounter';
      ui_web.platformViewRegistry.registerViewFactory(viewType, (int id) => video);

      try {
        await video.play().toDart;
      } catch (_) {}

      if (!mounted) {
        for (final t in stream.getTracks().toDart) {
          t.stop();
        }
        return;
      }
      setState(() {
        _stream = stream;
        _video = video;
        _viewType = viewType;
        _state = _CamState.ready;
      });
      debugPrint('CAMERA OK (browser getUserMedia)');
    } catch (e) {
      debugPrint('CAMERA ERROR: $e');
      if (!mounted) return;
      setState(() {
        _err = e.toString();
        _state = _CamState.failed;
      });
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

  // Take a photo from the live video.
  Future<void> _scan() async {
    final v = _video;
    if (_busy || v == null) return;
    try {
      final w = v.videoWidth;
      final h = v.videoHeight;
      if (w == 0 || h == 0) {
        throw Exception('Camera is not ready yet');
      }
      final canvas =
          web.document.createElement('canvas') as web.HTMLCanvasElement;
      canvas.width = w;
      canvas.height = h;
      final ctx = canvas.getContext('2d')! as web.CanvasRenderingContext2D;
      ctx.drawImage(v, 0, 0);
      final dataUrl = canvas.toDataURL('image/jpeg', 0.92.toJS);
      final bytes = base64Decode(dataUrl.split(',').last);
      final photo =
          XFile.fromData(bytes, mimeType: 'image/jpeg', name: 'face.jpg');
      await _process(photo);
    } catch (e) {
      debugPrint('TAKE PICTURE ERROR: $e');
      _failed();
    }
  }

  // Choose a photo from the gallery.
  Future<void> _pickPhoto() async {
    if (_busy) return;
    try {
      final photo = await ImagePicker()
          .pickImage(source: ImageSource.gallery, imageQuality: 90);
      if (photo == null) return; // user cancelled
      await _process(photo);
    } catch (e) {
      debugPrint('PICK PHOTO ERROR: $e');
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
      _stopCamera();
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
      debugPrint('SCAN ERROR: $e');
      _failed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ready = _state == _CamState.ready && _video != null;
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

  // ---------- Status screens ----------
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
      child: SingleChildScrollView(
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
          if (_err.isNotEmpty) ...[
            const SizedBox(height: 12),
            SelectableText('Error: $_err',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.w600)),
          ],
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
      HtmlElementView(viewType: _viewType),
      IgnorePointer(
        child: Center(
          child: Container(
            width: 240,
            height: 300,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(140)),
          ),
        ),
      ),
      const Positioned(
        top: 100,
        left: 24,
        right: 24,
        child: IgnorePointer(
          child: Text(
              'Face a window for soft light. No makeup or cream. Look straight at the camera.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 13)),
        ),
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