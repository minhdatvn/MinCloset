// lib/screens/faq_page.dart
import 'package:flutter/material.dart';
import 'package:mincloset/widgets/page_scaffold.dart';
import 'package:mincloset/widgets/section_header.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      appBar: AppBar(
        title: const Text("FAQ"), // Tiêu đề trang
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          SectionHeader(title: "Frequently Asked Questions"),
          SizedBox(height: 8),
          _FaqItem(
            question: "How does AI suggestion work?",
            answer: "The app sends anonymized information about your closet items and local weather to a powerful AI (Google's Gemini) to generate a personalized and reasoned outfit suggestion.",
          ),
          _FaqItem(
            question: "Is my data private?",
            answer: "Yes. All your data, including photos, is stored locally on your device. If you choose to back up, your data is stored securely in your own private cloud space on Firebase, protected by Google's security standards.",
          ),
          _FaqItem(
            question: "Why do I need to log in for backup?",
            answer: "Logging in creates a secure link between you and your data on the cloud. This ensures that only you can access, back up, or restore your closet information.",
          ),
        ],
      ),
    );
  }
}

// Widget helper cho các câu hỏi FAQ (sao chép từ guides_page cũ)
class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer),
          ),
        ],
      ),
    );
  }
}