import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/providers/authentication_provider.dart';
import 'package:flutter_chat_app/utilities/assets_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();

  Country selectedCountry = Country(
      phoneCode: '26',
      countryCode: 'ZM',
      e164Sc: 0,
      geographic: true,
      level: 1,
      name: 'Zambia',
      example: 'Zambia',
      displayName: 'Zambia',
      displayNameNoCountryCode: 'ZM',
      e164Key: '');

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();
    return Scaffold(
        body: Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 50),
            SizedBox(
              height: 200,
              width: 200,
              child: Lottie.asset(AssetsManager.chatBubble),
            ),
            Text(
              'Pop Peep Chat',
              style: GoogleFonts.openSans(
                  fontSize: 35, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 20),
            Text('Add your phone number will send you an OTP to verify',
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(fontSize: 16)),
            const SizedBox(height: 20),
            TextFormField(
              controller: _phoneNumberController,
              maxLength: 10,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              onChanged: (value) {
                setState(() {
                  _phoneNumberController.text = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Phone Number',
                hintStyle: GoogleFonts.openSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                prefixIcon: Container(
                  padding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 12.0),
                  child: InkWell(
                    onTap: () {
                      showCountryPicker(
                        context: context,
                        showPhoneCode: true,
                        onSelect: (Country country) {
                          setState(() {
                            selectedCountry = country;
                          });
                        },
                      );
                    },
                    child: Text(
                      '${selectedCountry.flagEmoji} +${selectedCountry.phoneCode}',
                      style: GoogleFonts.openSans(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                suffixIcon: _phoneNumberController.text.length > 9
                    ? authProvider.isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          )
                        : InkWell(
                            onTap: () {
                              //sign in with phone number
                              authProvider.signInWithPhoneNumber(
                                  phoneNumber:
                                      '+${selectedCountry.phoneCode}${_phoneNumberController.text}',
                                  context: context);
                            },
                            child: Container(
                              height: 35,
                              width: 35,
                              margin: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                  color: Colors.green, shape: BoxShape.circle),
                              child: const Icon(Icons.done,
                                  color: Colors.white, size: 25),
                            ),
                          )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
