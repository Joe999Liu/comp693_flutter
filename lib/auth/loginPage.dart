import 'package:flutter/material.dart';
import 'package:flutter_tiktok/auth/registrPage.dart';
import 'package:get/get.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

import '../pages/homePage.dart';
import '../widgets/inputTextWidget.dart';


class LoginPage extends StatefulWidget {

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  bool showProgressBar = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
              children: [
                const SizedBox(
                  height: 100,
                ),
                Image.asset(
                  "images/tiktok.png",
                  width: 200,
                ),
                Text(
                  "Welcome",
                ),
                Text("Glad to see you"),
                const SizedBox(
                  height: 30,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: InputTextWidget(
                    textEditingController: emailTextEditingController,
                    lableString: "Email",
                    iconData: Icons.email_outlined,
                    isObscure: false,
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: InputTextWidget(
                    textEditingController: passwordTextEditingController,
                    lableString: "Password",
                    iconData: Icons.lock_outline,
                    isObscure: true,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                showProgressBar == false ?
                Column(
                children: [

                //login button
                  Container(
                    width: MediaQuery.of(context).size.width - 38,
                    height: 54,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: InkWell(
                      onTap: ()
                        async {
                          setState(() {
                            showProgressBar = true;
                          });
                          await Future.delayed(Duration(seconds: 3));
                          Get.to(HomePage());
                      },
                    child: const Center(
                      child: Text(
                        "Login",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  //not have an account, signup now button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an Account? ",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      InkWell(
                        onTap: ()
                        {
                          //send user to signup screen
                          Get.to(RegistrPage());
                        },
                        child: const Text(
                          "SignUp Now",
                          style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                ) : Container(
                  //show animations
                  child: const SimpleCircularProgressBar(
                  progressColors: [
                  Colors.green,
                  Colors.blueAccent,
                  Colors.red,
                  Colors.amber,
                  Colors.purpleAccent,
                  ],
                  animationDuration: 3,
                  backColor: Colors.white38,
                  ),
                ),
              ],
            ),
        ),
      ),
    );
  }
}
