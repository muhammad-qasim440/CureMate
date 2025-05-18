// API Provider
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/diagnosis_model.dart';

final diagnosisProvider = StateProvider<AsyncValue<List<Diagnosis>>>((ref) => const AsyncValue.loading());

final apiUrlProvider = StateProvider<String>((ref) => 'https://f0f7-119-154-241-110.ngrok-free.app/diagnose');