import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/portal_links/portal_link_catalog_repository.dart';
import '../../domain/entities/admin_portal_link.dart';

class LinkFormValue {
  final String tabName;
  final String name;
  final String url;
  final int sortOrder;
  final bool isActive;
  final File? image;

  const LinkFormValue({
    required this.tabName,
    required this.name,
    required this.url,
    required this.sortOrder,
    required this.isActive,
    required this.image,
  });
}

class PortalLinkFormDialog extends StatefulWidget {
  final AdminPortalLink? link;
  final List<String> existingCategories;

  const PortalLinkFormDialog({
    super.key,
    this.link,
    this.existingCategories = const [],
  });

  @override
  State<PortalLinkFormDialog> createState() => _PortalLinkFormDialogState();
}

class _PortalLinkFormDialogState extends State<PortalLinkFormDialog> {
  static const _defaultCategories = [
    'Abi Portal',
    'Kavi Manju Portal',
    'Vetri Portal',
    'Dinesh Portal',
  ];

  late final List<String> _categories;
  String? _selectedCategory;
  bool _isAddingCategory = false;

  late final TextEditingController _newCategoryController;
  late final TextEditingController _nameController;
  late final TextEditingController _urlController;
  late final TextEditingController _orderController;
  bool _active = true;
  File? _image;

  @override
  void initState() {
    super.initState();
    _active = widget.link?.isActive ?? true;
    _newCategoryController = TextEditingController();

    // Assemble unique categories
    final catSet = <String>{..._defaultCategories};
    for (final c in widget.existingCategories) {
      if (c.trim().isNotEmpty) catSet.add(c.trim());
    }
    if (widget.link != null && widget.link!.tabName.trim().isNotEmpty) {
      catSet.add(widget.link!.tabName.trim());
    }
    _categories = catSet.toList();

    if (widget.link != null && widget.link!.tabName.trim().isNotEmpty) {
      _selectedCategory = widget.link!.tabName.trim();
    } else {
      _selectedCategory = _categories.isNotEmpty ? _categories.first : 'Abi Portal';
    }

    _nameController = TextEditingController(text: widget.link?.name ?? '');
    _urlController = TextEditingController(text: widget.link?.url ?? '');
    _orderController = TextEditingController(
      text: '${widget.link?.sortOrder ?? 0}',
    );
  }

  @override
  void dispose() {
    _newCategoryController.dispose();
    _nameController.dispose();
    _urlController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    final path = result?.files.single.path;
    if (path != null) setState(() => _image = File(path));
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return AlertDialog(
      title: Text(widget.link == null ? 'Add Web App' : 'Edit Web App'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _isAddingCategory ? '__ADD_NEW__' : _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: [
                  for (final cat in _categories)
                    DropdownMenuItem(value: cat, child: Text(cat)),
                  DropdownMenuItem(
                    value: '__ADD_NEW__',
                    child: Row(
                      children: [
                        Icon(Icons.add_circle_outline, size: 18, color: primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          '+ Add new category...',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value == '__ADD_NEW__') {
                    setState(() {
                      _isAddingCategory = true;
                    });
                  } else if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                      _isAddingCategory = false;
                    });
                  }
                },
              ),
              if (_isAddingCategory) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newCategoryController,
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: 'New Category Name',
                          hintText: 'e.g. Finance Portal',
                          prefixIcon: const Icon(Icons.create_new_folder_outlined),
                          suffixIcon: IconButton(
                            tooltip: 'Cancel new category',
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() => _isAddingCategory = false);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(labelText: 'Website URL'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _orderController,
                decoration: const InputDecoration(labelText: 'Sort order'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Active'),
                value: _active,
                onChanged: (value) => setState(() => _active = value),
              ),
              const SizedBox(height: 12),
              const Text(
                'Card Image',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image_outlined),
                    label: Text(
                      _image != null
                          ? 'Change image'
                          : (widget.link?.imagePath != null ? 'Change image' : 'Upload image'),
                    ),
                  ),
                  const SizedBox(width: 14),
                  if (_image != null) ...[
                    Container(
                      width: 44,
                      height: 44,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Image.file(_image!, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Remove selected image',
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => setState(() => _image = null),
                    ),
                  ] else if (widget.link?.imagePath != null && widget.link!.imagePath!.isNotEmpty) ...[
                    Container(
                      width: 44,
                      height: 44,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Image.network(
                        PortalLinkCatalogRepository.absoluteImageUrl(widget.link!.imagePath!)!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final category = _isAddingCategory
                ? _newCategoryController.text.trim()
                : (_selectedCategory ?? 'Abi Portal');
            final name = _nameController.text.trim();
            final url = _urlController.text.trim();
            if (category.isEmpty || name.isEmpty || url.isEmpty) return;
            Navigator.pop(
              context,
              LinkFormValue(
                tabName: category,
                name: name,
                url: url,
                sortOrder: int.tryParse(_orderController.text) ?? 0,
                isActive: _active,
                image: _image,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
