import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rubbish_detection/pages/recognization_result_page/recognization_result_page.dart';
import 'package:rubbish_detection/pages/record_page/record_vm.dart';
import 'package:rubbish_detection/utils/custom_helper.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage>
    with SingleTickerProviderStateMixin {
  final _recordViewModel = RecordViewModel();

  late ValueNotifier<bool> _isRecordingNotifier;

  late AudioRecorder _recorder;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _isRecordingNotifier = ValueNotifier(false);
    _recorder = AudioRecorder();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animationController.repeat(reverse: true);

    _scaleAnimation = Tween(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _isRecordingNotifier.dispose();
    _animationController.dispose();
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: 20.r,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "语音识别",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24.sp,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 顶部提示区域
            _buildHeader(),
            // 示例区域
            _buildExamples(),
            // 录音按钮区域
            _buildMicButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 30.h),
      child: Column(
        children: [
          Text(
            "请点击下面的麦克风",
            style: TextStyle(
              fontSize: 22.sp,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "说出您要分类的垃圾",
            style: TextStyle(
              fontSize: 22.sp,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamples() {
    return Expanded(
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
    );
  }

  Widget _buildExampleChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFF00CE68).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          color: const Color(0xFF00CE68),
        ),
      ),
    );
  }

  Widget _buildMicButton() {
    return Container(
      margin: EdgeInsets.only(bottom: 100.h),
      child: ValueListenableBuilder(
        valueListenable: _isRecordingNotifier,
        builder: (context, isRecording, child) {
          return Column(
            children: [
              GestureDetector(
                onTap: () async {
                  if (isRecording) {
                    final payload = await _stopRecording();
                    _isRecordingNotifier.value = false;
                    _getRecordRecognition(payload ?? "");
                  } else {
                    await _startRecording();
                    _isRecordingNotifier.value = true;
                  }
                },
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: isRecording ? _scaleAnimation.value : 1.0,
                      child: Container(
                        height: 90.h,
                        width: 90.h,
                        decoration: BoxDecoration(
                          color: isRecording
                              ? const Color(0xFFFF3197)
                              : const Color(0xFF00CE68),
                          borderRadius: BorderRadius.circular(50.r),
                          boxShadow: [
                            BoxShadow(
                              color: (isRecording
                                      ? const Color(0xFFFF3197)
                                      : const Color(0xFF00CE68))
                                  .withValues(alpha: 0.3),
                              spreadRadius: 4.r,
                              blurRadius: 15.r,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.mic,
                          color: Colors.white,
                          size: 60.r,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                isRecording ? "点击停止" : "点击说话",
                style: TextStyle(
                  fontSize: 16.sp,
                  color: isRecording
                      ? const Color(0xFFFF3197)
                      : const Color(0xFF00CE68),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _startRecording() async {
    if (await _recorder.hasPermission()) {
      final appCacheDir = await getApplicationCacheDirectory();

      final filePath = path.join(appCacheDir.path, "recording_file.opus");

      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.opus),
        path: filePath,
      );

      _animationController.repeat(reverse: true);
    } else {
      if (mounted) {
        CustomHelper.showSnackBar(context, "请先授予录音权限", success: false);
      }
    }
  }

  Future<String?> _stopRecording() async {
    final audioFilePath = await _recorder.stop();
    _animationController.stop();

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

  Future<void> _getRecordRecognition(String payload) async {
    final res = await _recordViewModel.getResponse(payload);

    if (mounted == false) {
      return;
    }

    if (res?.result?.isEmpty == true) {
      CustomHelper.showSnackBar(context, "识别失败，请重新尝试", success: false);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecognizationResultPage(
            rubbishName: res?.result ?? "",
          ),
        ),
      );
    }
  }
}
