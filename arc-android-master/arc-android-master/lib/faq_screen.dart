import 'dart:convert';

import 'package:arc/ChatScreen.dart';
import 'package:arc/faq_question_screen.dart';
import 'package:arc/network/api.dart';
import 'package:arc/provider/news_letter_provider.dart';
import 'package:arc/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/faq_response.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> with TickerProviderStateMixin {
  NewsLetterProvider? provider;
  List<FaqQuestion> faqList = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    provider = Provider.of<NewsLetterProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (provider!.faqDataList.isEmpty) {
        provider!.getFaqQuestions(context);
      }
    });
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final mProvider = Provider.of<NewsLetterProvider>(context);
    faqList = mProvider.faqDataList;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Customer Support", style: TextStyle(color: Colors.white),),
        backgroundColor: themeColor,
        leading: IconButton(
          icon: RotationTransition(
            turns: const AlwaysStoppedAnimation(180 / 360),
            child: Image.asset(
              'assets/right_arrow.png',
              fit: BoxFit.cover,
              color: Colors.white,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: mProvider.isFaqLoading ? SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(themeColor),
          ),
        ),
      ) : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    "How can we help?",
                    style: TextStyle(color: black, fontWeight: FontWeight.w600, fontSize: 18,),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Select a topic to see common questions",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 5),
                  _buildFaqList(),
                ],
              ),
            ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(
                  settings: const RouteSettings(name: ChatScreen.routeName),
                  builder: (context) => const ChatScreen(faqModel: null,),
                )
            );
          },
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.chat_bubble_outline, color: themeColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Didn't find answer? Chat with us",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade700,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: themeColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFaqList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: faqList.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: _buildFaqItem(faqList[index], index),
        );
      },
    );
  }

  Widget _buildFaqItem(FaqQuestion faq, int index) {
    return Container(
      margin: const EdgeInsets.only(top: 10, left: 12, right: 12),
      //margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB), // stroke color (light grey)
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE7F6F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(getIcon(index), color: const Color(0xFF4FB6B2)),
        ),
        title: Text("${faq.name}",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
       /* subtitle: const Text(
          "Anurag",
          style: TextStyle(fontSize: 13),
        ),*/
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => FAQQuestionScreen(faq: faq)));
        },
      ),
    );
  }

  IconData getIcon(int position) {
    if(position == 0) {
      return Icons.info_outline;
    } else if(position == 1) {
      return Icons.app_registration_outlined;
    } else if(position == 2) {
      return Icons.payment;
    } else if(position == 3) {
      return Icons.medical_services_outlined;
    } else if(position == 4) {
      return Icons.health_and_safety_outlined;
    } else if(position == 5) {
      return Icons.safety_check;
    } else if(position == 6) {
      return Icons.home_outlined;
    } else if(position == 7) {
      return Icons.mark_chat_unread_outlined;
    }
    return Icons.info_outline;
  }
}