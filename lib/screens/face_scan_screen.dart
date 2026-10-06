import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'products_screen.dart';

class FaceScanScreen extends StatefulWidget {
  const FaceScanScreen({super.key});
  @override
  State<FaceScanScreen> createState() => _FaceScanScreenState();
}

class _FaceScanScreenState extends State<FaceScanScreen> {
  CameraController? _cam;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final cams = await availableCameras();
      final cam = cams.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
          orElse: () => cams.first);
      final c = CameraController(cam, ResolutionPreset.medium,
          enableAudio: false);
      await c.initialize();
      if (!mounted) return;
      setState(() => _cam = c);
    } catch (e) {
      if (mounted) setState(() => _error = 'Cannot open the camera.Permission needed.');
    }
  }

  @override
  void dispose() {
    _cam?.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    if (_busy || _cam == null) return;
    setState(() => _busy = true);
    try {
      final photo = await _cam!.takePicture();
      final bytes = await photo.readAsBytes();
      final r = await ApiService().analyzeSkin(bytes);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ProductsScreen(
            skinType: r['type'],
            title: 'Your skin result',
            header: SkinResultCard(r),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Scan failed. Try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0),
      extendBodyBehindAppBar: true,
      body: _error != null
          ? Center(
              child: Text(_error!, style: const TextStyle(color: Colors.white)))
          : _cam == null
              ? const Center(child: CircularProgressIndicator())
              : Stack(fit: StackFit.expand, children: [
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
                        'Keep your face inside the frame. Use good light, and no makeup.',
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
                              border: Border.all(
                                  color: Colors.white54, width: 6)),
                        ),
                      ),
                    ),
                  ),
                  if (_busy)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 12),
                            Text('Analyzing your skin...',
                                style: TextStyle(color: Colors.white)),
                          ])),
                    ),
                ]),
    );
  }
}

class SkinResultCard extends StatelessWidget {
  final Map<String, String> r;
  const SkinResultCard(this.r, {super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: const Color(0xFFF5EFEC),
          borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Your skin type: ${r['type']}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        if ((r['notes'] ?? '').isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(r['notes']!, style: const TextStyle(fontSize: 11)),
        ],
        const SizedBox(height: 6),
        Text(
            r['demo'] == 'true'
                ? 'DEMO MODE: not an actual result.'
                : 'This is just an estimate, not medical diagnosis.',
            style: TextStyle(
                fontSize: 10,
                color: r['demo'] == 'true' ? Colors.red : Colors.grey)),
        const SizedBox(height: 6),
        const Text('Recommended products',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
