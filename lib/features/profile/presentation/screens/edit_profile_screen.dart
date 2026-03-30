import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:form_validator/form_validator.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/business_provider.dart';
import '../../../../data/models/business_model.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';
import '../../../../core/widgets/pretty_neumorphic_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;

  // Business specific controllers
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late TextEditingController _instagramController;
  late TextEditingController _twitterController;
  late TextEditingController _facebookController;
  late TextEditingController _websiteController;
  late TextEditingController _logoUrlController;

  bool _isBusiness = false;
  BusinessModel? _business;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userModel;
    _isBusiness = user?.role == 'business';

    _nameController = TextEditingController(text: user?.name);
    _bioController = TextEditingController(text: user?.bio);

    _locationController = TextEditingController();
    _descriptionController = TextEditingController();
    _instagramController = TextEditingController();
    _twitterController = TextEditingController();
    _facebookController = TextEditingController();
    _websiteController = TextEditingController();
    _logoUrlController = TextEditingController();

    if (_isBusiness) {
      _loadBusinessData();
    }
  }

  void _loadBusinessData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    final user = authProvider.userModel;
    if (user != null) {
      await businessProvider.fetchBusinessByOwner(user.uid);
      _business = businessProvider.currentBusiness;

      if (_business != null) {
        setState(() {
          _locationController.text = _business!.location ?? '';
          _descriptionController.text = _business!.description ?? '';
          _instagramController.text = _business!.instagram ?? '';
          _twitterController.text = _business!.twitter ?? '';
          _facebookController.text = _business!.facebook ?? '';
          _websiteController.text = _business!.ecommerceLink ?? '';
          _logoUrlController.text = _business!.logoUrl ?? '';
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _instagramController.dispose();
    _twitterController.dispose();
    _facebookController.dispose();
    _websiteController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  void _handleUpdate() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final businessProvider = Provider.of<BusinessProvider>(context, listen: false);

      bool userSuccess = await authProvider.updateProfile(
        name: _nameController.text.trim(),
        bio: _bioController.text.trim(),
      );

      bool businessSuccess = true;
      if (_isBusiness && _business != null) {
        final updatedBusiness = BusinessModel(
          id: _business!.id,
          ownerId: _business!.ownerId,
          name: _nameController.text.trim(), // Keep name in sync
          description: _descriptionController.text.trim(),
          location: _locationController.text.trim(),
          instagram: _instagramController.text.trim(),
          twitter: _twitterController.text.trim(),
          facebook: _facebookController.text.trim(),
          ecommerceLink: _websiteController.text.trim(),
          logoUrl: _logoUrlController.text.trim(),
          trustScore: _business!.trustScore,
          createdAt: _business!.createdAt,
          updatedAt: DateTime.now(),
        );
        businessSuccess = await businessProvider.updateBusinessProfile(updatedBusiness);
      }

      if (userSuccess && businessSuccess) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.of(context).pop();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.error ?? businessProvider.error ?? 'Failed to update profile')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final businessProvider = Provider.of<BusinessProvider>(context);
    final isLoading = authProvider.isLoading || businessProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Personal Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  icon: LucideIcons.user,
                  validator: ValidationBuilder().minLength(3).build(),
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _bioController,
                  label: 'Bio',
                  hint: 'Tell us about yourself',
                  icon: LucideIcons.info,
                  validator: (value) => null,
                ),
                if (_isBusiness) ...[
                  const SizedBox(height: 32),
                  const Text(
                    'Business Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: _descriptionController,
                    label: 'Business Description',
                    hint: 'Describe your business',
                    icon: LucideIcons.fileText,
                    validator: ValidationBuilder().minLength(10).build(),
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: _locationController,
                    label: 'Location',
                    hint: 'e.g. Lagos, Nigeria',
                    icon: LucideIcons.mapPin,
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: _logoUrlController,
                    label: 'Logo URL',
                    hint: 'https://...',
                    icon: LucideIcons.image,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Social & Links',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: _instagramController,
                    label: 'Instagram',
                    hint: '@username',
                    icon: LucideIcons.instagram,
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: _twitterController,
                    label: 'Twitter',
                    hint: '@username',
                    icon: LucideIcons.twitter,
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: _facebookController,
                    label: 'Facebook',
                    hint: 'facebook.com/page',
                    icon: LucideIcons.facebook,
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: _websiteController,
                    label: 'Website/Store Link',
                    hint: 'https://...',
                    icon: LucideIcons.link,
                  ),
                ],
                const SizedBox(height: 40),
                PrettyNeumorphicButton(
                  onPressed: isLoading ? null : _handleUpdate,
                  label: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
