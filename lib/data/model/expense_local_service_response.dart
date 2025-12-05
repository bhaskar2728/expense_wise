class ExpenseLocalServiceResponse {
  final bool success;
  String? errorMsg;
  dynamic data;

  ExpenseLocalServiceResponse({
    required this.success,
    this.errorMsg,
    this.data,
  });
}
