import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';
import 'package:hybrid_digital_docs_assignment_frontend/core/auth/auth_provider.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/utils/dialog_utils.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_button.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_card.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    DialogUtils.showLoadingDialog(context, message: 'login.authenticating'.tr());

    try {
      await ref.read(authProvider.notifier).login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (mounted) DialogUtils.hideLoadingDialog(context);
    } catch (e) {
      if (mounted) DialogUtils.hideLoadingDialog(context);

      if (mounted) {
        setState(() {
          String rawError = e.toString().replaceAll('Exception: ', '');
          if (rawError.toLowerCase().contains('provided credentials are incorrect') || rawError.toLowerCase().contains('invalid email or password')) {
            _errorMessage = 'login.invalid_credentials'.tr();
          } else {
            _errorMessage = rawError;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Login Card
                CustomCard(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Image.asset(
                        'assets/images/logo1.png',
                        height: 80,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'login.sign_in'.tr(),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'login.subtitle'.tr(),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Email Field
                      CustomTextField(
                        label: 'login.email'.tr(),
                        hintText: 'login.email_hint'.tr(),
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => value == null || value.isEmpty ? 'login.error_email_required'.tr() : null,
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      CustomTextField(
                        label: 'login.password'.tr(),
                        hintText: 'login.password_hint'.tr(),
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        validator: (value) => value == null || value.isEmpty ? 'login.error_password_required'.tr() : null,
                        suffixIcon: IconButton(
                          icon: HeroIcon(
                            _obscurePassword ? HeroIcons.eyeSlash : HeroIcons.eye,
                            size: 20,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              HeroIcon(HeroIcons.exclamationCircle, color: theme.colorScheme.error, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 32),

                      // Login Button
                      CustomButton(
                        text: 'login.sign_in'.tr(),
                        onPressed: _handleLogin,
                      ),
                      const SizedBox(height: 16),

                      // Language Switcher
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () {
                            if (context.locale.languageCode == 'en') {
                              context.setLocale(const Locale('km'));
                            } else {
                              context.setLocale(const Locale('en'));
                            }
                          },
                          icon: const HeroIcon(HeroIcons.language, size: 20),
                          label: Text(
                            context.locale.languageCode == 'en' ? 'English' : 'ភាសាខ្មែរ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                        ),
                      ),
                    ],
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
