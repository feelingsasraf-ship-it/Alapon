import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const AlaponApp());
}

class AlaponApp extends StatelessWidget {
  const AlaponApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'আলাপন',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF0F4F8),
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}

// ==========================================
// ১. স্প্ল্যাশ স্ক্রিন (Splash Screen)
// ==========================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PhoneLoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2C59),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF1E63B8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.chat_bubble_rounded,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'আলাপন',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Connect Globally with Everyone',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF9BA4B5),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 50),
            const CircularProgressIndicator(
              color: Color(0xFF384959),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// ২. ফোন নাম্বার ইনপুট স্ক্রিন (Phone Login)
// ==========================================
class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  bool isLoading = false;

  void verifyPhoneNumber(BuildContext context) async {
    String phoneNumber = phoneController.text.trim();
    
    if (phoneNumber.length == 11 && phoneNumber.startsWith('01')) {
      phoneNumber = '+88$phoneNumber';
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('দয়া করে সঠিক ১১ ডিজিটের মোবাইল নাম্বার দিন')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ChatListScreen()),
            );
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ত্রুটি: ${e.message}')),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            isLoading = false;
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreen(
                verificationId: verificationId,
                phoneNumber: phoneNumber,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('অপ্রত্যাশিত সমস্যা: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'নম্বর দিয়ে প্রবেশ করুন',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F2C59),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'আপনার মোবাইল নাম্বারে একটি ভেরিফিকেশন কোড পাঠানো হবে।',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF526D82),
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: '01XXXXXXXXX',
                prefixIcon: const Icon(Icons.phone_iphone, color: Color(0xFF1E63B8)),
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E63B8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                onPressed: isLoading ? null : () => verifyPhoneNumber(context),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'কোড পাঠান',
                        style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// ৩. ওটিপি ভেরিফিকেশন স্ক্রিন (OTP Screen)
// ==========================================
class OtpScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  const OtpScreen({super.key, required this.verificationId, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool isLoading = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void verifyOTP() async {
    String smsCode = _controllers.map((e) => e.text).join();
    if (smsCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('সম্পূর্ণ ৬ ডিজিটের ওটিপি কোড লিখুন')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: smsCode,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ChatListScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ভুল ওটিপি কোড: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F2C59)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'ওটিপি যাচাইকরণ',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F2C59),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${widget.phoneNumber} নামبرটিতে ৬ ডিজিটের কোড পাঠানো হয়েছে',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Color(0xFF526D82)),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 48,
                  height: 56,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        _focusNodes[index + 1].requestFocus();
                      } else if (value.isEmpty && index > 0) {
                        _focusNodes[index - 1].requestFocus();
                      }
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E63B8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: isLoading ? null : verifyOTP,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'যাচাই করুন',
                        style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// ৪. চ্যাট লিস্ট স্ক্রিন (Chat List Screen)
// ==========================================
class ChatModel {
  final String name;
  final String message;
  final String time;
  final String profileImage;
  final int unreadCount;

  ChatModel({
    required this.name,
    required this.message,
    required this.time,
    required this.profileImage,
    required this.unreadCount,
  });
}

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  static final List<ChatModel> dummyChats = [
    ChatModel(
      name: 'রফিক আহমেদ',
      message: 'কেমন আছিস ভাই? প্রজেক্টের কি খবর?',
      time: '১০:৩০ AM',
      profileImage: 'https://i.pravatar.cc/150?img=11',
      unreadCount: 2,
    ),
    ChatModel(
      name: 'সাদিয়া ইসলাম',
      message: 'ফ্লাটার কোডটা একটু পাঠিয়ে দিও তো।',
      time: '৯:১৫ AM',
      profileImage: 'https://i.pravatar.cc/150?img=5',
      unreadCount: 0,
    ),
    ChatModel(
      name: 'তানভীর হাসান',
      message: 'কাল দেখা হচ্ছে তাহলে কনফার্ম।',
      time: 'গতকাল',
      profileImage: 'https://i.pravatar.cc/150?img=12',
      unreadCount: 1,
    ),
    ChatModel(
      name: 'ফাতেমা তুজ জোহরা',
      message: 'ধন্যবাদ ভাইয়া!',
      time: 'গতকাল',
      profileImage: 'https://i.pravatar.cc/150?img=9',
      unreadCount: 0,
    ),
    ChatModel(
      name: '+8801812345678',
      message: 'হ্যালো, কেমন আছেন?',
      time: '২ দিন আগে',
      profileImage: 'https://i.pravatar.cc/150?img=3',
      unreadCount: 0,
    ),
    ChatModel(
      name: 'কামরুল ইসলাম',
      message: 'মিটিংয়ে জয়েন করো দ্রুত।',
      time: '৩ দিন আগে',
      profileImage: 'https://i.pravatar.cc/150?img=15',
      unreadCount: 5,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F2C59),
        elevation: 0,
        title: const Text(
          'আলাপন চ্যাট',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const PhoneLoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: dummyChats.length,
        itemBuilder: (context, index) {
          final chat = dummyChats[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(chat.profileImage),
            ),
            title: Text(
              chat.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF0F2C59),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                chat.message,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF526D82), fontSize: 14),
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat.time,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 6),
                if (chat.unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E63B8),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${chat.unreadCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatDetailScreen(contactName: chat.name),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1E63B8),
        child: const Icon(Icons.chat, color: Colors.white),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('নতুন চ্যাট শুরু করার অপশন')),
          );
        },
      ),
    );
  }
}

// ==========================================
// ৫. চ্যাটিং কনভারসেশন স্ক্রিন (Chat Detail Screen)
// ==========================================
class ChatDetailScreen extends StatefulWidget {
  final String contactName;
  const ChatDetailScreen({super.key, required this.contactName});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<String> _messages = [
    'কেমন আছিস ভাই?',
    'আলহামদুলিল্লাহ ভালো, তুই কেমন আছিস?',
    'এই তো ভালো। প্রজেক্টের কাজ কতদূর?',
    'চলছে, আজকেই শেষ হয়ে যাবে আশা করি।'
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      _messages.add(_messageController.text.trim());
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F2C59),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
            ),
            const SizedBox(width: 10),
            Text(
              widget.contactName,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                bool isMe = index % 2 != 0;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFF1E63B8) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _messages[index],
                      style: TextStyle(
                        color: isMe ? Colors.white : const Color(0xFF0F2C59),
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add, color: Color(0xFF1E63B8)),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'একটি বার্তা লিখুন...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF1E63B8)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}