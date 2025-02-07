class QuizBean {
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

  QuizBean(
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

  QuizBean.fromJson(Map<String, dynamic> json) {
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
