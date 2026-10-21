import 'package:flutter/material.dart';

import 'summary_card.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const SignUpScreen(),
    );
  }
}

const groups = ['IT-2301', 'IT-2302', 'IT-2303', 'IT-2304', 'IT-2305'];

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _birthController = TextEditingController();

  final _emailFocus = FocusNode();

  String? _group;
  DateTime? _birth;

  bool _agreed = false;
  bool _done = false;

  @override
  void dispose() {
    for (final controller in [
      _name,
      _email,
      _password,
      _confirm,
      _birthController,
    ]) {
      controller.dispose();
    }

    _emailFocus.dispose();
    super.dispose();
  }

  void _unfocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _signUp() {
    if (!_agreed) return;

    if (_formKey.currentState!.validate()) {
      _unfocus();

      setState(() {
        _done = true;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Account created')));
    }
  }

  Future<void> _pickBirthDate() async {
    _unfocus();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime(2005),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (selectedDate == null) return;
    if (!mounted) return;

    setState(() {
      _birth = selectedDate;

      final day = selectedDate.day.toString().padLeft(2, '0');

      final month = selectedDate.month.toString().padLeft(2, '0');

      final year = selectedDate.year.toString();

      _birthController.text = '$day.$month.$year';
    });
  }

  void _startOver() {
    setState(() {
      for (final controller in [
        _name,
        _email,
        _password,
        _confirm,
        _birthController,
      ]) {
        controller.clear();
      }

      _group = null;
      _birth = null;
      _agreed = false;
      _done = false;
    });
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // NAME
                TextFormField(
                  controller: _name,
                  textInputAction: TextInputAction.next,

                  onFieldSubmitted: (_) {
                    _emailFocus.requestFocus();
                  },

                  onTapOutside: (_) => _unfocus(),

                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),

                  validator: (value) {
                    final name = (value ?? '').trim();

                    if (name.length < 2) {
                      return 'Name is too short';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // EMAIL
                TextFormField(
                  controller: _email,
                  focusNode: _emailFocus,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textInputAction: TextInputAction.next,

                  onTapOutside: (_) => _unfocus(),

                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'name@kbtu.kz',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),

                  validator: (value) {
                    final email = (value ?? '').trim();

                    if (!email.contains('@')) {
                      return 'Email looks wrong';
                    }

                    final atIndex = email.indexOf('@');

                    final dotIndex = email.indexOf('.', atIndex + 1);

                    if (dotIndex == -1 || dotIndex == email.length - 1) {
                      return 'Email looks wrong';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // PASSWORD
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  textInputAction: TextInputAction.next,

                  onTapOutside: (_) => _unfocus(),

                  decoration: const InputDecoration(
                    labelText: 'Password',
                    helperText: 'At least 8 characters',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),

                  onChanged: (value) {
                    setState(() {});
                  },

                  validator: (value) {
                    final password = value ?? '';

                    if (password.length < 8) {
                      return 'Password is too short';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 4),

                Text(
                  '${_password.text.length} of 8',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),

                const SizedBox(height: 16),

                // CONFIRM PASSWORD
                TextFormField(
                  controller: _confirm,
                  obscureText: true,
                  textInputAction: TextInputAction.done,

                  onFieldSubmitted: (_) {
                    _signUp();
                  },

                  onTapOutside: (_) => _unfocus(),

                  decoration: const InputDecoration(
                    labelText: 'Confirm password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_reset),
                  ),

                  validator: (value) {
                    final confirm = value ?? '';

                    if (confirm.isEmpty || confirm != _password.text) {
                      return 'Passwords do not match';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // GROUP
                DropdownButtonFormField<String>(
                  initialValue: _group,

                  decoration: const InputDecoration(
                    labelText: 'Group',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.groups_outlined),
                  ),

                  items: [
                    for (final group in groups)
                      DropdownMenuItem<String>(
                        value: group,
                        child: Text(group),
                      ),
                  ],

                  onChanged: (value) {
                    setState(() {
                      _group = value;
                    });
                  },

                  validator: (value) {
                    if (value == null) {
                      return 'Choose a group';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // DATE OF BIRTH
                TextFormField(
                  controller: _birthController,
                  readOnly: true,

                  onTap: _pickBirthDate,
                  onTapOutside: (_) => _unfocus(),

                  decoration: const InputDecoration(
                    labelText: 'Date of birth',
                    hintText: 'dd.mm.yyyy',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.cake_outlined),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),

                  validator: (value) {
                    if (_birth == null) {
                      return 'Choose a date of birth';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // AGREEMENT
                CheckboxListTile(
                  title: const Text('I agree to the rules'),
                  value: _agreed,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,

                  onChanged: (value) {
                    setState(() {
                      _agreed = value ?? false;
                    });
                  },
                ),

                const SizedBox(height: 24),

                // SIGN UP
                FilledButton(
                  onPressed: _agreed ? _signUp : null,

                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Sign up'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SummaryCard(
                name: _name.text.trim(),
                email: _email.text.trim(),
                group: _group ?? '',
                birthDate: _birthController.text,
              ),

              const SizedBox(height: 16),

              TextButton.icon(
                onPressed: _startOver,
                icon: const Icon(Icons.restart_alt),
                label: const Text('Start over'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_done ? 'Summary' : 'Sign up')),
      body: _done ? _buildSummary() : _buildForm(),
    );
  }
}
