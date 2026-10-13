/// The only error type screens ever see. Repositories convert Firebase
/// errors into this, with a message that is safe to show to the user.
class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}