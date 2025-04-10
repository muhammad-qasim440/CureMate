
class IsarService {
  static Isar? _isar;

  static Future<Isar> getInstance() async {
    if (_isar == null || !_isar!.isOpen) {
      final dir = await getApplicationDocumentsDirectory();
      _isar = await Isar.open(
        [],
        directory: dir.path,
      );
    }
    return _isar!;
  }
}
