import 'dart:math';

import 'package:flutter/material.dart';

class AddGroupDialog extends StatefulWidget {
  final Function(String) onAdd;
  final Set<String> existingGroups;

  const AddGroupDialog(
      {super.key, required this.onAdd, required this.existingGroups});

  @override
  State<AddGroupDialog> createState() => _AddGroupDialogState();
}

class _AddGroupDialogState extends State<AddGroupDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _groupNameField = TextEditingController();

  @override
  void dispose() {
    _groupNameField.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SizedBox(
          width: min(MediaQuery.of(context).size.width * 0.8, 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text("Add flashcard group"),
              const SizedBox(height: 15),
              Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _groupNameField,
                        decoration: const InputDecoration(
                            hintText: "Group name",
                            contentPadding: EdgeInsets.only(left: 5)),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter some group name";
                          } else if (widget.existingGroups.contains(value)) {
                            return "Group name already exists";
                          }
                          return null;
                        },
                      )
                    ],
                  )),
              // const SizedBox(height: 10),
              // IconButton(
              //     onPressed: () {},
              //     tooltip: "Add flashcard",
              //     icon: const Icon(Icons.add)),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          widget.onAdd(_groupNameField.text);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text("Add"))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
