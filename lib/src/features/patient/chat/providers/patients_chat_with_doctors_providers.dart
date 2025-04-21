import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/chat/providers/chatting_providers.dart';

final searchQueryForPatientChatWithDoctorProvider=StateProvider<String>((ref)=>'');
final filteredChatListProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final chatList = ref.watch(chatListProvider).valueOrNull ?? [];
  final searchQuery = ref.watch(searchQueryForPatientChatWithDoctorProvider);

  if (searchQuery.isEmpty) {
    return chatList;
  }

  return chatList.where((chat) {
    final otherUserName = chat['otherUserName']?.toString().trim() ?? '';
    return otherUserName.toLowerCase().contains(searchQuery.toLowerCase());
  }).toList();
});