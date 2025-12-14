
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hello_farmer/services/auth_service.dart';
import 'package:permission_handler/permission_handler.dart';

class RegisterScreen extends StatefulWidget {
  final Function toggleView;
  const RegisterScreen({super.key, required this.toggleView});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String confirmPassword = '';
  String mobileNumber = '';
  String error = '';
  bool loading = false;

  // Animation controllers
  late AnimationController _pageController;
  late AnimationController _headerController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Farmer quotes
  final List<String> _farmerQuotes = [
    "To plant a garden is to believe in tomorrow.",
    "The discovery of agriculture was the first big step toward a civilized life.",
    "It is the farmer who faithfully plants seeds in the spring who reaps a harvest in the autumn.",
    "Let us not forget that the cultivation of the earth is the most important labor of man."
  ];
  String _currentQuote = '';

  @override
  void initState() {
    super.initState();

    _currentQuote = _farmerQuotes[Random().nextInt(_farmerQuotes.length)];

    _pageController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _pageController, curve: Curves.easeOut));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _pageController, curve: Curves.easeIn),
    );

    _headerController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _scaleAnimation =
        CurvedAnimation(parent: _headerController, curve: Curves.elasticOut);

    _pageController.forward().then((_) => _headerController.forward());
  }

  @override
  void dispose() {
    _pageController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: Column(
                              children: [
                                const Text(
                                  "Create Account 🌱",
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "Start your journey with us",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  '''"$_currentQuote"''',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          TextFormField(
                            decoration: InputDecoration(
                              labelText: "Email",
                              prefixIcon: const Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            validator: (val) =>
                                val!.isEmpty ? 'Enter an email' : null,
                            onChanged: (val) => setState(() => email = val),
                          ),

                          const SizedBox(height: 20),

                          TextFormField(
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: "Mobile Number",
                              prefixIcon: const Icon(Icons.phone),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            validator: (val) =>
                                val!.isEmpty ? 'Enter a mobile number' : null,
                            onChanged: (val) => setState(() => mobileNumber = val),
                          ),

                          const SizedBox(height: 20),

                          TextFormField(
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "Password",
                              prefixIcon: const Icon(Icons.lock),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            validator: (val) => val!.length < 6
                                ? 'Password must be at least 6 characters'
                                : null,
                            onChanged: (val) => setState(() => password = val),
                          ),

                          const SizedBox(height: 20),

                          TextFormField(
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "Confirm Password",
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            validator: (val) =>
                                val != password ? 'Passwords do not match' : null,
                            onChanged: (val) => setState(() => confirmPassword = val),
                          ),

                          const SizedBox(height: 25),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: loading
                                  ? null
                                  : () async {
                                      if (_formKey.currentState!.validate()) {
                                        setState(() => loading = true);

                                        dynamic result = await _auth
                                            .registerWithEmailAndPassword(
                                                email, password, mobileNumber);
                                                
                                        if (mounted && result != null) {
                                           await _requestLocationPermission();
                                        } else if (mounted) {
                                           setState(() {
                                            error = 'Please supply a valid email';
                                            loading = false;
                                          });
                                        }
                                      }
                                    },
                              child: loading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text("Register", style: TextStyle(fontSize: 18)),
                            ),
                          ),

                          if (error.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Text(error, style: const TextStyle(color: Colors.red)),
                            ),

                          const SizedBox(height: 20),

                          TextButton(
                            onPressed: () => widget.toggleView(),
                            child: const Text(
                              "Already have an account? Sign In",
                              style: TextStyle(fontSize: 15),
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
    );
  }
}
