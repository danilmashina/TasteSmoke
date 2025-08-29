import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../utils/theme.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isResetting = false;
  bool _needsVerification = false;
  bool _isTermsAccepted = false;
  bool _isPrivacyAccepted = false;
  String? _message;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Настраиваем русский язык для Firebase Auth (как в Android версии)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authServiceProvider).setLanguageCode('ru');
    });
  }

  bool get _isAgreementsAccepted => _isTermsAccepted && _isPrivacyAccepted;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.paddingLarge),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.paddingLarge),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Заголовок
                        Text(
                          'TasteSmoke',
                          style: AppTheme.h1.copyWith(
                            color: AppTheme.accentPink,
                          ),
                        ),
                        const SizedBox(height: AppTheme.paddingSmall),
                        Text(
                          'Миксы для кальяна',
                          style: AppTheme.body.copyWith(
                            color: AppTheme.secondaryText,
                          ),
                        ),
                        const SizedBox(height: AppTheme.paddingLarge),

                        // Email поле
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'Введите ваш email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Введите email';
                            }
                            if (!value.contains('@')) {
                              return 'Введите корректный email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppTheme.paddingMedium),

                        // Поле пароля
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Пароль',
                            hintText: 'Введите пароль',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Введите пароль';
                            }
                            if (value.length < 6) {
                              return 'Пароль должен содержать минимум 6 символов';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppTheme.paddingMedium),

                        // Соглашения
                        _buildAgreements(),
                        const SizedBox(height: AppTheme.paddingLarge),

                        // Кнопки входа и регистрации
                        if (!_needsVerification) ...[
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isLoading || !_isAgreementsAccepted
                                      ? null
                                      : _signIn,
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text('Войти'),
                                ),
                              ),
                              const SizedBox(width: AppTheme.paddingMedium),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _isLoading || !_isAgreementsAccepted
                                      ? null
                                      : _register,
                                  child: const Text(
                                    'Регистрация',
                                    style: TextStyle(color: AppTheme.accentPink),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.paddingMedium),

                          // Кнопка сброса пароля
                          TextButton(
                            onPressed: _isLoading ? null : _resetPassword,
                            child: Text(
                              _isResetting
                                  ? 'Отправляем...'
                                  : 'Забыли пароль?',
                              style: const TextStyle(color: AppTheme.accentPink),
                            ),
                          ),
                        ],

                        // Блок верификации email
                        if (_needsVerification) ...[
                          Container(
                            padding: const EdgeInsets.all(AppTheme.paddingMedium),
                            decoration: BoxDecoration(
                              color: AppTheme.accentPink.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                              border: Border.all(
                                color: AppTheme.accentPink.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.email_outlined,
                                  size: 48,
                                  color: AppTheme.accentPink,
                                ),
                                const SizedBox(height: AppTheme.paddingMedium),
                                const Text(
                                  'Подтвердите email',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryText,
                                  ),
                                ),
                                const SizedBox(height: AppTheme.paddingSmall),
                                Text(
                                  'Мы отправили письмо с подтверждением на ${_emailController.text}. Проверьте почту и нажмите на ссылку.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: AppTheme.secondaryText),
                                ),
                                const SizedBox(height: AppTheme.paddingMedium),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: _resendVerification,
                                        child: const Text(
                                          'Отправить повторно',
                                          style: TextStyle(color: AppTheme.accentPink),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppTheme.paddingMedium),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _checkVerification,
                                        child: const Text('Получено'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Сообщение об ошибке/успехе
                        if (_message != null) ...[
                          const SizedBox(height: AppTheme.paddingMedium),
                          Container(
                            padding: const EdgeInsets.all(AppTheme.paddingMedium),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              _message!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ],
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

  Widget _buildAgreements() {
    return Column(
      children: [
        // Пользовательское соглашение
        Row(
          children: [
            Checkbox(
              value: _isTermsAccepted,
              onChanged: (value) {
                setState(() {
                  _isTermsAccepted = value ?? false;
                });
              },
              activeColor: AppTheme.accentPink,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => _showTermsDialog(),
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: AppTheme.secondaryText),
                    children: [
                      TextSpan(text: 'Я согласен с '),
                      TextSpan(
                        text: 'пользовательским соглашением',
                        style: TextStyle(
                          color: AppTheme.accentPink,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        // Согласие на обработку данных
        Row(
          children: [
            Checkbox(
              value: _isPrivacyAccepted,
              onChanged: (value) {
                setState(() {
                  _isPrivacyAccepted = value ?? false;
                });
              },
              activeColor: AppTheme.accentPink,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => _showPrivacyDialog(),
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: AppTheme.secondaryText),
                    children: [
                      TextSpan(text: 'Я согласен на '),
                      TextSpan(
                        text: 'обработку персональных данных',
                        style: TextStyle(
                          color: AppTheme.accentPink,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    final authService = ref.read(authServiceProvider);
    final result = await authService.signInWithEmailAndPassword(
      _emailController.text,
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (result.isSuccess) {
      // Навигация обрабатывается автоматически через authProvider
    } else {
      setState(() {
        _message = result.error;
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    final authService = ref.read(authServiceProvider);
    final result = await authService.registerWithEmailAndPassword(
      _emailController.text,
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (result.isSuccess) {
      setState(() {
        _needsVerification = true;
        _message = result.message;
      });
    } else {
      setState(() {
        _message = result.error;
      });
    }
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) {
      setState(() {
        _message = 'Введите email для сброса пароля';
      });
      return;
    }

    setState(() {
      _isResetting = true;
      _message = null;
    });

    final authService = ref.read(authServiceProvider);
    final result = await authService.resetPassword(_emailController.text);

    setState(() {
      _isResetting = false;
      _message = result.isSuccess ? result.message : result.error;
    });
  }

  Future<void> _resendVerification() async {
    final authService = ref.read(authServiceProvider);
    final result = await authService.resendVerificationEmail();

    setState(() {
      _message = result.isSuccess ? result.message : result.error;
    });
  }

  Future<void> _checkVerification() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    // Пытаемся войти снова, чтобы проверить верификацию
    final authService = ref.read(authServiceProvider);
    final result = await authService.signInWithEmailAndPassword(
      _emailController.text,
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (result.isSuccess) {
      // Успешно вошли - email подтвержден
    } else {
      setState(() {
        _message = result.error;
      });
    }
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Пользовательское соглашение'),
        content: const SingleChildScrollView(
          child: Text(
            'Используя приложение TasteSmoke, вы соглашаетесь с условиями использования и несете ответственность за публикуемый контент. Приложение предназначено для лиц старше 18 лет.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Отмена',
              style: TextStyle(color: AppTheme.accentPink),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _isTermsAccepted = true;
              });
              Navigator.pop(context);
            },
            child: const Text(
              'Принимаю',
              style: TextStyle(color: AppTheme.accentPink),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Обработка персональных данных'),
        content: const SingleChildScrollView(
          child: Text(
            'Мы собираем и обрабатываем ваши данные (email, никнейм, фото профиля) для обеспечения работы приложения. Данные защищены и не передаются третьим лицам.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Отмена',
              style: TextStyle(color: AppTheme.accentPink),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _isPrivacyAccepted = true;
              });
              Navigator.pop(context);
            },
            child: const Text(
              'Принимаю',
              style: TextStyle(color: AppTheme.accentPink),
            ),
          ),
        ],
      ),
    );
  }
}