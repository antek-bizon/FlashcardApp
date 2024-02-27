import 'package:flutter/material.dart';

class GroupPageArguments {
  final String groupName;
  final String? groupId;
  final VoidCallback onDelete;
  GroupPageArguments(this.groupName, this.groupId, this.onDelete);
}
