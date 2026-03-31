import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:form_validator/form_validator.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../core/widgets/pretty_neumorphic_button.dart';
import '../../../../core/widgets/auth_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'customer';

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.pendingRole != null) {
      _selectedRole = authProvider.pendingRole!;
    } else {
      // Initialize pending role with default selection
      authProvider.setPendingRole(_selectedRole);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool success = await authProvider.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        role: _selectedRole,
      );

      if (success) {
        if (!mounted) return;
        Future.microtask(() {
          if (_selectedRole == 'business') {
            context.go('/build-profile');
          } else {
            context.go('/');
          }
        });
      } else if (authProvider.error != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error!),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.go('/login'),
        ),
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
                  'Join the BIZNET Community',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'find businesses you can trust, and grow your business with us.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                AuthTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  icon: LucideIcons.user,
                  validator: ValidationBuilder().minLength(3).build(),
                ),
                AuthTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Enter your email',
                  icon: LucideIcons.mail,
                  keyboardType: TextInputType.emailAddress,
                  validator: ValidationBuilder().email().build(),
                ),
                AuthTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter your password',
                  icon: LucideIcons.lock,
                  isPassword: true,
                  validator: ValidationBuilder().minLength(6).build(),
                ),
                const SizedBox(height: 16),
                const Text(
                  'I am a:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Customer'),
                        selected: _selectedRole == 'customer',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedRole = 'customer');
                            Provider.of<AuthProvider>(context, listen: false).setPendingRole('customer');
                          }
                        },
                        selectedColor: const Color.fromRGBO(30, 46, 79, 0.2), // changed from pink to match theme
                        labelStyle: TextStyle(
                          color: _selectedRole == 'customer' ? const Color(0xFF1E2E4F) : Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Business'),
                        selected: _selectedRole == 'business',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedRole = 'business');
                            Provider.of<AuthProvider>(context, listen: false).setPendingRole('business');
                          }
                        },
                        selectedColor: const Color.fromRGBO(30, 46, 79, 0.2), // changed from pink to match theme
                        labelStyle: TextStyle(
                          color: _selectedRole == 'business' ? const Color(0xFF1E2E4F) : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                PrettyNeumorphicButton(
                  onPressed: authProvider.isLoading ? null : _handleSignup,
                  label: authProvider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Sign Up',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('OR', style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: authProvider.isLoading
                      ? null
                      : () async {
                    // Capture role locally to avoid state reset during async call
                    final roleToUse = _selectedRole;
                    bool success = await authProvider.signInWithGoogle(role: roleToUse);
                    if (!mounted) return;
                    if (success) {
                      Future.microtask(() {
                        if (roleToUse == 'business') {
                          context.go('/build-profile');
                        } else {
                          context.go('/');
                        }
                      });
                    } else if (authProvider.error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(authProvider.error!),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  },
                  icon: const Icon(LucideIcons.chrome, size: 20),
                  label: const Text('Sign up with Google', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: Colors.grey),
                    foregroundColor: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
