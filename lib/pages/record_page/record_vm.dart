import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:rubbish_detection/repository/data/record_response_data.dart';

class RecordViewModel with ChangeNotifier {

  Future<RecordResponse?> getResponse(String payload) async {
    const secretId = 'AKID76rNfiYAZkmfKo5B4i7II4cw61jDXhcJ';
    const secretKey = 'YszsZ2HI4HQPDB869788zyoUw97wa4NY';

    const service = 'asr';
    const host = 'asr.tencentcloudapi.com';
    const action = 'SentenceRecognition';
    const version = '2019-06-14';
    const algorithm = 'TC3-HMAC-SHA256';
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final date = DateFormat('yyyy-MM-dd').format(
        DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true));

    // ************* 步骤 1：拼接规范请求串 *************
    const httpRequestMethod = 'POST';
    const canonicalUri = '/';
    const canonicalQuerystring = '';
    const ct = 'application/json; charset=utf-8';
    final canonicalHeaders =
        'content-type:$ct\nhost:$host\nx-tc-action:${action.toLowerCase()}\n';
    const signedHeaders = 'content-type;host;x-tc-action';
    final hashedRequestPayload = sha256.convert(utf8.encode(payload));
    final canonicalRequest = '''
$httpRequestMethod
$canonicalUri
$canonicalQuerystring
$canonicalHeaders
$signedHeaders
$hashedRequestPayload''';

    // ************* 步骤 2：拼接待签名字符串 *************
    final credentialScope = '$date/$service/tc3_request';
    final hashedCanonicalRequest =
        sha256.convert(utf8.encode(canonicalRequest));
    final stringToSign = '''
$algorithm
$timestamp
$credentialScope
$hashedCanonicalRequest''';

    // ************* 步骤 3：计算签名 *************
    List<int> sign(List<int> key, String msg) {
      final hmacSha256 = Hmac(sha256, key);
      return hmacSha256.convert(utf8.encode(msg)).bytes;
    }

    final secretDate = sign(utf8.encode('TC3$secretKey'), date);
    final secretService = sign(secretDate, service);
    final secretSigning = sign(secretService, 'tc3_request');
    final signature = Hmac(sha256, secretSigning)
        .convert(utf8.encode(stringToSign))
        .toString();

    // ************* 步骤 4：拼接 Authorization *************
    final authorization =
        '$algorithm Credential=$secretId/$credentialScope, SignedHeaders=$signedHeaders, Signature=$signature';

    // ************* 步骤 5：构造并发起请求 *************
    final dio = Dio(BaseOptions(baseUrl: "https://asr.tencentcloudapi.com"));
    final res = await dio.post(
      "/",
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': authorization,
          'X-TC-Action': action,
          'X-TC-Version': version,
          'X-TC-Timestamp': timestamp.toString(),
        },
      ),
      data: payload,
    );

    final model = RecordResponseDataModel.fromJson(res.data);

    return model.response;
  }
}
