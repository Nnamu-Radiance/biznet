import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../providers/business_provider.dart';
import '../../../../providers/auth_provider.dart';
import 'package:intl/intl.dart';

class BusinessReviewsScreen extends StatefulWidget {
  const BusinessReviewsScreen({Key? key}) : super(key: key);

  @override
  _BusinessReviewsScreenState createState() => _BusinessReviewsScreenState();
}

class _BusinessReviewsScreenState extends State<BusinessReviewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.userModel != null) {
        Provider.of<BusinessProvider>(context, listen: false)
            .fetchBusinessByOwner(authProvider.userModel!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final businessProvider = Provider.of<BusinessProvider>(context);
    final reviews = businessProvider.reviews;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.filter),
            onPressed: () {},
          ),
        ],
      ),
      body: businessProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : reviews.isEmpty
          ? const Center(child: Text('No reviews yet.'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final review = reviews[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFF1E2E4F).withValues(alpha: 0.1),
                            child: const Icon(LucideIcons.user, color: Color(0xFF1E2E4F), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            review.userName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(LucideIcons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(review.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    review.text,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: const Text('Reply', style: TextStyle(color: Color(0xFF1E2E4F))),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat('MMM d, yyyy').format(review.createdAt),
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
