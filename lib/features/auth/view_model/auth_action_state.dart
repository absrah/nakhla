/// What a form screen needs to know about the request it just made.
class AuthActionState {
  const AuthActionState({
    this.isLoading = false,
    this.error,
    this.done = false,
  });

  final bool isLoading; // show a spinner, ignore extra taps
  final String? error; // message to show, safe for users
  final bool done; // the request finished successfully
}
