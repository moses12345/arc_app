import 'dart:convert';

import 'package:arc/ChatScreen.dart';
import 'package:arc/network/api.dart';
import 'package:arc/provider/news_letter_provider.dart';
import 'package:arc/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/faq_response.dart';

class FAQQuestionScreen extends StatefulWidget {
  final FaqQuestion? faq;
  const FAQQuestionScreen({super.key, required this.faq});

  @override
  State<FAQQuestionScreen> createState() => _FAQQuestionScreenState();
}

class _FAQQuestionScreenState extends State<FAQQuestionScreen> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Text("${widget.faq?.name}", style: const TextStyle(color: black, fontWeight: FontWeight.w600, fontSize: 18,),),
                  const SizedBox(height: 5),
                  const Text(
                    "Select a question or type your own below",
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
    );
  }

  Widget _buildFaqList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.faq?.questions?.length,
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
          child: _buildFaqItem(widget.faq!.questions![index], index),
        );
      },
    );
  }

  Widget _buildFaqItem(FaqModel faqModel, int index) {
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
        //contentPadding: const EdgeInsets.all(5),
        title: Text(faqModel.question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(
                settings: const RouteSettings(name: ChatScreen.routeName),
                builder: (context) => ChatScreen(faqModel: faqModel),
              )
          );
        },
      ),
    );
  }
}