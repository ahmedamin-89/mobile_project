// lib/screens/gift_list_page.dart
import 'package:flutter/material.dart';
import '../widgets/gift_card.dart';
import '../models/gift.dart';
import '../models/event.dart';
import '../models/friend.dart';

class GiftListPage extends StatefulWidget {
  final Event? event;
  final Friend? friend;

  const GiftListPage({Key? key, this.event, this.friend}) : super(key: key);

  @override
  State<GiftListPage> createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  List<Gift> gifts = [];

  String sortBy = 'name';

  @override
  void initState() {
    super.initState();
    // Initialize gifts based on event or friend
    if (widget.event != null) {
      gifts = getGiftsForEvent(widget.event!.id);
    } else if (widget.friend != null) {
      gifts = getGiftsForFriend(widget.friend!.id);
    }
  }

  List<Gift> getGiftsForEvent(String eventId) {
    // Return sample gifts for the event
    return [
      Gift(
        id: 'gift1',
        name: 'Wireless Headphones',
        description: 'Noise-cancelling headphones.',
        category: 'Electronics',
        price: 199.99,
        status: 'Available',
        eventId: eventId,
      ),
      Gift(
        id: 'gift2',
        name: 'Cookbook',
        description: 'Delicious recipes.',
        category: 'Books',
        price: 29.99,
        status: 'Pledged',
        eventId: eventId,
      ),
    ];
  }

  List<Gift> getGiftsForFriend(String friendId) {
    // Return sample gifts for the friend's events
    return [
      Gift(
        id: 'gift3',
        name: 'Coffee Maker',
        description: 'Automatic drip coffee maker.',
        category: 'Home Appliances',
        price: 79.99,
        status: 'Available',
        eventId: 'event3',
      ),
      Gift(
        id: 'gift4',
        name: 'Yoga Mat',
        description: 'Eco-friendly yoga mat.',
        category: 'Fitness',
        price: 39.99,
        status: 'Available',
        eventId: 'event4',
      ),
    ];
  }

  void sortGifts(String criterion) {
    setState(() {
      sortBy = criterion;
      if (criterion == 'name') {
        gifts.sort((a, b) => a.name.compareTo(b.name));
      } else if (criterion == 'category') {
        gifts.sort((a, b) => a.category.compareTo(b.category));
      } else if (criterion == 'status') {
        gifts.sort((a, b) => a.status.compareTo(b.status));
      }
    });
  }

  void navigateToGiftDetails(Gift gift) {
    Navigator.pushNamed(
      context,
      '/gift-details',
      arguments: gift,
    );
  }

  void addGift() {
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Gift functionality not implemented')),
    );
  }

  void editGift(Gift gift) {
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit Gift functionality not implemented')),
    );
  }

  void deleteGift(Gift gift) {
    setState(() {
      gifts.remove(gift);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gift "${gift.name}" deleted')),
    );
  }

  void pledgeGift(Gift gift) {
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pledged "${gift.name}"')),
    );
  }

  @override
  Widget build(BuildContext context) {
    String title = 'Gifts';
    bool isOwnEvent = false;

    if (widget.event != null) {
      title = widget.event!.name;
      isOwnEvent = true;
    } else if (widget.friend != null) {
      title = '${widget.friend!.name}\'s Gifts';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          PopupMenuButton<String>(
            onSelected: sortGifts,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'name', child: Text('Sort by Name')),
              const PopupMenuItem(
                  value: 'category', child: Text('Sort by Category')),
              const PopupMenuItem(
                  value: 'status', child: Text('Sort by Status')),
            ],
            icon: const Icon(Icons.sort),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: gifts.length,
        itemBuilder: (context, index) {
          final gift = gifts[index];
          return GiftCard(
            giftName: gift.name,
            category: gift.category,
            status: gift.status,
            onTap: () => navigateToGiftDetails(gift),
            onEdit: isOwnEvent && gift.status == 'Available'
                ? () => editGift(gift)
                : null,
            onDelete: isOwnEvent && gift.status == 'Available'
                ? () => deleteGift(gift)
                : null,
            onPledge: !isOwnEvent && gift.status == 'Available'
                ? () => pledgeGift(gift)
                : null,
          );
        },
      ),
      floatingActionButton: isOwnEvent
          ? FloatingActionButton(
              onPressed: addGift,
              child: const Icon(Icons.add),
              tooltip: 'Add Gift',
            )
          : null,
    );
  }
}
