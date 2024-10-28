// lib/screens/gift_details_page.dart
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
  String category = 'Electronics';
  late double price;
  bool isPledged = false;

  final List<String> categories = [
    'Electronics',
    'Books',
    'Clothing',
    'Home',
    'Toys',
    // Add more categories as needed
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
      // Implement functionality to save the gift details
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
                    // Implement image upload functionality
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
