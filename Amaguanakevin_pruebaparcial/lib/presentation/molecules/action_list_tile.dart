import 'package:flutter/material.dart';
import '../atoms/custom_card.dart';

class ActionListTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ActionListTile({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.onEdit,
    this.onDelete,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: ListTile(
        leading: leading,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: trailing ??
            (onEdit != null || onDelete != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onEdit != null)
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: onEdit,
                          tooltip: 'Editar',
                        ),
                      if (onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.red, size: 20),
                          onPressed: onDelete,
                          tooltip: 'Eliminar',
                        ),
                    ],
                  )
                : null),
        onTap: onTap,
      ),
    );
  }
}
