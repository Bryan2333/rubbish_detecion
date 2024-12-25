import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:oktoast/oktoast.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rubbish_detection/pages/recognization_result_page/recognization_result_page.dart';
import 'package:rubbish_detection/pages/record_page/record_vm.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage>
    with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  final _recordViewModel = RecordViewModel();
  late AudioRecorder _recorder;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _recorder = AudioRecorder();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "语音识别",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24.sp,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 顶部提示区域
            Container(
              padding: EdgeInsets.symmetric(vertical: 30.h),
              child: Column(
                children: [
                  Text(
                    "请点击下面的麦克风",
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "说出您要分类的垃圾",
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            // 示例区域
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 30.h),
                    Text(
                      "您可以这样说",
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Wrap(
                      spacing: 12.w,
                      runSpacing: 12.h,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildExampleChip("纸巾"),
                        _buildExampleChip("塑胶品"),
                        _buildExampleChip("温度计"),
                        _buildExampleChip("蓄电池"),
                        _buildExampleChip("外卖盒"),
                        _buildExampleChip("苹果皮"),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 录音按钮区域
            Container(
              padding: EdgeInsets.symmetric(vertical: 40.h),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      if (_isRecording) {
                        final payload = await _stopRecord();
                        setState(() => _isRecording = false);
                        _animationController.stop();

                        final res =
                            await _recordViewModel.getResponse(payload ?? "");

                        if (res?.result?.isEmpty == true) {
                          showToast("语音识别失败！");
                          return;
                        }

                        if (context.mounted == false) {
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecognizationResultPage(
                              rubbishName: res?.result ?? "",
                            ),
                          ),
                        );
                      } else {
                        await _startRecord();
                        setState(() => _isRecording = true);
                        _animationController.repeat(reverse: true);
                      }
                    },
                    child: AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _isRecording ? _scaleAnimation.value : 1.0,
                          child: Container(
                            height: 100.h,
                            width: 100.h,
                            decoration: BoxDecoration(
                              color: _isRecording
                                  ? const Color(0xFFFF3197)
                                  : const Color(0xFF00CE68),
                              borderRadius: BorderRadius.circular(50.r),
                              boxShadow: [
                                BoxShadow(
                                  color: (_isRecording
                                          ? const Color(0xFFFF3197)
                                          : const Color(0xFF00CE68))
                                      .withOpacity(0.3),
                                  spreadRadius: 4,
                                  blurRadius: 15,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              "assets/images/microphone_2.png",
                              width: 50.r,
                              height: 50.r,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    _isRecording ? "点击停止" : "点击说话",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: _isRecording
                          ? const Color(0xFFFF3197)
                          : const Color(0xFF00CE68),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFF00CE68).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          color: const Color(0xFF00CE68),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // _startRecord 和 _stopRecord 方法保持不变

  Future<void> _startRecord() async {
    if (await _recorder.hasPermission()) {
      final appCacheDir = await getApplicationCacheDirectory();

      final filePath = path.join(appCacheDir.path, "recording_file.opus");

      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.opus),
        path: filePath,
      );
    }
  }

  Future<String?> _stopRecord() async {
    final audioFilePath = await _recorder.stop();

    if (audioFilePath == null) {
      return null;
    }

    final audioFile = File(audioFilePath);

    final audioBytes = audioFile.readAsBytesSync();

    final payload = json.encode({
      "EngSerViceType": "16k_zh",
      "SourceType": 1,
      "VoiceFormat": "ogg-opus",
      "FilterPunc": 2,
      "Data": base64Encode(audioBytes),
      "DataLen": audioBytes.length
    });

    return payload;
  }
}
