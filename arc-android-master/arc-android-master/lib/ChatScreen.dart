import 'dart:async';
import 'package:arc/model/faq_response.dart';
import 'package:arc/provider/notification_provider.dart';
import 'package:arc/provider/news_letter_provider.dart';
import 'package:arc/utils/colors.dart';
import 'package:arc/utils/preference_helper.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:arc/configuration/config_provider.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = '/chat';
  final FaqModel? faqModel;
  const ChatScreen({super.key, required this.faqModel});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final DatabaseReference _baseRef = FirebaseDatabase.instance.ref(ConfigProvider.config.firebaseChatDB);
  final uuid = Uuid();
  NotificationProvider? provider;


  List<ChatMessage> _messages = [];
  List<ChatMessage> _faqMessages = []; // Store FAQ messages separately
  String? _faqStartID;
  StreamSubscription<DatabaseEvent>? _messagesSubscription;
  String? _userId;
  String? _userName;
  bool _isLoading = true;
  bool _hasUserInput = false; // Track if user has input anything
  bool _faqLoaded = false;
  NewsLetterProvider? _newsLetterProvider;

  @override
  void initState() {
    super.initState();
    provider = Provider.of<NotificationProvider>(context, listen: false);
    _newsLetterProvider = Provider.of<NewsLetterProvider>(context, listen: false);

    // If faqModel is provided, handle it first
    // if (widget.faqModel != null) {
    //   _handleFaqModel();
    // } else {
      _loadUserData();
    // }
  }

  void _handleFaqModel() async {
    if (widget.faqModel == null) { return; }

    final faqModel = widget.faqModel!;
    final userData = await PreferenceHelper.getUserProfile();
    setState(() {
      _userId = userData.id;
      _userName = userData.fullName ?? 'User';
      _isLoading = false;
    });

    // Add the question as a user message
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final questionMessage = ChatMessage(
      id: "${timestamp}_question",
      initiate: 'patient',
      senderId: _userId ?? '',
      senderName: _userName ?? 'User',
      text: faqModel.question,
      timestamp: timestamp,
    );

    _faqStartID = _messages.last.id;
    setState(() {
      _faqMessages.add(questionMessage);
      _messages = List.from(_faqMessages); // Initialize with FAQ messages
    });

    // Handle based on type
    if (faqModel.type == 'STATIC') {
      _handleStaticFaq(faqModel);
    } else if (faqModel.type == 'DYNAMIC') {
      _handleDynamicFaq(faqModel);
    } else if (faqModel.type == 'CONDITIONAL') {
      _handleConditionalFaq(faqModel);
    }

    _scrollToBottom();
  }

  void _handleStaticFaq(FaqModel faqModel) {
    // For STATIC, show points as answer
    final answerText = faqModel.points.isEmpty 
        ? 'No answer available.' 
        : faqModel.points.join('\n\n');
    
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final answerMessage = ChatMessage(
      id: "${timestamp}_answer",
      initiate: 'arc',
      senderId: 'arc',
      senderName: 'ARC Support',
      text: answerText,
      timestamp: timestamp,
    );

    setState(() {
      _faqMessages.add(answerMessage);
      _messages = _mergeMessages(_faqMessages, _messages);
    });
  }

  void _handleDynamicFaq(FaqModel faqModel) async {
    // For DYNAMIC, call API with qid
    if (faqModel.qid.isEmpty) {
      final errorMessage = ChatMessage(
        id: "${DateTime.now().millisecondsSinceEpoch}_error",
        initiate: 'arc',
        senderId: 'arc',
        senderName: 'ARC Support',
        text: 'Error: Question ID not found.',
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      setState(() {
        _faqMessages.add(errorMessage);
        _messages = _mergeMessages(_faqMessages, _messages);
      });
      return;
    }

    // Show typing indicator
    final typingMessageId = "${DateTime.now().millisecondsSinceEpoch}_typing";
    final typingMessage = ChatMessage(
      id: typingMessageId,
      initiate: 'arc',
      senderId: 'arc',
      senderName: 'ARC Support',
      text: '',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      isTyping: true,
    );
    setState(() {
      _faqMessages.add(typingMessage);
      _messages = _mergeMessages(_faqMessages, _messages);
    });
    _scrollToBottom();

    // Call API
    try {
      await _newsLetterProvider?.getFaqAnswerOfQuestions(faqModel.qid, context);
      
      if (kDebugMode) {
        print("ChatScreen: API call completed. Answer: ${_newsLetterProvider?.answer}");
        print("ChatScreen: isAnswerLoading: ${_newsLetterProvider?.isAnswerLoading}");
      }
      
      // Remove typing indicator and add answer
      setState(() {
        // Find and remove the typing message from both lists
        _faqMessages.removeWhere((msg) => msg.id == typingMessageId || msg.isTyping);
        _messages.removeWhere((msg) => msg.id == typingMessageId || msg.isTyping);
        
        // Get answer from response - use answer key
        final answer = _newsLetterProvider?.answer;
        
        if (kDebugMode) {
          print("ChatScreen: Retrieved answer: $answer");
        }
        
        final answerText = answer != null && answer.isNotEmpty 
            ? answer 
            : 'No answer available.';
        
        final answerMessage = ChatMessage(
          id: "${DateTime.now().millisecondsSinceEpoch}_answer",
          initiate: 'arc',
          senderId: 'arc',
          senderName: 'ARC Support',
          text: answerText,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          isTyping: false,
        );
        _faqMessages.add(answerMessage);
        _messages = _mergeMessages(_faqMessages, _messages);
      });
      
      _scrollToBottom();
    } catch (e) {
      if (kDebugMode) {
        print("ChatScreen: Error fetching FAQ answer: $e");
      }
      
      // Remove typing indicator and show error
      setState(() {
        // Find and remove the typing message from both lists
        _faqMessages.removeWhere((msg) => msg.id == typingMessageId || msg.isTyping);
        _messages.removeWhere((msg) => msg.id == typingMessageId || msg.isTyping);
        
        final errorMessage = ChatMessage(
          id: "${DateTime.now().millisecondsSinceEpoch}_error",
          initiate: 'arc',
          senderId: 'arc',
          senderName: 'ARC Support',
          text: 'Failed to load answer. Please try again.',
          timestamp: DateTime.now().millisecondsSinceEpoch,
          isTyping: false,
        );
        _faqMessages.add(errorMessage);
        _messages = _mergeMessages(_faqMessages, _messages);
      });
      
      _scrollToBottom();
    }
  }

  void _handleConditionalFaq(FaqModel faqModel) {
    // For CONDITIONAL, show options from conditionalPoint
    if (faqModel.conditionalPoint.isEmpty) {
      final errorMessage = ChatMessage(
        id: "${DateTime.now().millisecondsSinceEpoch}_error",
        initiate: 'arc',
        senderId: 'arc',
        senderName: 'ARC Support',
        text: 'No options available.',
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      setState(() {
        _messages.add(errorMessage);
      });
      return;
    }

    // Create options message with clickable options
    final options = faqModel.conditionalPoint.keys.toList();
    final optionsText = 'Please select an option:\n\n' + 
        options.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n');
    
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final optionsMessage = ChatMessage(
      id: "${timestamp}_options",
      initiate: 'arc',
      senderId: 'arc',
      senderName: 'ARC Support',
      text: optionsText,
      timestamp: timestamp,
    );

    setState(() {
      _faqMessages.add(optionsMessage);
      _messages = _mergeMessages(_faqMessages, _messages);
    });
  }

  void _handleConditionalSelection(String selectedOption, FaqModel faqModel) {
    // Add user's selection as a message first
    final userTimestamp = DateTime.now().millisecondsSinceEpoch;
    final userMessage = ChatMessage(
      id: "${userTimestamp}_${uuid.v4()}",
      initiate: 'patient',
      senderId: _userId ?? '',
      senderName: _userName ?? 'User',
      text: selectedOption,
      timestamp: userTimestamp,
    );

    setState(() {
      _faqMessages.add(userMessage);
      _messages = _mergeMessages(_faqMessages, _messages);
    });

    // When user selects an option, show the corresponding answer
    final answers = faqModel.conditionalPoint[selectedOption];
    if (answers == null || answers.isEmpty) {
      final errorMessage = ChatMessage(
        id: "${DateTime.now().millisecondsSinceEpoch}_error",
        initiate: 'arc',
        senderId: 'arc',
        senderName: 'ARC Support',
        text: 'No answer available for this option.',
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      setState(() {
        _faqMessages.add(errorMessage);
        _messages = _mergeMessages(_faqMessages, _messages);
      });
      _scrollToBottom();
      return;
    }

    final answerText = answers.join('\n\n');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final answerMessage = ChatMessage(
      id: "${timestamp}_answer",
      initiate: 'arc',
      senderId: 'arc',
      senderName: 'ARC Support',
      text: answerText,
      timestamp: timestamp,
    );

    setState(() {
      _faqMessages.add(answerMessage);
      _messages = _mergeMessages(_faqMessages, _messages);
    });
    _scrollToBottom();
    
    // Mark that user has input something and setup Firebase listener
    if (!_hasUserInput) {
      setState(() {
        _hasUserInput = true;
      });
      _setupMessagesListener();
    }
  }

  // Merge FAQ messages with Firebase messages, preserving order
  List<ChatMessage> _mergeMessages(List<ChatMessage> faqMessages, List<ChatMessage> firebaseMessages) {
    // Create a combined list
    final combined = <ChatMessage>[];
    
    // Add FAQ messages first (they should appear first), but exclude typing indicators
    combined.addAll(faqMessages.where((msg) => !msg.isTyping));
    
    // Add Firebase messages that don't already exist in FAQ messages
    // Filter out any Firebase messages that might duplicate FAQ messages
    final faqIds = faqMessages.map((m) => m.id).toSet();
    for (var firebaseMsg in firebaseMessages) {
      // Only add Firebase messages that aren't FAQ messages and aren't typing indicators
      // FAQ messages have IDs like "timestamp_question", "timestamp_answer", etc.
      // Firebase messages have IDs like "timestamp_uuid"
      if (!faqIds.contains(firebaseMsg.id) && !firebaseMsg.isTyping) {
        combined.add(firebaseMsg);
      }
    }
    
    // Sort by timestamp to maintain chronological order
    combined.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    return combined;
  }

  Future<void> _loadUserData() async {
    final userData = await PreferenceHelper.getUserProfile();
    setState(() {
      _userId = userData.id;
      _userName = userData.fullName ?? 'User';
      
      if (kDebugMode) {
        print("ChatScreen: UserId: $_userId");
      }
    });
    _setupMessagesListener();
  }

  void _setupMessagesListener() {
    if (_userId == null) return;

    // Listen to messages in real-time
    // Path: chat_dev/{userId}
    final messagesRef = _baseRef.child(_userId!);
    
    _messagesSubscription = messagesRef.onValue.listen((DatabaseEvent event) {
      if (kDebugMode) {
        print("ChatScreen: Received data from Firebase");
        print("ChatScreen: Snapshot value: ${event.snapshot.value}");
      }
      
      if (event.snapshot.value != null) {
        final dynamic snapshotValue = event.snapshot.value;
        
        // Handle both Map and other types
        if (snapshotValue is Map) {
          final Map<dynamic, dynamic> data = 
              Map<dynamic, dynamic>.from(snapshotValue);
          
          final List<ChatMessage> messages = [];
          // Use entries to preserve insertion order from database
          final entries = data.entries.toList();
          
          for (var entry in entries) {
            final key = entry.key;
            final value = entry.value;
            try {
              // Skip if value is not a Map (could be other data structures)
              if (value is! Map) {
                if (kDebugMode) {
                  print("ChatScreen: Skipping non-map value for key: $key, type: ${value.runtimeType}");
                }
                continue;
              }
              
              final messageData = Map<String, dynamic>.from(value);
              
              // Validate that this looks like a message (has required fields)
              if (messageData.containsKey('text') || 
                  messageData.containsKey('senderId') ||
                  messageData.containsKey('timestamp')) {
                final message = ChatMessage.fromMap(key.toString(), messageData);
                messages.add(message);
                
                if (kDebugMode) {
                  print("ChatScreen: Parsed message - key: $key, timestamp: ${message.timestamp}, initiate: ${messageData['initiate']}, text: ${messageData['text']}");
                }
              } else {
                if (kDebugMode) {
                  print("ChatScreen: Skipping invalid message structure for key: $key");
                }
              }
            } catch (e) {
              if (kDebugMode) {
                print("ChatScreen: Error parsing message with key $key: $e");
                print("ChatScreen: Value was: $value");
              }
            }
          }

          // Sort by message ID (key) to preserve database insertion order
          // Message IDs are created as "${timestamp}_${uuid}" which maintains insertion order
          messages.sort((a, b) {
            return a.id.compareTo(b.id);
          });

          if (kDebugMode) {
            print("ChatScreen: Total messages loaded: ${messages.length}");
            if (messages.isNotEmpty) {
              print("ChatScreen: First message (oldest) - timestamp: ${messages.first.timestamp}, text: ${messages.first.text.substring(0, messages.first.text.length > 20 ? 20 : messages.first.text.length)}");
              print("ChatScreen: Last message (newest) - timestamp: ${messages.last.timestamp}, text: ${messages.last.text.substring(0, messages.last.text.length > 20 ? 20 : messages.last.text.length)}");
            }
          }

          setState(() {
            // Merge FAQ messages with Firebase messages instead of replacing
            _messages = List.from(messages);
            if (_faqMessages.isNotEmpty) {
              int index = -1;
              if (_faqStartID != null) {
                index = _messages.indexWhere((msg) => msg.id == _faqStartID);
              }
              _messages.insertAll(index + 1, _faqMessages);
            }
            _isLoading = false;
          });

          _scrollToBottom();
        } else {
          if (kDebugMode) {
            print("ChatScreen: Snapshot value is not a Map, type: ${snapshotValue.runtimeType}");
          }
          setState(() {
            // Keep FAQ messages even if Firebase is empty
            _messages = List.from(_faqMessages);
            _isLoading = false;
          });
        }
      } else {
        if (kDebugMode) {
          print("ChatScreen: No data found at chat_dev/$_userId");
        }
        setState(() {
          // Keep FAQ messages even if Firebase has no data
          _messages = List.from(_faqMessages);
          _isLoading = false;
        });
      }
      if (!_faqLoaded) {
        _handleFaqModel();
        _faqLoaded = true;
      }
    });
    
    if (kDebugMode) {
      print("ChatScreen: Listening to messages at chat_dev/$_userId");
    }
  }

  /// Scrolls to the bottom reliably, retrying briefly to account for late layout changes
  Future<void> _scrollToBottom({bool animated = true}) async {
    try {
      // Wait a frame to allow list layout to update
      await Future.delayed(const Duration(milliseconds: 50));

      if (!_scrollController.hasClients) {
        // Give one more short chance for the controller to attach
        await Future.delayed(const Duration(milliseconds: 50));
        if (!_scrollController.hasClients) return;
      }

      // Attempt to move to the bottom
      double maxScroll = _scrollController.position.maxScrollExtent;

      if (animated) {
        await _scrollController.animateTo(
          maxScroll,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(maxScroll);
      }

      // Retry a few times in case subsequent frames push the content further
      for (int i = 0; i < 3; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (!_scrollController.hasClients) break;
        final newMax = _scrollController.position.maxScrollExtent;
        final distance = newMax - _scrollController.offset;
        if (distance > 2) {
          if (animated) {
            await _scrollController.animateTo(
              newMax,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          } else {
            _scrollController.jumpTo(newMax);
          }
        } else {
          break;
        }
      }
    } catch (e) {
      if (kDebugMode) print('ChatScreen: _scrollToBottom failed: $e');
    }
  }

  Future<void> _sendMessage() async {
    final messageText = _controller.text.trim();
    if (messageText.isEmpty || _userId == null || _userName == null) return;

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final messageId = "${timestamp}_${uuid.v4()}";

    final messageData = {
      'initiate': 'patient', // Hardcoded as "patient" for messages sent from our app
      'senderId': _userId,
      'senderName': _userName,
      'text': messageText,
      'timestamp': timestamp,
    };

    try {
      // Push message to Firebase Realtime Database
      // Path: chat_dev/{userId}/{messageId}
      final messagesRef = _baseRef.child(_userId!).child(messageId);
      await messagesRef.set(messageData);
      _controller.clear();

      Map<String, String> body = {
        "patientId": _userId ?? "",
      };
      provider?.sendNotification(body, context);
      if (kDebugMode) {
        print("Message sent successfully to chat_dev/$_userId");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error sending message: $e");
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("ARC Chat", style: TextStyle(color: Colors.white),),
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
      body: SafeArea(child: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start the conversation!',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                // Current user if initiate is "patient" (sent from our app)
                final isCurrentUser = message.initiate == 'patient';

                return ChatBubble(
                  message: message,
                  isCurrentUser: isCurrentUser,
                  faqModel: widget.faqModel,
                  onOptionSelected: widget.faqModel != null && widget.faqModel!.type == 'CONDITIONAL'
                      ? (option) => _handleConditionalSelection(option, widget.faqModel!)
                      : null,
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      )),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: "Type your message...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  isDense: true,
                ),
                maxLines: 3,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: themeColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String id;
  final String initiate; // "patient" or "arc"
  final String senderId;
  final String senderName;
  final String text;
  final int timestamp;
  final bool isTyping; // Indicates if this is a typing indicator

  ChatMessage({
    required this.id,
    required this.initiate,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.isTyping = false,
  });

  factory ChatMessage.fromMap(String id, Map<String, dynamic> map) {
    // Handle timestamp as int or string
    int timestamp;
    if (map['timestamp'] is int) {
      timestamp = map['timestamp'] as int;
    } else if (map['timestamp'] is String) {
      timestamp = int.tryParse(map['timestamp'] as String) ?? DateTime.now().millisecondsSinceEpoch;
    } else {
      timestamp = DateTime.now().millisecondsSinceEpoch;
    }
    
    return ChatMessage(
      id: id,
      initiate: map['initiate']?.toString() ?? 'patient',
      senderId: map['senderId']?.toString() ?? '',
      senderName: map['senderName']?.toString() ?? 'Unknown',
      text: map['text']?.toString() ?? '',
      timestamp: timestamp,
      isTyping: map['isTyping'] == true,
    );
  }

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timestamp);
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isCurrentUser;
  final FaqModel? faqModel;
  final Function(String)? onOptionSelected;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    this.faqModel,
    this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isCurrentUser)
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 8),
                child: Text(
                  message.senderName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isCurrentUser ? themeColor : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isCurrentUser ? 16 : 4),
                  bottomRight: Radius.circular(isCurrentUser ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Check if this is a typing indicator
                  if (message.isTyping)
                    _buildTypingIndicator()
                  // Check if this is an options message for conditional FAQ
                  else if (!isCurrentUser && 
                      faqModel != null && 
                      faqModel!.type == 'CONDITIONAL' && 
                      message.text.contains('Please select an option') &&
                      onOptionSelected != null)
                    _buildConditionalOptions()
                  else
                    Text(
                      message.text,
                      style: TextStyle(
                        color: isCurrentUser ? Colors.white : Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                  // Hide timestamp for typing indicator
                  if (!message.isTyping) ...[
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('HH:mm').format(message.dateTime),
                      style: TextStyle(
                        color: isCurrentUser
                            ? Colors.white70
                            : Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionalOptions() {
    if (faqModel == null || faqModel!.conditionalPoint.isEmpty) {
      return Text(
        message.text,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 15,
        ),
      );
    }

    final options = faqModel!.conditionalPoint.keys.toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Please select an option:',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...options.map((option) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => onOptionSelected?.call(option),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: themeColor, width: 1.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      option,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: themeColor),
                ],
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return _TypingIndicator();
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );
    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }).toList();

    // Start animations with staggered delays
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Opacity(
                opacity: _animations[index].value,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
