import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _isChanging = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: StreamBuilder<UserModel?>(
          stream: _authService.currentUserModel,
          builder: (context, snapshot) {
            final user = snapshot.data;
            if (user == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView(
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_circle,
                        size: 48, color: Colors.orangeAccent),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.email,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('Role: ${user.role.toUpperCase()}',
                            style: const TextStyle(color: Colors.orangeAccent)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Account Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.email, color: Colors.orangeAccent),
                            const SizedBox(width: 8),
                            Expanded(child: Text(user.email, style: const TextStyle(fontSize: 16))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Text('Password:', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text('••••••••', style: TextStyle(fontSize: 16, letterSpacing: 2)),
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.lock_reset, color: Colors.orangeAccent),
                              label: const Text('Change Password', style: TextStyle(color: Colors.orangeAccent)),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.orangeAccent,
                              ),
                              onPressed: () => _showChangePasswordDialog(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text('About',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                const Text('This is a cooking recipe app. Version 1.0.0'),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isChanging
                ? null
                : () async {
                    if (_passwordController.text != _confirmController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Passwords do not match'),
                            backgroundColor: Colors.red),
                      );
                      return;
                    }
                    if (_passwordController.text.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Password must be at least 6 characters'),
                            backgroundColor: Colors.red),
                      );
                      return;
                    }
                    setState(() {
                      _isChanging = true;
                    });
                    try {
                      await _authService.changePassword(_passwordController.text);
                      _passwordController.clear();
                      _confirmController.clear();
                      await _authService.logout();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password changed successfully. Please log in again.')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                      );
                    } finally {
                      setState(() {
                        _isChanging = false;
                      });
                    }
                  },
            child: _isChanging
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Change'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }
}
