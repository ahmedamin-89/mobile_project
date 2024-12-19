import 'package:flutter/material.dart';
import '../models/gift.dart';

class GiftDetailsPage extends StatefulWidget {
  final Gift? gift; // Null if adding a new gift

  const GiftDetailsPage({super.key, this.gift});

  @override
  _GiftDetailsPageState createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String description;
  String category = 'Electronics'; // Default category
  late double price;
  bool isPledged = false;

  final List<String> categories = [
    'Electronics',
    'Books',
    'Clothing',
    'Home',
    'Toys',
    'Sports',
    'Beauty',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.gift != null) {
      // Editing an existing gift
      name = widget.gift!.name;
      description = widget.gift!.description;
      category = widget.gift!.category;
      price = widget.gift!.price;
      isPledged = widget.gift!.status != 'Available';
    } else {
      // Adding a new gift
      name = '';
      description = '';
      price = 0.0;
    }
  }

  void saveGift() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Create or update the gift object
      final newGift = Gift(
        id: widget.gift?.id ?? '', // Generate ID if needed
        name: name,
        description: description,
        category: category,
        price: price,
        status: widget.gift?.status ?? 'Available',
        eventId: widget.gift?.eventId ?? '',
      );

      // Save the newGift to Firestore or pass it back to the previous screen
      // TODO: Implement Firestore integration
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gift "${newGift.name}" saved.')),
      );

      Navigator.pop(context, newGift);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditable = !isPledged;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gift != null ? 'Edit Gift' : 'Add Gift'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isEditable
            ? Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: name,
                      decoration: const InputDecoration(labelText: 'Gift Name'),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a gift name' : null,
                      onSaved: (value) => name = value!,
                    ),
                    TextFormField(
                      initialValue: description,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      onSaved: (value) => description = value!,
                    ),
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: categories
                          .map((cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)))
                          .toList(),
                      onChanged: (value) => setState(() => category = value!),
                      onSaved: (value) => category = value!,
                    ),
                    TextFormField(
                      initialValue: price != 0.0 ? price.toString() : '',
                      decoration: const InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a price' : null,
                      onSaved: (value) => price = double.parse(value!),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: saveGift,
                      child: const Text('Save'),
                    ),
                  ],
                ),
              )
            : const Center(
                child: Text(
                  'This gift cannot be edited because it has been pledged.',
                  textAlign: TextAlign.center,
                ),
              ),
      ),
    );
  }
}
