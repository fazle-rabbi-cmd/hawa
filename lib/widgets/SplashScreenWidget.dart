import 'package:flutter/material.dart';

class SplashScreenWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // Customize the background color
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FlutterLogo(
                size: 100, // Adjust the size of the logo
                textColor: Colors.white, // Customize the color of the logo
              ),
              SizedBox(height: 20),
              Text(
                'Your App Name',
                style: TextStyle(
                  color: Colors.white, // Customize the color of the text
                  fontSize: 24, // Adjust the font size
                  fontWeight: FontWeight.bold, // Adjust the font weight
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Loading...',
                style: TextStyle(
                  color: Colors.white, // Customize the color of the text
                  fontSize: 16, // Adjust the font size
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
