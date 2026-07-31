abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure({String message = "Server communication failure"}) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure({String message = "Local cache reading failure"}) : super(message);
}

class NoInternetFailure extends Failure {
  const NoInternetFailure({String message = "No active internet connection detected"}) : super(message);
}