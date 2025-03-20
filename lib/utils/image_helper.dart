import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rubbish_detection/utils/custom_helper.dart';

class ImageHelper {
  static Future<File?> uploadImage(BuildContext context,
      {double? maxWidth, double? maxHeight, int? imageQuality}) async {
    final imageSource = await _showPickerDialog(context);
    if (imageSource == null) {
      return null;
    }

    if (!context.mounted) return null;

    final pickedImage = await _pickImage(context,
        source: imageSource,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality);

    return pickedImage;
  }

  static Future<ImageSource?> _showPickerDialog(BuildContext context) async {
    ImageSource? source;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('选择图片'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text('拍照'),
                onTap: () {
                  Navigator.of(context).pop();
                  source = ImageSource.camera;
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('从相册选择'),
                onTap: () {
                  Navigator.of(context).pop();
                  source = ImageSource.gallery;
                },
              ),
            ],
          ),
        );
      },
    );

    return source;
  }

  static Future<File?> _pickImage(BuildContext context,
      {required ImageSource source,
      double? maxWidth,
      double? maxHeight,
      int? imageQuality}) async {
    final returnImage = await ImagePicker().pickImage(
      source: source,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );
    if (returnImage == null) {
      return null;
    }

    final extension = p.extension(returnImage.path).toLowerCase();
    if (extension != ".jpeg" && extension != ".jpg") {
      if (!context.mounted) return null;
      CustomHelper.showSnackBar(context, "只支持上传jpg和jpeg格式的图片", success: false);
      return null;
    }

    final croppedImage = await _cropImage(returnImage);
    if (croppedImage == null) {
      return null;
    }

    return File(croppedImage.path);
  }

  static Future<CroppedFile?> _cropImage(XFile image) async {
    final croppedImage = await ImageCropper().cropImage(
      sourcePath: image.path,
      uiSettings: [
        AndroidUiSettings(
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
          toolbarColor: Colors.white,
          toolbarTitle: "图片裁剪",
          toolbarWidgetColor: Colors.black,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        )
      ],
    );

    return croppedImage;
  }
}
