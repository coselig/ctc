import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:async';
import '../models/photo_record.dart';

class FloorPlanView extends StatelessWidget {
  final String imageUrl;
  final List<PhotoRecord> records;
  final PhotoRecord? selectedRecord;
  final Offset? selectedPoint;
  final Function(TapUpDetails) onTapUp;
  final bool isRecordMode;

  const FloorPlanView({
    super.key,
    required this.imageUrl,
    required this.records,
    required this.onTapUp,
    this.selectedRecord,
    this.selectedPoint,
    this.isRecordMode = false,
  });

  Future<Size> _getImageSize(String imageUrl) async {
    final image = NetworkImage(imageUrl);
    final completer = Completer<Size>();

    final imageStream = image.resolve(ImageConfiguration.empty);
    final listener = ImageStreamListener(
      (imageInfo, synchronousCall) {
        final size = Size(
          imageInfo.image.width.toDouble(),
          imageInfo.image.height.toDouble(),
        );
        completer.complete(size);
      },
      onError: (exception, stackTrace) {
        completer.completeError(exception);
      },
    );

    imageStream.addListener(listener);
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // 圖片層
            FutureBuilder<Size>(
              future: _getImageSize(imageUrl),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final imageSize = snapshot.data!;
                final containerRatio =
                    constraints.maxWidth / constraints.maxHeight;
                final imageRatio = imageSize.width / imageSize.height;

                double scale;
                double actualWidth;
                double actualHeight;
                double offsetX = 0;
                double offsetY = 0;

                if (containerRatio > imageRatio) {
                  // 容器較寬，以高度為基準
                  scale = constraints.maxHeight / imageSize.height;
                  actualHeight = constraints.maxHeight;
                  actualWidth = imageSize.width * scale;
                  offsetX = (constraints.maxWidth - actualWidth) / 2;
                } else {
                  // 容器較高，以寬度為基準
                  scale = constraints.maxWidth / imageSize.width;
                  actualWidth = constraints.maxWidth;
                  actualHeight = imageSize.height * scale;
                  offsetY = (constraints.maxHeight - actualHeight) / 2;
                }

                return Stack(
                  children: [
                    Positioned(
                      left: offsetX,
                      top: offsetY,
                      width: actualWidth,
                      height: actualHeight,
                      child: GestureDetector(
                        onTapUp: (details) {
                          final localPosition = details.localPosition;
                          // 將點擊位置轉換為原始圖片座標
                          final originalX = localPosition.dx / scale;
                          final originalY = localPosition.dy / scale;

                          // 確保點擊在圖片範圍內
                          if (originalX >= 0 &&
                              originalX <= imageSize.width &&
                              originalY >= 0 &&
                              originalY <= imageSize.height) {
                            final newDetails = TapUpDetails(
                              kind: PointerDeviceKind.touch,
                              globalPosition: Offset(originalX, originalY),
                            );
                            onTapUp(newDetails);
                          }
                        },
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.fill,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(child: Text('載入設計圖失敗'));
                          },
                        ),
                      ),
                    ),
                    // 標記點層
                    ...records.map((record) {
                      if (record.floorPlanPath != imageUrl)
                        return const SizedBox();

                      // 計算標記點在螢幕上的位置
                      double screenX = (record.point.dx * scale) + offsetX;
                      double screenY = (record.point.dy * scale) + offsetY;

                      return Positioned(
                        left: screenX - 8, // 8 是標記點寬度的一半
                        top: screenY - 8, // 8 是標記點高度的一半
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: record == selectedRecord
                                ? Colors.red
                                : Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),

                    // 臨時選擇點
                    if (selectedPoint != null && isRecordMode)
                      Positioned(
                        left: (selectedPoint!.dx * scale) + offsetX - 8,
                        top: (selectedPoint!.dy * scale) + offsetY - 8,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}
