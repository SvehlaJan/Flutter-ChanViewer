import 'package:flutter/material.dart';

enum AppTheme { light, dark }

enum OnlineState { ONLINE, OFFLINE, UNKNOWN }

class Constants {
  //routes
  static const String favoritesRoute = "favorites";
  static const String boardsRoute = "boards";
  static const String boardDetailRoute = "board/detail";
  static const String threadDetailRoute = "board/detail/thread";
  static const String galleryRoute = "board/detail/thread/gallery";
  static const String settingsRoute = "settings";
  static const String notFoundRoute = "not_found";

  static const double favoriteIconSize = 16.0;
  static const double avatarImageSize = 100.0;
  static const double avatarImageMaxHeight = 600.0;
  static const double progressPlaceholderSize = 40.0;
  static const double errorPlaceholderSize = 100.0;
  static const double minFlingDistance = 100.0;
  static const Widget progressIndicator = const SizedBox(width: Constants.progressPlaceholderSize, height: Constants.progressPlaceholderSize, child: CircularProgressIndicator());
  static const Widget centeredProgressIndicator = const Center(child: progressIndicator);
  static const Widget noDataPlaceholder = const Center(child: Text("No data :-("));
  static const Widget errorPlaceholder = const Center(child: Text("Error :-("));

  //strings
  static const String appName = "Chan Viewer";

  //generic
  static const String str_error = "Error";
  static const String str_success = "Success";
  static const String str_ok = "OK";
  static const String str_forgot_password = "Forgot Password?";
  static const String str_something_went_wrong = "Something went wrong";
  static const String str_coming_soon = "Coming Soon";

  static List<AppTheme> appThemes = [AppTheme.light, AppTheme.dark];

  static ThemeData searchBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      textTheme: theme.primaryTextTheme,
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: Theme.of(context).textTheme.title.copyWith(color: Theme.of(context).primaryTextTheme.title.color.withOpacity(0.8)),
      ),
    );
  }
}
