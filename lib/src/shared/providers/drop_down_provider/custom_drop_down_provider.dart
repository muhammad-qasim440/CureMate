import 'package:flutter_riverpod/flutter_riverpod.dart';

class DropdownState<T> {
  final T selected;
  final List<T> items;

  DropdownState({required this.selected, required this.items});
}

class DropdownNotifier<T> extends StateNotifier<DropdownState<T>> {
  DropdownNotifier({required List<T> items, required T initial})
      : super(DropdownState(selected: initial, items: items));

  void setSelected(T value) {
    state = DropdownState(selected: value, items: state.items);
  }
}

final customDropDownProvider = StateNotifierProvider.autoDispose
    .family<DropdownNotifier<String>, DropdownState<String>, List<String>>(
      (ref, items) => DropdownNotifier(items: items, initial: items.first),
);
