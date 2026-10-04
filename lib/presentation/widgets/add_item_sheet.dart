import 'package:flutter/material.dart';

import '../controllers/shopping_list_controller.dart';

Future<void> showAddItemSheet(
  BuildContext context,
  ShoppingListController controller,
) async {
  final TextEditingController textController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textController,
              focusNode: focusNode,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(hintText: 'Add an item…'),
              onSubmitted: (value) {
                controller.add(value).ignore();
                // Keep the sheet open for the next item.
                textController.clear();
                focusNode.requestFocus();
              },
            ),
          ),
          const SizedBox(width: 12),
          IconButton.filled(
            icon: const Icon(Icons.add),
            tooltip: 'Add',
            onPressed: () {
              controller.add(textController.text).ignore();
              textController.clear();
              focusNode.requestFocus();
            },
          ),
        ],
      ),
    ),
  );

  // Save any text left in the field when it closes.
  controller.add(textController.text).ignore();
  textController.dispose();
  focusNode.dispose();
}
