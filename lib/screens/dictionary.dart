import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'mock_data.dart';
import 'theme_data.dart';

class DictionaryPage extends StatefulWidget {
  final User currentUser;

  const DictionaryPage({super.key, required this.currentUser});

  @override
  State<DictionaryPage> createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  Map<String, String> _dictionary = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDictionary();
  }

  Future<void> _loadDictionary() async {
    try {
      final String content =
          await rootBundle.loadString('assets/targetwords.json');
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
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle error
      print('Error loading dictionary: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeDatabase.getTheme(widget.currentUser.currentThemeId);
    final foundWords = widget.currentUser.foundWordsList;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: theme.backgroundColor, // สีพื้นหลังตามธีม
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "DICTIONARY",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.textColor, // สีหัวข้อตามธีม
              ),
            ),
            const SizedBox(height: 10),
            // Displaying progress based on user data
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                // ใช้สีธีมแบบจางๆ เป็นพื้นหลัง
                color: theme.correct.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.correct.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.book, color: theme.correct), // ไอคอนสีตามธีม
                  const SizedBox(width: 10),
                  Text(
                    "You have unlocked ${widget.currentUser.wordsFound} words!",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: theme.textColor, // สีตัวหนังสือในกล่อง
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // ส่วนแสดงรายการคำศัพท์ (List)
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: theme.textColor,
                      ),
                    )
                  : foundWords.isEmpty
                      ? Center(
                          child: Text(
                            "List of words will appear here as you find them.",
                            style:
                                TextStyle(color: theme.textColor.withOpacity(0.5)),
                          ),
                        )
                      : ListView.builder(
                          itemCount: foundWords.length,
                          itemBuilder: (context, index) {
                            final word = foundWords[index];
                            final translation = _dictionary[word] ?? '...';
                            return Card(
                              color: theme.brightness == Brightness.dark
                                  ? Colors.grey.shade900
                                  : Colors.white,
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                    color: theme.correct.withOpacity(0.3)),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: theme.correct,
                                  child: Text(
                                    "${index + 1}",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(
                                  word,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: theme.textColor,
                                      letterSpacing: 1.2),
                                ),
                                subtitle: Text(
                                  translation,
                                  style: TextStyle(
                                    color: theme.textColor.withOpacity(0.7),
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
    );
  }
}