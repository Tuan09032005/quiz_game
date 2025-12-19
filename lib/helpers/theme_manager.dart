import 'package:flutter/material.dart';
import 'package:quiz_game/helpers/theme_helper.dart';

// The InheritedWidget that will provide the theme data down the widget tree.
class ThemeProvider extends InheritedWidget {
  final LinearGradient gradient;
  final Color textColor;
  final Function(int) setTheme;

  const ThemeProvider({
    super.key,
    required this.gradient,
    required this.textColor,
    required this.setTheme,
    required super.child,
  });

  static ThemeProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
  }

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) {
    // Rebuild widgets if the gradient or text color has changed.
    return gradient != oldWidget.gradient || textColor != oldWidget.textColor;
  }
}

// The StatefulWidget that will manage the theme state.
class ThemeManager extends StatefulWidget {
  final Widget child;
  const ThemeManager({super.key, required this.child});

  @override
  State<ThemeManager> createState() => _ThemeManagerState();
}

class _ThemeManagerState extends State<ThemeManager> {
  late ThemeOption _currentTheme;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialTheme();
  }

  void _loadInitialTheme() async {
    final theme = await ThemeHelper.getCurrentTheme();
    if (mounted) {
      setState(() {
        _currentTheme = theme;
        _isLoading = false;
      });
    }
  }

  // This method will be called from the Settings screen.
  void _setTheme(int index) async {
    await ThemeHelper.setTheme(index);
    final newTheme = await ThemeHelper.getCurrentTheme();
    setState(() {
      _currentTheme = newTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Show a simple loading indicator while the initial theme is being loaded.
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return ThemeProvider(
      gradient: LinearGradient(colors: _currentTheme.colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
      textColor: _currentTheme.textColor,
      setTheme: _setTheme,
      child: widget.child,
    );
  }
}
