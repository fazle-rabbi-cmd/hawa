import 'package:flutter/material.dart';

class SplashScreenWidget extends StatelessWidget {
  const SplashScreenWidget({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // Background color
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset(
                  'assets/custom_logo.png', // Path to your custom logo image
                  width: 150, // Logo width
                  height: 150, // Logo height
                  color: Colors.white, // Logo color
                ),
              ),
              // App name
              Text(
                'Hawa',
                style: TextStyle(
                  color: Colors.white, // Text color
                  fontSize: 24, // Text size
                  fontWeight: FontWeight.bold, // Text weight
                ),
              ),
              SizedBox(height: 10),
              // Loading message
              Text(
                'Loading...',
                style: TextStyle(
                  color: Colors.white, // Text color
                  fontSize: 16, // Text size
                ),
              ),
              SizedBox(height: 20),
              // Progress indicator
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white), // Indicator color
              ),
            ],
          ),
        ),
      ),
    );
  }
}
