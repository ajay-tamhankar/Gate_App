enum Environment { dev, stage, prod }

class Env {
  static Environment current = Environment.dev;

  static String get baseUrl {
    switch (current) {
      case Environment.dev:
        return 'https://vistar-crm.onrender.com/api/v1/gate';
      case Environment.stage:
        return 'https://vistar-crm.onrender.com/api/v1/gate';
      case Environment.prod:
        return 'https://vistar-crm.onrender.com/api/v1/gate';
    }
  }

  static bool get isDebug => current == Environment.dev;
}
