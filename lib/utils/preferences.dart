import 'package:shared_preferences/shared_preferences.dart';

/*
 * https://gist.github.com/faisalraja/9b628439978c67b2fb6515cf202a3992
 */
class Preferences {
  static final Preferences _instance = Preferences._internal();
  static bool _initialized = false;

  static late SharedPreferences _prefs;
  static Map<String, dynamic> _memoryPrefs = Map<String, dynamic>();

  static const String KEY_USER_UID = "user_uid";
  static const String KEY_USER_NICK_NAME = "user_nick_name";
  static const String KEY_USER_EMAIL = "user_email";
  static const String KEY_USER_PHOTO_URL = "user_photo_url";
  static const String KEY_SETTINGS_THEME = "settings_theme";
  static const String KEY_SETTINGS_SHOW_NSFW = "settings_show_nsfw";
  static const String KEY_FAVORITE_BOARDS = "favorite_boards";
  static const String KEY_THREAD_CATALOG_MODE = "thread_catalog_mode";
  static const String KEY_NEXT_POST_ID = "next_post_id";
  static const String KEY_NEXT_THREAD_ID = "next_thread_id";

  Preferences._internal() {
    // initialization code
  }

  static Future<Preferences> initAndGet() async {
    if (_initialized) return _instance;

    _prefs = await SharedPreferences.getInstance();

    _initialized = true;
    return _instance;
  }

  static void setStringList(String key, List<String> value) {
    _prefs.setStringList(key, value);
    _memoryPrefs[key] = value;
  }

  static void setString(String key, String value) {
    _prefs.setString(key, value);
    _memoryPrefs[key] = value;
  }

  static void setInt(String key, int value) {
    _prefs.setInt(key, value);
    _memoryPrefs[key] = value;
  }

  static void setDouble(String key, double value) {
    _prefs.setDouble(key, value);
    _memoryPrefs[key] = value;
  }

  static void setBool(String key, bool value) {
    _prefs.setBool(key, value);
    _memoryPrefs[key] = value;
  }

  static List<String> getStringList(String key) {
    List<String>? val;
    if (_memoryPrefs.containsKey(key)) {
      val = _memoryPrefs[key];
    }
    if (val == null) {
      val = _prefs.getStringList(key);
    }
    if (val == null) {
      val = [];
    }
    _memoryPrefs[key] = val;
    return val;
  }

  static String getString(String key, {String? def}) {
    String? val;
    if (_memoryPrefs.containsKey(key)) {
      val = _memoryPrefs[key];
    }
    if (val == null) {
      val = _prefs.getString(key);
    }
    if (val == null) {
      val = def;
    }
    _memoryPrefs[key] = val;
    return val!;
  }

  static int getIntDef(String key, int def) {
    int? val = getInt(key);
    if (val == null) {
      val = def;
    }
    _memoryPrefs[key] = val;
    return val;
  }

  static int? getInt(String key) {
    int? val;
    if (_memoryPrefs.containsKey(key)) {
      val = _memoryPrefs[key];
    }
    if (val == null) {
      val = _prefs.getInt(key);
    }
    _memoryPrefs[key] = val;
    return val;
  }

  static double getDouble(String key, {double? def}) {
    double? val;
    if (_memoryPrefs.containsKey(key)) {
      val = _memoryPrefs[key];
    }
    if (val == null) {
      val = _prefs.getDouble(key);
    }
    if (val == null) {
      val = def;
    }
    _memoryPrefs[key] = val;
    return val!;
  }

  static bool getBool(String key, {bool def = false}) {
    bool? val;
    if (_memoryPrefs.containsKey(key)) {
      val = _memoryPrefs[key];
    }
    if (val == null) {
      val = _prefs.getBool(key);
    }
    if (val == null) {
      val = def;
    }
    _memoryPrefs[key] = val;
    return val;
  }
}
