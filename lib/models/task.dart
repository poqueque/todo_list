class Task {
  late String title;
  late bool completed;

  Task(this.title, this.completed);

  Task.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    completed = json['completed'];
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'completed': completed,
    };
  }
}
