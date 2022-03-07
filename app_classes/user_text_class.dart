class UserText{
  String text;
  UserText(this.text);

 factory UserText.fromMap(Map<String, dynamic>map){
    final text = map["text"];
    return UserText(text);
  }
}