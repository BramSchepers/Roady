import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Login/registratie: één scherm met toggle "Account aanmaken" (standaard) of "Log in".
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isSignUp = true;
  bool _isLoading = false;
  String? _errorMessage;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();

  static const _primary = Color(0xFFF97316);
  static const _heroBg = Color(0xFFe8f0e9);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (_isSignUp) {
        final confirm = _confirmPasswordController.text;
        if (password != confirm) {
          setState(() {
            _errorMessage = 'Wachtwoorden komen niet overeen.';
            _isLoading = false;
          });
          return;
        }
        if (password.length < 6) {
          setState(() {
            _errorMessage = 'Kies een wachtwoord van minstens 6 tekens.';
            _isLoading = false;
          });
          return;
        }
        final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final name = _displayNameController.text.trim();
        if (name.isNotEmpty && cred.user != null) {
          await cred.user!.updateDisplayName(name);
        }
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
      // Auth state will update; GoRouter redirect will navigate to dashboard/payment
    } on FirebaseAuthException catch (e) {
      final msg = _authErrorToDutch(e.code);
      setState(() {
        _errorMessage = msg;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Er ging iets mis. Probeer het opnieuw.';
        _isLoading = false;
      });
    }
  }

  Future<void> _sendPasswordReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() =>
          _errorMessage = 'Vul je e-mailadres in om wachtwoord te resetten.');
      return;
    }
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('E-mail om wachtwoord te resetten is verzonden.')),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _authErrorToDutch(e.code);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Kon reset-e-mail niet versturen.';
        _isLoading = false;
      });
    }
  }

  static String _authErrorToDutch(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Dit e-mailadres is al in gebruik.';
      case 'invalid-email':
        return 'Ongeldig e-mailadres.';
      case 'operation-not-allowed':
        return 'Deze aanmelding is niet toegestaan.';
      case 'weak-password':
        return 'Kies een sterker wachtwoord (min. 6 tekens).';
      case 'user-disabled':
        return 'Dit account is uitgeschakeld.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Verkeerd e-mailadres of wachtwoord.';
      case 'too-many-requests':
        return 'Te veel pogingen. Wacht even en probeer opnieuw.';
      default:
        return 'Er ging iets mis. Probeer het opnieuw.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _heroBg,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: _heroBg,
              child: SvgPicture.asset(
                'assets/illustrations/Background_hero.svg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 24),
                        Center(
                          child: SvgPicture.asset(
                            'images/logo-roady.svg',
                            height: 48,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isSignUp ? 'Account aanmaken' : 'Inloggen',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red.shade800),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (_isSignUp)
                          TextFormField(
                            controller: _displayNameController,
                            decoration: const InputDecoration(
                              labelText: 'Naam (optioneel)',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                        if (_isSignUp) const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          decoration: const InputDecoration(
                            labelText: 'E-mail',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return 'Vul je e-mail in.';
                            if (!v.contains('@'))
                              return 'Vul een geldig e-mailadres in.';
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Wachtwoord',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'Vul je wachtwoord in.';
                            if (_isSignUp && v.length < 6)
                              return 'Minimaal 6 tekens.';
                            return null;
                          },
                          textInputAction: _isSignUp
                              ? TextInputAction.next
                              : TextInputAction.done,
                        ),
                        if (_isSignUp) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Wachtwoord bevestigen',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (v) {
                              if (_isSignUp && v != _passwordController.text) {
                                return 'Wachtwoorden komen niet overeen.';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.done,
                          ),
                        ],
                        if (!_isSignUp) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _isLoading ? null : _sendPasswordReset,
                              child: const Text('Wachtwoord vergeten?'),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  if (_formKey.currentState?.validate() ??
                                      false) _submit();
                                },
                          style: FilledButton.styleFrom(
                            backgroundColor: _primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(
                                  _isSignUp ? 'Account aanmaken' : 'Inloggen'),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _isSignUp = !_isSignUp;
                                    _errorMessage = null;
                                  });
                                },
                          child: Text(
                            _isSignUp
                                ? 'Al een account? Log in'
                                : 'Geen account? Account aanmaken',
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
