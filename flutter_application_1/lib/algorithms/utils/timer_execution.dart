/// Determines the execution time of both
/// synchronous and asynchronous functions.
///
/// Example usage:
/// ```dart
/// void foo() {
///   for (int i = 0; i < 100000000; i++) {}
/// }
///
/// Future<void> main() async {
///   final timer = TimerExecution("Test Foo", () => foo());
///   await timer.determineTime();
///   print(timer);
/// }
/// ```
/// Output:
/// ```
/// TimerExecution(name: Test Foo, duration: 0:00:00.420153)
/// ```
class TimerExecution {
  final String name;
  final Function function;
  Duration? duration;

  /// Creates [TimerExecution] with [name] and [function]
  /// 
  /// [function] must be as an **arrow function** 
  /// 
  /// Example:
  /// ```dart 
  /// TimerExecution("name", () => yourFunc(your_args));
  /// ```
  TimerExecution(this.name, this.function);

  /// Returns a [Duration] that represents the execution time
  /// and assigns this to the field [duration]
  Future<Duration> determineTime() async {

    // Start the timer
    Stopwatch sw = Stopwatch()..start();

    // Check whether it is future or not
    final funcRes = function();
    if (funcRes is Future) {
      await funcRes;
    }

    // Stop the timer
    sw.stop();

    // Assign the result to duration and return this
    duration = sw.elapsed;
    return duration!;
  }

  @override
  String toString() {
    return "TimerExecution(name: $name, duration: ${duration ?? "Not Determined"})";
  }
}