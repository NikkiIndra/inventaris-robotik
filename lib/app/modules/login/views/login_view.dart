import 'package:flutter/material.dart';

import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});
  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: Center(
        child: isSmallScreen
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [Logo(), _formLogin()],
              )
            : Container(
                padding: const EdgeInsets.all(32),
                constraints: const BoxConstraints(maxWidth: 800),
                child: Row(
                  children: [
                    Expanded(child: Logo()),
                    Expanded(child: Center(child: _formLogin())),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _formLogin() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Form(
        key: controller.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: controller.emailController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter username or email';
                }
                final trimmed = value.trim();

                // allow fixed username 'koperasi'
                if (trimmed == 'robotik') return null;

                // otherwise validate as email
                final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
                if (!emailRegex.hasMatch(trimmed)) return 'Invalid email';
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Username or Email',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            Obx(
              () => TextFormField(
                obscureText: !controller.isPasswordVisible.value,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter password';
                  if (value.length < 6) return 'Min 6 chars';
                  return null;
                },
                controller: controller.passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPasswordVisible.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: controller.togglePassword,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Obx(
              () => CheckboxListTile(
                value: controller.rememberMe.value,
                title: const Text('Remember me'),
                onChanged: (value) => controller.toggleRemember(value!),
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.submit,
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Login Now',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/robotik.png',
          height: isSmallScreen ? 100 : 200,
          width: isSmallScreen ? 100 : 200,
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Welcome to Inventaris ROBOTIK!",

            textAlign: TextAlign.center,
            style: isSmallScreen
                ? TextStyle(fontSize: 20, fontWeight: FontWeight.w600)
                : TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
