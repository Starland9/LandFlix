class Env {
  static const apiUrl = String.fromEnvironment('API_URL');

  static const downloadUrl = String.fromEnvironment(
    "DOWNLOAD_PAGE_URL",
    defaultValue: "https://starland9.github.io/landflix-landing/#download",
  );
}
