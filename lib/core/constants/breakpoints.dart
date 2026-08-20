abstract final class Breakpoints {
  static const compact = 900.0;
  static const medium = 1200.0;

  static bool isCompact(double width) => width < compact;
  static bool isMedium(double width) => width < medium;
}
