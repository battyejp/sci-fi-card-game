class HelperFunctions {
  /// Generates a random integer between min and max (inclusive)
  static int randomInt(int min, int max) {
    return min + (max - min + 1) * (DateTime.now().millisecondsSinceEpoch % 1000) ~/ 1000;
  }
  
  /// Formats a number with commas for thousands
  static String formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
  
  /// Capitalizes the first letter of a string
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  /// Calculates distance between two points
  static double distance(double x1, double y1, double x2, double y2) {
    final dx = x2 - x1;
    final dy = y2 - y1;
    return (dx * dx + dy * dy).abs();
  }
  
  /// Lerp between two values
  static double lerp(double a, double b, double t) {
    return a + (b - a) * t;
  }
}
