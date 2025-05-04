import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
class SearchBarWidget extends ConsumerStatefulWidget {
  final StateProvider<String> provider;
  final bool applyFocusNode;

  const SearchBarWidget({
    super.key,
    required this.provider,
    this.applyFocusNode = true,
  });

  @override
  ConsumerState<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends ConsumerState<SearchBarWidget> {
  final FocusNode _focusNode = FocusNode();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(widget.provider));
    if (widget.applyFocusNode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String>(widget.provider, (previous, next) {
      if (_controller.text != next) {
        _controller.text = next;
        _controller.selection = TextSelection.collapsed(offset: next.length);
      }
    });

    return TextField(
      controller: _controller,
      // focusNode: widget.applyFocusNode ? _focusNode : null,
      decoration: InputDecoration(
        hintText: 'Search...',
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.subtextcolor,
          size: 20,
        ),
        suffixIcon: InkWell(
          onTap: () {
            _controller.clear();
            FocusScope.of(context).unfocus();
            ref.read(widget.provider.notifier).state = '';
          },
          child: const Icon(Icons.close, color: AppColors.subtextcolor, size: 20),
        ),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (value) {
        ref.read(widget.provider.notifier).state = value;
      },
    );
  }
}

