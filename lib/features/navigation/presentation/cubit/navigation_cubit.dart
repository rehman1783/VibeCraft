import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationState {
  final int selectedIndex;
  final DateTime? reselectedAt;

  const NavigationState({
    required this.selectedIndex,
    this.reselectedAt,
  });
}

/// Manages the selected tab index and re-tapping events for the bottom navigation bar.
class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(const NavigationState(selectedIndex: 0));

  /// Switches to the given tab [index] or emits reselectedAt timestamp if already active.
  void selectTab(int index) {
    if (index != state.selectedIndex) {
      emit(NavigationState(selectedIndex: index));
    } else {
      emit(NavigationState(selectedIndex: index, reselectedAt: DateTime.now()));
    }
  }
}
