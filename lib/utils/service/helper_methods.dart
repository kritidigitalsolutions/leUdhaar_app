String getInitials(String? name) {
  if (name == null || name.trim().isEmpty) return "U";

  List<String> parts = name.trim().split(" ");

  if (parts.length == 1) {
    return parts[0][0].toUpperCase();
  }

  return (parts[0][0] + parts[1][0]).toUpperCase();
}
