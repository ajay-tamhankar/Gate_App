enum Environment { dev, stage, prod }

class Env {
  static Environment current = Environment.dev;

  static String get baseUrl {
    switch (current) {
      case Environment.dev:
        return 'https://dev-api.gate-reco.com';
      case Environment.stage:
        return 'https://stage-api.gate-reco.com';
      case Environment.prod:
        return 'https://api.gate-reco.com';
    }
  }

  static bool get isDebug => current == Environment.dev;
}
