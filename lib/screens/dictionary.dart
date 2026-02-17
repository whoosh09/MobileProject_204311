import 'package:flutter/material.dart';
import 'mock_data.dart';
import 'theme_data.dart';

class DictionaryPage extends StatelessWidget {
  final User currentUser;

  const DictionaryPage({super.key, required this.currentUser});


  @override
  Widget build(BuildContext context) {
    final theme = ThemeDatabase.getTheme(currentUser.currentThemeId);
    final foundWords = currentUser.foundWordsList;
    return Scaffold(
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
                    "You have unlocked ${currentUser.wordsFound} words!",
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
              child: foundWords.isEmpty
                  ? Center(
                child: Text(
                  "List of words will appear here as you find them.",
                  style: TextStyle(color: theme.textColor.withOpacity(0.5)),
                ),
              )
                  : ListView.builder(
                itemCount: foundWords.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: theme.brightness == Brightness.dark ? Colors.grey.shade900 : Colors.white,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: theme.correct.withOpacity(0.3)),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.correct,
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        foundWords[index],
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.textColor,
                            letterSpacing: 1.2
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