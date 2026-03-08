import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';

class AiChatScreen extends StatelessWidget {
  const AiChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FluentIcons.chevron_left_24_regular, color: AppTheme.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'AI ASSISTANT',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(8),
             decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.textLight.withOpacity(0.2)),
            ),
            child: const Icon(FluentIcons.delete_24_regular, size: 20, color: AppTheme.textDark),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '👋 HI JOHN,',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'How can I help you today?',
                      style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight),
                    ),
                    const SizedBox(height: 32),
                    
                    // Suggested Prompts
                    Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildPromptBubble('Track my order', false),
                          const SizedBox(height: 16),
                          _buildPromptBubble('Show me trending products', false),
                          const SizedBox(height: 16),
                          _buildPromptBubble('How much do your services cost?', false),
                          const SizedBox(height: 16),
                          _buildPromptBubble('Recommend products based on my style', true),
                          const SizedBox(height: 16),
                          _buildPromptBubble('What types of ceilings do you install?', false), // The design actually has this random construction query, we copy it 1:1
                          const SizedBox(height: 16),
                          _buildPromptBubble('Show top-rated items in electronics', false), // Another random query from mockup
                          const SizedBox(height: 16),
                          _buildPromptBubble('Do you offer any discounts?', false),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom Input
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              color: AppTheme.backgroundLight,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(FluentIcons.mic_24_regular, color: AppTheme.textLight),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Chat with Chatbot',
                          hintStyle: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppTheme.textDark,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(FluentIcons.send_24_filled, color: Colors.white, size: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptBubble(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryLime : Colors.white,
        borderRadius: BorderRadius.circular(100),
        border: isSelected ? null : Border.all(color: AppTheme.textLight.withOpacity(0.1)),
        boxShadow: isSelected ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.textDark : AppTheme.textLight.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppTheme.textDark : AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
