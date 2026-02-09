import 'package:numberwale/core/common/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../src/authentication/domain/entities/local_user.dart';

extension ContextExt on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => theme.textTheme;

  ColorScheme get colorScheme => theme.colorScheme;

  MediaQueryData get mediaQuery => MediaQuery.of(this);

  Size get size => mediaQuery.size;

  double get width => size.width;

  double get height => size.height;

  UserProvider get userProvider => read<UserProvider>();

  LocalUser? get currentUser => userProvider.user;

  // Responsive breakpoints
  bool get isMobile => width < 768;
  bool get isTablet => width >= 768 && width < 1024;
  bool get isDesktop => width >= 1024;
  bool get isTabletOrDesktop => width >= 768;
  bool get isMobileOrTablet => width < 1024;

  // Responsive spacing
  double get responsiveSpacing => isMobile ? 16.0 : (isTablet ? 24.0 : 32.0);
  double get responsiveCardSpacing => isMobile ? 12.0 : (isTablet ? 16.0 : 20.0);
  double get responsivePadding => isMobile ? 16.0 : (isTablet ? 32.0 : 48.0);

  // Responsive text scaling
  double get responsiveTextScale => isMobile ? 1.0 : (isTablet ? 1.1 : 1.2);

  // Responsive content width
  double get maxContentWidth => isMobile ? width : (isTablet ? 600.0 : 800.0);
  double get responsiveCardWidth => isMobile ? width - 32 : (isTablet ? 400.0 : 450.0);

  // Grid columns for responsive layouts
  int get responsiveColumns => isMobile ? 1 : (isTablet ? 2 : 3);
  int get responsiveGridColumns => isMobile ? 2 : (isTablet ? 3 : 4);

  // Responsive sizing helpers
  double responsiveValue({
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  T responsiveChoice<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }
}