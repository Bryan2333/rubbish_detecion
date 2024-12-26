class QuizModel {
  String? msg;
  String? code;
  List<Quiz>? data;

  QuizModel({this.msg, this.code, this.data});

  QuizModel.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];
    code = json['code'];
    if (json['data'] != null) {
      data = <Quiz>[];
      json['data'].forEach((v) {
        data!.add(Quiz.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['msg'] = msg;
    data['code'] = code;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Quiz {
  int? id;
  String? question;
  String? optionA;
  String? optionB;
  String? optionC;
  String? optionD;
  int? correctAnswerIndex;
  int? status;
  String? createTime;
  String? updateTime;

  Quiz(
      {this.id,
      this.question,
      this.optionA,
      this.optionB,
      this.optionC,
      this.optionD,
      this.correctAnswerIndex,
      this.status,
      this.createTime,
      this.updateTime});

  Quiz.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    question = json['question'];
    optionA = json['optionA'];
    optionB = json['optionB'];
    optionC = json['optionC'];
    optionD = json['optionD'];
    correctAnswerIndex = json['correctAnswerIndex'];
    status = json['status'];
    createTime = json['createTime'];
    updateTime = json['updateTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['question'] = question;
    data['optionA'] = optionA;
    data['optionB'] = optionB;
    data['optionC'] = optionC;
    data['optionD'] = optionD;
    data['correctAnswerIndex'] = correctAnswerIndex;
    data['status'] = status;
    data['createTime'] = createTime;
    data['updateTime'] = updateTime;
    return data;
  }
}
