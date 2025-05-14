import 'package:flutter/material.dart';

class CampaignImageViewer extends StatefulWidget {
  final String imageUrl;
  final String title;

  const CampaignImageViewer({
    Key? key,
    required this.imageUrl,
    required this.title,
  }) : super(key: key);

  @override
  State<CampaignImageViewer> createState() => _CampaignImageViewerState();
}

class _CampaignImageViewerState extends State<CampaignImageViewer> {
  late TransformationController _controller;
  TapDownDetails? _doubleTapDetails;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = TransformationController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_doubleTapDetails == null) {
      return;
    }

    if (_controller.value != Matrix4.identity()) {
      // Reset zoom if already zoomed in
      _controller.value = Matrix4.identity();
    } else {
      // Zoom in to tap location
      final position = _doubleTapDetails!.localPosition;
      final double scale = 3.0;

      // For zooming to the position tapped
      final x = -position.dx * (scale - 1);
      final y = -position.dy * (scale - 1);

      final zoomed = Matrix4.identity()
        ..translate(x, y)
        ..scale(scale);

      _controller.value = zoomed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final accentColor = const Color(0xFFFF5722);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(color: textColor),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Stack(
        children: [
          // Image with interactive viewer
          Center(
            child: GestureDetector(
              onDoubleTapDown: _handleDoubleTapDown,
              onDoubleTap: _handleDoubleTap,
              child: InteractiveViewer(
                transformationController: _controller,
                minScale: 0.5,
                maxScale: 4.0,
                child: Stack(
                  children: [
                    // Loading indicator
                    if (_isLoading)
                      Center(
                        child: CircularProgressIndicator(color: accentColor),
                      ),

                    // Error widget
                    if (_hasError)
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.broken_image_rounded,
                              size: 64,
                              color: textColor.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load image',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isLoading = true;
                                  _hasError = false;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),

                    // Image
                    Image.network(
                      widget.imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          // Loading complete
                          if (_isLoading) {
                            Future.microtask(() {
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            });
                          }
                          return child;
                        }
                        return Container();
                      },
                      errorBuilder: (context, error, stackTrace) {
                        if (!_hasError) {
                          Future.microtask(() {
                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                                _hasError = true;
                              });
                            }
                          });
                        }
                        return Container();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Instructions
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Double tap to zoom • Pinch to zoom in/out',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
