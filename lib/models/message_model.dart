class MessageModel {
  String message;
  bool isMyMessage;
  String messageType;
  MessageModel(
      {this.message = '', this.isMyMessage = true, this.messageType = 'text'});
}
