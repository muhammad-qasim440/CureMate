import 'package:flutter_riverpod/flutter_riverpod.dart';

final forgotPasswordEmailProvider = StateProvider<String>((ref) => '');
final isEmailSentProvider = StateProvider<bool>((ref) => false);
