class RecordResponseDataModel {
  RecordResponse? response;

  RecordResponseDataModel({this.response});

  RecordResponseDataModel.fromJson(Map<String, dynamic> json) {
    response = json['Response'] != null
        ? RecordResponse.fromJson(json['Response'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (response != null) {
      data['Response'] = response!.toJson();
    }
    return data;
  }
}

class RecordResponse {
  int? audioDuration;
  String? requestId;
  String? result;
  List<WordList>? wordList;
  int? wordSize;

  RecordResponse(
      {this.audioDuration,
      this.requestId,
      this.result,
      this.wordList,
      this.wordSize});

  RecordResponse.fromJson(Map<String, dynamic> json) {
    audioDuration = json['AudioDuration'];
    requestId = json['RequestId'];
    result = json['Result'];
    if (json['WordList'] != null) {
      wordList = <WordList>[];
      json['WordList'].forEach((v) {
        wordList!.add(WordList.fromJson(v));
      });
    }
    wordSize = json['WordSize'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['AudioDuration'] = audioDuration;
    data['RequestId'] = requestId;
    data['Result'] = result;
    if (wordList != null) {
      data['WordList'] = wordList!.map((v) => v.toJson()).toList();
    }
    data['WordSize'] = wordSize;
    return data;
  }
}

class WordList {
  int? endTime;
  int? startTime;
  String? word;

  WordList({this.endTime, this.startTime, this.word});

  WordList.fromJson(Map<String, dynamic> json) {
    endTime = json['EndTime'];
    startTime = json['StartTime'];
    word = json['Word'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['EndTime'] = endTime;
    data['StartTime'] = startTime;
    data['Word'] = word;
    return data;
  }
}
