import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:twitter/firebase_options.dart';
import 'package:twitter/services/auth/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: FutureBuilder(
        // Check if Firebase is initialized
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          // If Firebase initialization is not complete, show loading spinner
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // or any loading widget
          }
          // If Firebase initialization is complete, build the app
          return MyApp();
        },
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: LoginPage(),
      routes: {
        '/all_tweets': (context) => AllTweetsPage(), // New route for All Tweets
        '/profile': (context) => ProfilePage(), // Route to the profile page
        '/edit_profile': (context) =>
            ChangePasswordPage(), // Route to the password page
      },
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/Xicon.png', // Replace with your logo image path
              height: 100,
              width: 100,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () async {
                // Retrieve email and password from controllers
                final email = _emailController.text;
                final password = _passwordController.text;

                //get auth service
                final authService =
                    Provider.of<AuthService>(context, listen: false);
                try {
                  await authService.signInWithEmailandPassword(email, password);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        e.toString(),
                      ),
                    ),
                  );
                }
              },
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Don\'t have an account?'),
                const SizedBox(width: 5),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignupPage()),
                    );
                  },
                  child: const Text('Sign Up'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text('Or sign in with'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 10),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.facebook),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // User is not authenticated, handle this case
      return Scaffold(
        appBar: AppBar(
          title: Text('Profile Page'),
        ),
        body: Center(
          child: Text('User not authenticated. Please log in.'),
        ),
      );
    }

    String uid = user.uid;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Profile Page'),
            const Spacer(), // Add a spacer to push the logout button to the right
            IconButton(
              icon: Icon(Icons.logout), // Add the logout icon button
              onPressed: () {
                final authService =
                    Provider.of<AuthService>(context, listen: false);
                authService.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text('Shravani'), // Replace with actual username
              accountEmail: null,
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(
                  'https://resize.indiatvnews.com/en/resize/newbucket/1080_-/2023/06/untitled-design-2023-06-20t120715-1687246152.jpg',
                ),
              ),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 52, 52, 52),
              ),
            ),
            ListTile(
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Edit Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                    context, '/edit_profile'); // Navigate to password page
              },
            ),
            ListTile(
              // New navigation item for All Tweets
              title: const Text('All Tweets'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/all_tweets');
              },
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header image
          Container(
            height: 170,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://images.shiksha.com/mediadata/images/1553752427phpvP6G9K.png',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: const Stack(
              children: [
                // Profile picture overlapping header image
                Positioned(
                  top: 100,
                  left: 20,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      'https://resize.indiatvnews.com/en/resize/newbucket/1080_-/2023/06/untitled-design-2023-06-20t120715-1687246152.jpg',
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bio container
          Container(
            padding: const EdgeInsets.all(20),
            height: 180,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.account_circle),
                    SizedBox(width: 10),
                    Text(
                      'Username',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.info),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'My flutter project',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.location_on),
                    SizedBox(width: 10),
                    Text(
                      'Chembur',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(FontAwesomeIcons.birthdayCake),
                    SizedBox(width: 10),
                    Text(
                      'Born 1 Aug 2003',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(width: 20), // Adjust the width as needed
                    Icon(FontAwesomeIcons.calendarAlt),
                    SizedBox(width: 7),
                    Text(
                      'Joined 1 Feb 2024',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Tweets
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('tweets')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No tweets found.'));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var tweetData = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;
                    return Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                        ),
                        borderRadius: BorderRadius.circular(
                            10), // Optional: for rounded corners
                      ),
                      child: Card(
                        elevation: 3,
                        child: Container(
                          height:
                              120, // Adjust the height as per your preference
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tweetData['text'],
                                style: TextStyle(fontSize: 16),
                              ),
                              Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.thumb_up),
                                    onPressed: () {
                                      // Handle like button press
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.thumb_down),
                                    onPressed: () {
                                      // Handle dislike button press
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ComposeTweetPage()));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

// class PasswordPage extends StatelessWidget {
//   const PasswordPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Password Page'),
//       ),
//       body: Center(
//         child: Text('Password Page'),
//       ),
//     );
//   }
// }

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                    return 'Password must contain at least one symbol';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                ),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    String newPassword = _passwordController.text;
                    try {
                      await AuthService().changePassword(newPassword);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Password changed successfully. Please sign in again.'),
                        ),
                      );
                      // You may choose to navigate the user to the sign-in page or any other page after password change
                    } catch (e) {
                      // Handle any errors that occur during password change
                      print('Error changing password: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Failed to change password. Please try again later.'),
                        ),
                      );
                    }
                  }
                },
                child: Text('Change Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

// ignore: must_be_immutable
class SignupPage extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _confirmpasswordController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Email is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Password is required';
                  }
                  // Add more email validation if needed
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _confirmpasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'confirm Password is required';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  // Add more password validation if needed
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  //signup logic
                  if (_passwordController.text !=
                      _confirmpasswordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Passwords do not match!"),
                      ),
                    );
                    return;
                  }

                  final authService =
                      Provider.of<AuthService>(context, listen: false);

                  try {
                    await authService.signUpWithEmailandPassword(
                      _emailController.text,
                      _passwordController.text,
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//All tweets page
class AllTweetsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Tweets'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collectionGroup('tweets').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Extract tweet data from snapshot
          List<QueryDocumentSnapshot> tweetDocs = snapshot.data!.docs;

          if (tweetDocs.isEmpty) {
            return Center(child: Text('No tweets found.'));
          }

          return ListView.builder(
            itemCount: tweetDocs.length,
            itemBuilder: (context, index) {
              var tweetData = tweetDocs[index].data() as Map<String, dynamic>;

              // Print each tweet's data for debugging
              print('Tweet $index: $tweetData');

              return TweetCard(
                tweetData: tweetData,
              );
            },
          );
        },
      ),
    );
  }
}

class TweetCard extends StatefulWidget {
  final Map<String, dynamic> tweetData;

  const TweetCard({Key? key, required this.tweetData}) : super(key: key);

  @override
  _TweetCardState createState() => _TweetCardState();
}

class _TweetCardState extends State<TweetCard> {
  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      elevation: 3,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.tweetData['text'],
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.favorite,
                    color: isLiked ? Colors.red : null,
                  ),
                  onPressed: () {
                    setState(() {
                      isLiked = !isLiked;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ComposeTweetPage extends StatefulWidget {
  @override
  _ComposeTweetPageState createState() => _ComposeTweetPageState();
}

class _ComposeTweetPageState extends State<ComposeTweetPage> {
  final TextEditingController _tweetController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compose Tweet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _tweetController,
                  maxLines: null, // Allow multiple lines for the tweet
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'What\'s on your mind?',
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String tweetText = _tweetController.text;
                // String tweetText = _tweetController.text;
                saveTweet(tweetText);
                Navigator.pop(context); // Close the compose tweet screen
              },
              child: Text('Tweet'),
            ),
          ],
        ),
      ),
    );
  }
}
