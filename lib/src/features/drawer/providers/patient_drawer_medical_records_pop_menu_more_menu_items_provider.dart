import 'package:flutter/material.dart';

List<PopupMenuEntry<String>> buildPopupMoreMenuItems() {
  List<PopupMenuEntry<String>> menuItems = [];

    menuItems.addAll([
      const PopupMenuItem(
        value: 'delete',
        child: Text('Delete'),
      ),
    ]);

  return menuItems;
}


