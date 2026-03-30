import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../../../core/widgets/pretty_neumorphic_button.dart';
import '../../../../providers/review_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/business_provider.dart'; // Import BusinessProvider

class WriteReviewScreen extends StatefulWidget {
  final String businessId;
  final String businessName;
  final String? productId;
  final String? productName;

  const WriteReviewScreen({
    Key? key,
    required this.businessId,
    required this.businessName,
    this.productId,
    this.productName,
  }) : super(key: key);

  @override
  _WriteReviewScreenState createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _commentController = TextEditingController();
  double _rating = 5.0;
  bool _targetProduct = false;
  String? _selectedProductId;
  String? _selectedProductName;

  @override
  void initState() {
    super.initState();
    _targetProduct = widget.productId != null;
    _selectedProductId = widget.productId;
    _selectedProductName = widget.productName;

    // Fetch products for the business so we can populate the dropdown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BusinessProvider>(context, listen: false)
          .fetchBusinessDetails(widget.businessId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final businessProvider = Provider.of<BusinessProvider>(context); // Get business provider

    final titleText = _targetProduct
        ? 'Reviewing: ${_selectedProductName ?? 'Select a Product'}'
        : 'How was your experience at ${widget.businessName}?';

    // Show as a modal-style centered card so it looks like the in-place popup
    return Scaffold(
      backgroundColor: Colors.black54,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => context.pop(), // tap outside to dismiss
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: GestureDetector(
                  onTap: () {}, // absorb taps inside the card
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header row with title and close
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    titleText,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => context.pop(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Toggle between Business and Product
                            Center(
                              child: SegmentedButton<bool>(
                                segments: const [
                                  ButtonSegment<bool>(
                                    value: false,
                                    label: Text('Business'),
                                    icon: Icon(LucideIcons.store),
                                  ),
                                  ButtonSegment<bool>(
                                    value: true,
                                    label: Text('Product'),
                                    icon: Icon(LucideIcons.package),
                                  ),
                                ],
                                selected: {_targetProduct},
                                onSelectionChanged: (Set<bool> newSelection) {
                                  setState(() {
                                    _targetProduct = newSelection.first;
                                    // If switching to business, clear product selection visual cues if desired,
                                    // but keeping the ID is fine.
                                  });
                                },
                              ),
                            ),

                            if (_targetProduct) ...[
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedProductId,
                                decoration: InputDecoration(
                                  labelText: 'Select Product',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                items: businessProvider.products.map((product) {
                                  return DropdownMenuItem<String>(
                                    value: product.id,
                                    child: Text(
                                      product.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedProductId = value;
                                    final product = businessProvider.products
                                        .firstWhere((p) => p.id == value, orElse: () => businessProvider.products.first);
                                     // fallback shouldn't happen if value is valid
                                    _selectedProductName = product.name;
                                  });
                                },
                                hint: const Text('Choose a product to review'),
                              ),
                            ],


                            const SizedBox(height: 16),

                            // Rating Bar
                            Center(
                              child: RatingBar.builder(
                                initialRating: _rating,
                                minRating: 1,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                                itemBuilder: (context, _) => const Icon(
                                  LucideIcons.star,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: (rating) {
                                  setState(() {
                                    _rating = rating;
                                  });
                                },
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Comment Field
                            TextFormField(
                              controller: _commentController,
                              maxLines: 5,
                              decoration: InputDecoration(
                                hintText: 'Share your experience with this business...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF1E2E4F)),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a comment';
                                }
                                if (value.length < 10) {
                                  return 'Comment must be at least 10 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              child: PrettyNeumorphicButton(
                                label: const Text(
                                  'Submit Review',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    if (_targetProduct && _selectedProductId == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Please select a product')),
                                      );
                                      return;
                                    }

                                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
                                    final user = authProvider.userModel;

                                    if (user == null) return;

                                    bool success = await reviewProvider.postReview(
                                      businessId: widget.businessId,
                                      userId: user.uid,
                                      userName: user.name,
                                      rating: _rating,
                                      comment: _commentController.text.trim(),
                                      productId: _targetProduct ? _selectedProductId : null,
                                    );

                                    if (success) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Review posted successfully!')),
                                      );
                                      context.pop();
                                    } else if (reviewProvider.error != null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(reviewProvider.error!)),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
