import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/business_provider.dart';
import '../../../../data/models/business_model.dart';
import '../../../../data/models/product_model.dart';

class BuildProfileScreen extends StatefulWidget {
  const BuildProfileScreen({Key? key}) : super(key: key);

  @override
  _BuildProfileScreenState createState() => _BuildProfileScreenState();
}

class _BuildProfileScreenState extends State<BuildProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Step 1: Basic Info
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Step 2: Social & Links
  final _instagramController = TextEditingController();
  final _twitterController = TextEditingController();
  final _facebookController = TextEditingController();
  final _websiteController = TextEditingController();

  // Step 3: Profile Picture
  final _logoUrlController = TextEditingController();

  // Step 4: Products
  final List<Map<String, dynamic>> _products = [];

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.userModel != null) {
      _nameController.text = authProvider.userModel!.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _instagramController.dispose();
    _twitterController.dispose();
    _facebookController.dispose();
    _websiteController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  void _addProduct() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final imageUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _products.add({
                  'name': nameController.text,
                  'price': double.tryParse(priceController.text) ?? 0.0,
                  'imageUrl': imageUrlController.text,
                });
              });
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Build Your Business Profile'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.logOut),
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.signOut();
              context.go('/login');
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          onStepTapped: (step) {
            setState(() => _currentStep = step);
          },
          onStepContinue: () {
            if (_currentStep == 0) {
              if (_nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Business Name is required')),
                );
                return;
              }
              if (_descriptionController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Description is required')),
                );
                return;
              }
            }

            if (_currentStep < 3) {
              setState(() => _currentStep += 1);
            } else {
              if (_products.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please add at least one product')),
                );
                return;
              }
              _handleFinalSubmit();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep -= 1);
            }
          },
          steps: [
            Step(
              title: const Text('Basic'),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Business Name *',
                      hintText: 'e.g. Glow Beauty Spa',
                    ),
                    validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location (Optional)',
                      hintText: 'e.g. Lagos, Nigeria',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description *',
                      hintText: 'Tell us about your beauty business',
                    ),
                    maxLines: 3,
                    validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                  ),
                ],
              ),
            ),
            Step(
              title: const Text('Social'),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              content: Column(
                children: [
                  TextFormField(
                    controller: _instagramController,
                    decoration: const InputDecoration(
                      labelText: 'Instagram Handle',
                      prefixIcon: Icon(LucideIcons.instagram),
                      hintText: '@username',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _twitterController,
                    decoration: const InputDecoration(
                      labelText: 'Twitter Handle',
                      prefixIcon: Icon(LucideIcons.twitter),
                      hintText: '@username',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _facebookController,
                    decoration: const InputDecoration(
                      labelText: 'Facebook Page',
                      prefixIcon: Icon(LucideIcons.facebook),
                      hintText: 'facebook.com/page',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _websiteController,
                    decoration: const InputDecoration(
                      labelText: 'Website/Store Link (Optional)',
                      prefixIcon: Icon(LucideIcons.link),
                      hintText: 'https://...',
                    ),
                  ),
                ],
              ),
            ),
            Step(
              title: const Text('Logo'),
              isActive: _currentStep >= 2,
              state: _currentStep > 2 ? StepState.complete : StepState.indexed,
              content: Column(
                children: [
                  TextFormField(
                    controller: _logoUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Logo Image URL',
                      hintText: 'https://example.com/logo.png',
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                  const SizedBox(height: 24),
                  if (_logoUrlController.text.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF1E2E4F), width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: NetworkImage(_logoUrlController.text),
                        onBackgroundImageError: (_, __) => const Icon(LucideIcons.image, size: 40),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF1E2E4F), width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: const AssetImage('assets/app_logo.png'),
                      ),
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    'Provide a URL for your business logo',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Step(
              title: const Text('Products'),
              isActive: _currentStep >= 3,
              state: _currentStep == 3 ? StepState.editing : StepState.indexed,
              content: Column(
                children: [
                  const Text(
                    'Add at least one product to showcase your business',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _addProduct,
                    icon: const Icon(LucideIcons.plus),
                    label: const Text('Add Product'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E2E4F),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_products.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(LucideIcons.package, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('No products added yet', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _products.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: product['imageUrl'] != null && product['imageUrl'].isNotEmpty
                                ? Image.network(product['imageUrl'], width: 50, height: 50, fit: BoxFit.cover)
                                : Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[200],
                              child: const Icon(LucideIcons.image, size: 20),
                            ),
                          ),
                          title: Text(product['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('\$${product['price']}'),
                          trailing: IconButton(
                            icon: const Icon(LucideIcons.trash2, color: Colors.red, size: 20),
                            onPressed: () => setState(() => _products.removeAt(index)),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleFinalSubmit() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final businessProvider = Provider.of<BusinessProvider>(context, listen: false);

    if (authProvider.userModel == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final businessId = 'biz_${authProvider.userModel!.uid}';
      final business = BusinessModel(
        id: businessId,
        ownerId: authProvider.userModel!.uid,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        instagram: _instagramController.text.trim(),
        twitter: _twitterController.text.trim(),
        facebook: _facebookController.text.trim(),
        ecommerceLink: _websiteController.text.trim(),
        logoUrl: _logoUrlController.text.trim(),
        trustScore: 5.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save business
      await businessProvider.updateBusinessProfile(business);

      // Save products
      for (var p in _products) {
        final product = ProductModel(
          id: const Uuid().v4(),
          businessId: businessId,
          categoryId: 'general',
          name: p['name'],
          price: p['price'],
          imageUrl: p['imageUrl'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await businessProvider.addProduct(product);
      }

      // Mark profile as built with the business name
      await authProvider.markProfileAsBuilt(name: _nameController.text.trim());

      if (!mounted) return;
      Navigator.pop(context); // Pop loading
      context.go('/business-dashboard');
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Pop loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to build profile: $e')),
      );
    }
  }
}
