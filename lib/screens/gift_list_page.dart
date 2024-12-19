import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/gift_card.dart';
import '../models/gift.dart';
import '../models/event.dart';
import '../models/friend.dart';

class GiftListPage extends StatefulWidget {
  final Event? event;
  final Friend? friend;

  const GiftListPage({super.key, this.event, this.friend});

  @override
  State<GiftListPage> createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  String sortBy = 'name';

  void sortGifts(List<Gift> gifts, String criterion) {
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
    Navigator.pushNamed(
      context,
      '/gift-details',
      arguments: {'event': widget.event},
    );
  }

  void editGift(Gift gift) {
    Navigator.pushNamed(
      context,
      '/gift-details',
      arguments: gift,
    );
  }

  Future<void> deleteGift(Gift gift) async {
    await FirebaseFirestore.instance.collection('gifts').doc(gift.id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gift "${gift.name}" deleted')),
    );
  }

  Future<void> pledgeGift(Gift gift) async {
    await FirebaseFirestore.instance.collection('gifts').doc(gift.id).update({
      'status': 'Pledged',
      'pledgedBy': 'currentUserId', // Replace with the actual user ID
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pledged "${gift.name}"')),
    );
  }

  @override
  Widget build(BuildContext context) {
    String title = 'Gifts';
    bool isOwnEvent = widget.event != null;

    if (widget.event != null) {
      title = widget.event!.name;
    } else if (widget.friend != null) {
      title = '${widget.friend!.name}\'s Gifts';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          PopupMenuButton<String>(
            onSelected: (criterion) => setState(() {
              sortBy = criterion;
            }),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'name', child: Text('Sort by Name')),
              const PopupMenuItem(
                  value: 'category', child: Text('Sort by Category')),
              const PopupMenuItem(
                  value: 'status', child: Text('Sort by Status')),
            ],
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('gifts')
            .where('eventId', isEqualTo: widget.event?.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No gifts found.'));
          }

          List<Gift> gifts = snapshot.data!.docs
              .map((doc) =>
                  Gift.fromFirestore(doc.data() as Map<String, dynamic>))
              .toList();

          sortGifts(gifts, sortBy);

          return ListView.builder(
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
          );
        },
      ),
      floatingActionButton: isOwnEvent
          ? FloatingActionButton(
              onPressed: addGift,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
