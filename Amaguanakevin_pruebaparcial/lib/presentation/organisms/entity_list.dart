import 'package:flutter/material.dart';
import '../molecules/action_list_tile.dart';
import '../atoms/empty_state.dart';

class EntityList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(T item) leadingBuilder;
  final String Function(T item) titleBuilder;
  final String? Function(T item)? subtitleBuilder;
  final void Function(T item)? onEdit;
  final void Function(T item)? onDelete;
  final void Function(T item)? onTap;
  final String emptyMessage;
  final IconData emptyIcon;

  const EntityList({
    super.key,
    required this.items,
    required this.leadingBuilder,
    required this.titleBuilder,
    this.subtitleBuilder,
    this.onEdit,
    this.onDelete,
    this.onTap,
    this.emptyMessage = 'No hay elementos registrados',
    this.emptyIcon = Icons.inbox,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return EmptyState(
        icon: emptyIcon,
        message: emptyMessage,
        subtitle: 'Presiona + para agregar',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ActionListTile(
          leading: leadingBuilder(item),
          title: titleBuilder(item),
          subtitle: subtitleBuilder?.call(item),
          onEdit: onEdit != null ? () => onEdit!(item) : null,
          onDelete: onDelete != null ? () => onDelete!(item) : null,
          onTap: onTap != null ? () => onTap!(item) : null,
        );
      },
    );
  }
}
