import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'chatting_providers.dart';

final chatListSearchQueryProviderProvider=StateProvider<String>((ref)=>'');
final filteredChatListProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final chatList = ref.watch(chatListProvider).valueOrNull ?? [];
  final searchQuery = ref.watch(chatListSearchQueryProviderProvider);

  if (searchQuery.isEmpty) {
    return chatList;
  }

  return chatList.where((chat) {
    final otherUserName = chat['otherUserName']?.toString().trim() ?? '';
    return otherUserName.toLowerCase().contains(searchQuery.toLowerCase());
  }).toList();
});