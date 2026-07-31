import 'package:flutter_bloc/flutter_bloc.dart';

/// Manages the selected tab index for the bottom navigation bar.
class NavigationCubit extends Cubit<int> {
  NavigationCubit() : super(0);

  /// Switches to the given tab [index].
  void selectTab(int index) {
    if (index != state) {
      emit(index);
    }
  }
}

