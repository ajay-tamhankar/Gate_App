enum Environment { dev, stage, prod }

class Env {
  static Environment current = Environment.dev;

  static String get baseUrl {
    switch (current) {
      case Environment.dev:
        return 'https://gate-app-26yt.onrender.com/api/v1';
      case Environment.stage:
        return 'https://gate-app-26yt.onrender.com/api/v1';
      case Environment.prod:
        return 'https://gate-app-26yt.onrender.com/api/v1';
    }
  }

  static bool get isDebug => current == Environment.dev;
}
