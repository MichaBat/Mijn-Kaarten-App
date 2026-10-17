import 'package:bonidus_apidus/presentation/viewmodels/card_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/card_item.dart';
import 'cards/add_card_item.dart';
import 'cards/card_list_item.dart';

class ListViewWidget extends StatelessWidget {
  final List<CardItem>? cardItems;

  const ListViewWidget({
    super.key,
    this.cardItems,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CardViewmodel>();

    return ListView.builder(
      padding: const EdgeInsets.only(top: 20.0, bottom: 60),
      itemCount: viewModel.filteredCardList.length + 1,
      itemBuilder: (context, index) {
        if (index == viewModel.filteredCardList.length) {
          return const AddCardItem();
        }
        final item = viewModel.filteredCardList[index];
        return CardListItem(
          key: ValueKey(item.id),
          item: item,
        );
      },
    );
  }
}
