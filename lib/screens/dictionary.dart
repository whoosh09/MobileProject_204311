import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/mock_data.dart';
import '../theme/theme_data.dart';
import '../services/audio_helper.dart'; // 🆕 นำเข้าเสียงเผื่อกดเล่น

class DictionaryPage extends StatefulWidget {
  final User currentUser;

  const DictionaryPage({super.key, required this.currentUser});

  @override
  State<DictionaryPage> createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  Map<String, String> _dictionary = {};
  bool _isLoading = true;
  int _totalWords = 0; // 🆕 เก็บจำนวนคำศัพท์ทั้งหมดในเกม

  // 🆕 ระบบค้นหาคำศัพท์
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadDictionary();
  }

  Future<void> _loadDictionary() async {
    try {
      final String content = await rootBundle.loadString('assets/targetwords.json');
      final Map<String, dynamic> jsonData = json.decode(content);
      final Map<String, String> dictionaryData = {};

      jsonData.forEach((key, value) {
        if (value is Map && value.containsKey('th')) {
          dictionaryData[key.toUpperCase()] = value['th'];
        }
      });

      if (mounted) {
        setState(() {
          _dictionary = dictionaryData;
          _totalWords = dictionaryData.length; // นับคำทั้งหมดในระบบ
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading dictionary: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeDatabase.getTheme(widget.currentUser.currentThemeId);
    final isDark = theme.brightness == Brightness.dark;

    // 🆕 ตัวกรองคำศัพท์จากการค้นหา (ค้นได้ทั้งอังกฤษและไทย)
    final foundWords = widget.currentUser.foundWordsList.where((word) {
      final translation = _dictionary[word] ?? '';
      return word.contains(_searchQuery.toUpperCase()) ||
             translation.contains(_searchQuery);
    }).toList();

    // คำนวณความคืบหน้า (Progress)
    double progress = _totalWords > 0
        ? widget.currentUser.wordsFound / _totalWords
        : 0.0;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      // 🆕 ใช้ GestureDetector เพื่อให้กดพื้นที่ว่างแล้วคีย์บอร์ดหุบลงไป
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20), // ระยะห่างจากขอบจอบน

              // --- 📖 HEADER ---
              Text(
                "MY DICTIONARY",
                textAlign: TextAlign.center, // 🆕 เพิ่มบรรทัดนี้เพื่อให้อยู่ตรงกลาง
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: theme.textColor,
                ),
              ),
              const SizedBox(height: 20),

              // --- 📊 PROGRESS CARD ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.correct.withOpacity(isDark ? 0.3 : 0.15), theme.correct.withOpacity(0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: theme.correct.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: theme.correct.withOpacity(0.2), shape: BoxShape.circle),
                                child: Icon(Icons.menu_book_rounded, color: theme.correct, size: 20),
                              ),
                              const SizedBox(width: 8), // 🔽 1. ลดระยะห่างนิดนึงจาก 12 เหลือ 8 ให้มีพื้นที่เขียนหนังสือเพิ่มขึ้น
                              Expanded(
                                // 🆕 2. ใช้ FittedBox ครอบ Text เพื่อให้มันย่อฟอนต์ลงเวลาจอเล็ก แทนการขึ้นจุด ...
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Words Unlocked",
                                    style: TextStyle(fontWeight: FontWeight.bold, color: theme.textColor, fontSize: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // ฝั่งตัวเลข
                        Text(
                          "${widget.currentUser.wordsFound} / $_totalWords",
                          // 🔽 3. ลดขนาดตัวเลขด้านหลังจาก 18 เหลือ 16 เพื่อคืนพื้นที่ให้ตัวหนังสือด้านหน้า
                          style: TextStyle(fontWeight: FontWeight.w900, color: theme.correct, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: theme.textColor.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(theme.correct),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- 🔍 SEARCH BAR ---
              TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                style: TextStyle(color: theme.textColor),
                decoration: InputDecoration(
                  hintText: "Search English or Thai...",
                  hintStyle: TextStyle(color: theme.textColor.withOpacity(0.4)),
                  prefixIcon: Icon(Icons.search_rounded, color: theme.textColor.withOpacity(0.4)),
                  suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.cancel_rounded, color: theme.textColor.withOpacity(0.4)),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = "");
                        },
                      )
                    : null,
                  filled: true,
                  fillColor: theme.textColor.withOpacity(0.05),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),

              // --- 📋 WORD LIST ---
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: theme.correct))
                    : widget.currentUser.foundWordsList.isEmpty
                        ? _buildEmptyState(theme) // แสดงหน้าจอตอนยังไม่มีคำศัพท์
                        : foundWords.isEmpty
                            ? Center(child: Text("No words found matching '$_searchQuery'", style: TextStyle(color: theme.textColor.withOpacity(0.5))))
                            : ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.only(bottom: 24),
                                itemCount: foundWords.length,
                                itemBuilder: (context, index) {
                                  final word = foundWords[index];
                                  final translation = _dictionary[word] ?? '...';

                                  // 🆕 Premium Card Design
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.grey.shade800 : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: theme.textColor.withOpacity(0.05)),
                                      boxShadow: [BoxShadow(color: theme.textColor.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        onTap: () {
                                          AppFeedback.playClick(widget.currentUser); // เสียงเวลากดการ์ด
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Row(
                                            children: [
                                              // ลำดับที่
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(color: theme.textColor.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                                                alignment: Alignment.center,
                                                child: Text("${index + 1}", style: TextStyle(fontWeight: FontWeight.bold, color: theme.textColor.withOpacity(0.5))),
                                              ),
                                              const SizedBox(width: 16),
                                              // คำศัพท์และความหมาย
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      word,
                                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: theme.textColor, letterSpacing: 2, fontFamily: 'monospace'),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      translation,
                                                      style: TextStyle(fontSize: 14, color: theme.correct, fontWeight: FontWeight.w600),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🆕 หน้าจอตอนที่ยังไม่มีคำศัพท์เลย (Empty State)
  Widget _buildEmptyState(GameTheme theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.textColor.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lock_outline_rounded, size: 64, color: theme.textColor.withOpacity(0.3)),
          ),
          const SizedBox(height: 24),
          Text(
            "Your Vault is Empty",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textColor),
          ),
          const SizedBox(height: 8),
          Text(
            "Play the game to unlock new words\nand fill up your dictionary!",
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.textColor.withOpacity(0.5), height: 1.5),
          ),
        ],
      ),
    );
  }
}
