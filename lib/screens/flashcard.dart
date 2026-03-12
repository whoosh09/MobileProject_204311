import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math';
import '../models/mock_data.dart';
import '../services/audio_helper.dart';
import '../theme/theme_data.dart';
import '../components/custom_3d_buttton.dart'; // ปุ่ม 3D
import '../components/victory_effect.dart';    // 🆕 เอฟเฟกต์พลุ

class FlashcardPage extends StatefulWidget {
  final User currentUser;

  const FlashcardPage({super.key, required this.currentUser});

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> with SingleTickerProviderStateMixin {
  bool isLoading = true;

  Map<String, String> wordMeanings = {};
  List<String> unlockedWords = [];

  // โหมดการเล่น (false = Study พลิกการ์ด, true = Quiz ทายคำศัพท์)
  bool isQuizMode = false;

  // --- State สำหรับ Study Mode ---
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool isFront = true;
  int studyIndex = 0;

  // --- State สำหรับ Quiz Mode ---
  int quizIndex = 0;
  List<String> currentOptions = [];
  String? selectedAnswer;
  bool isAnswering = false;

  // 🆕 State สำหรับควบคุมพลุ
  bool showVictory = false;

  @override
  void initState() {
    super.initState();
    // Setup แอนิเมชันพลิกการ์ด
    _flipController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(_flipController);

    _loadTranslations();
  }

  Future<void> _loadTranslations() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/targetwords.json');
      final Map<String, dynamic> data = json.decode(jsonString);

      unlockedWords = List.from(widget.currentUser.foundWordsList);

      for (var word in unlockedWords) {
        String lowerWord = word.toLowerCase();
        if (data.containsKey(lowerWord) && data[lowerWord]['th'] != null) {
          wordMeanings[word] = data[lowerWord]['th'];
        } else {
          wordMeanings[word] = "ไม่มีคำแปล";
        }
      }

      setState(() {
        isLoading = false;
        if (unlockedWords.isNotEmpty) {
          unlockedWords.shuffle(); // สุ่มคำศัพท์ให้ควิซไม่จำเจ
          _generateOptions();
        }
      });
    } catch (e) {
      print("Error loading targetwords.json: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  // ==========================================
  // 📖 ลอจิกสำหรับ STUDY MODE (พลิกการ์ด)
  // ==========================================
  void _flipCard() {
    if (_flipController.isAnimating) return;
    AppFeedback.playFlip(widget.currentUser);
    AppFeedback.triggerHaptic(widget.currentUser);

    if (isFront) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
    isFront = !isFront;
  }

  void _nextStudyCard() {
    if (studyIndex < unlockedWords.length - 1) {
      AppFeedback.playClick(widget.currentUser);
      setState(() {
        studyIndex++;
        _resetCard();
      });
    }
  }

  void _prevStudyCard() {
    if (studyIndex > 0) {
      AppFeedback.playClick(widget.currentUser);
      setState(() {
        studyIndex--;
        _resetCard();
      });
    }
  }

  void _resetCard() {
    if (!isFront) {
      _flipController.value = 0;
      isFront = true;
    }
  }

  // ==========================================
  // 🎮 ลอจิกสำหรับ QUIZ MODE (ทายคำศัพท์)
  // ==========================================
  void _generateOptions() {
    String currentWord = unlockedWords[quizIndex];
    String correctMeaning = wordMeanings[currentWord] ?? "ไม่มีคำแปล";

    List<String> allMeanings = wordMeanings.values.where((m) => m != "ไม่มีคำแปล").toList();
    allMeanings.remove(correctMeaning);
    allMeanings.shuffle();

    currentOptions = [correctMeaning];
    currentOptions.addAll(allMeanings.take(3));
    currentOptions.shuffle();

    selectedAnswer = null;
    isAnswering = false;
    showVictory = false; // รีเซ็ตพลุ
  }

  Future<void> _checkAnswer(String answer) async {
    if (isAnswering) return;

    setState(() {
      isAnswering = true;
      selectedAnswer = answer;
    });

    String currentWord = unlockedWords[quizIndex];
    String correctMeaning = wordMeanings[currentWord] ?? "";

    if (answer == correctMeaning) {
      // ✅ ตอบถูก! โชว์พลุกระจาย
      AppFeedback.playCorrect(widget.currentUser);
      setState(() => showVictory = true);
    } else {
      // ❌ ตอบผิด
      AppFeedback.playWrong(widget.currentUser);
      AppFeedback.triggerHaptic(widget.currentUser);
    }

    // หน่วงเวลาดูเฉลย และดูพลุสวยๆ 1.5 วินาที
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    if (quizIndex < unlockedWords.length - 1) {
      setState(() {
        quizIndex++;
        _generateOptions();
      });
    } else {
      setState(() {
        unlockedWords.shuffle();
        quizIndex = 0;
        _generateOptions();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Round complete! Keep practicing. 🧠', textAlign: TextAlign.center),
          backgroundColor: ThemeDatabase.getTheme(widget.currentUser.currentThemeId).correct,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ==========================================
  // 🖥️ UI BUILDER
  // ==========================================
  @override
  Widget build(BuildContext context) {
    final theme = ThemeDatabase.getTheme(widget.currentUser.currentThemeId);

    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: theme.correct));
    }

    // --- 🔒 โหมดล็อค ---
    if (widget.currentUser.wordsFound < 15) {
      int wordsNeeded = 15 - widget.currentUser.wordsFound;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline_rounded, size: 100, color: theme.textColor.withOpacity(0.3)),
              const SizedBox(height: 20),
              Text("LOCKED", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.textColor)),
              const SizedBox(height: 15),
              Text("Find $wordsNeeded more words to unlock\nStudy & Quiz Modes!", textAlign: TextAlign.center, style: TextStyle(color: theme.textColor.withOpacity(0.7), fontSize: 18)),
            ],
          ),
        ),
      );
    }

    if (unlockedWords.isEmpty) {
      return Center(child: Text("No words available.", style: TextStyle(color: theme.textColor)));
    }

    return Stack(
      children: [
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- 🎛️ HEADER & MODE TOGGLE ---
                // --- HEADER ---
                Center( // ✅ เปลี่ยนจาก Row เป็น Center
                  child: Text(
                    "FLASHCARDS",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: theme.textColor,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Toggle Switch สลับโหมด
                Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: theme.textColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _buildModeTab("📖 STUDY", false, theme)),
                      Expanded(child: _buildModeTab("🎮 QUIZ", true, theme)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // --- 🔀 สลับเนื้อหาตามโหมดที่เลือก ---
                Expanded(
                  child: isQuizMode ? _buildQuizMode(theme) : _buildStudyMode(theme),
                ),
              ],
            ),
          ),
        ),

        // ✨ เอฟเฟกต์พลุกระจายเมื่อตอบควิซถูก! (วางซ้อนทับหน้าจอทั้งหมด)
        if (showVictory) const VictoryEffect(),
      ],
    );
  }

  // --- Widget: ปุ่มสลับโหมด ---
  Widget _buildModeTab(String title, bool isQuiz, GameTheme theme) {
    bool isSelected = isQuizMode == isQuiz;
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          AppFeedback.playClick(widget.currentUser);
          setState(() => isQuizMode = isQuiz);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? theme.correct : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isSelected ? [BoxShadow(color: theme.correct.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))] : [],
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.textColor.withOpacity(0.5),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  // ==========================================
  // 📖 UI: STUDY MODE (พลิกการ์ด)
  // ==========================================
  Widget _buildStudyMode(GameTheme theme) {
    String currentWord = unlockedWords[studyIndex];
    String currentMeaning = wordMeanings[currentWord] ?? "";

    return Column(
      children: [
        Text(
          "Card ${studyIndex + 1} of ${unlockedWords.length}",
          style: TextStyle(color: theme.textColor.withOpacity(0.6), fontSize: 14),
        ),
        const SizedBox(height: 20), // 🆕 เปลี่ยน Spacer เป็น SizedBox

        // 🆕 ใช้ Expanded ครอบการ์ด เพื่อให้ขยายเต็มพื้นที่ที่เหลืออัตโนมัติ (Responsive)
        Expanded(
          child: GestureDetector(
            onTap: _flipCard,
            child: AnimatedBuilder(
              animation: _flipAnimation,
              builder: (context, child) {
                final angle = _flipAnimation.value * pi;
                bool showFront = angle < (pi / 2);
                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(angle),
                  alignment: Alignment.center,
                  child: showFront
                      ? _buildCardSide(currentWord.toUpperCase(), true, theme)
                      : Transform(
                          transform: Matrix4.identity()..rotateY(pi),
                          alignment: Alignment.center,
                          child: _buildCardSide(currentMeaning, false, theme),
                        ),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 24), // 🆕 เปลี่ยน Spacer เป็น SizedBox
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              iconSize: 40,
              color: studyIndex > 0 ? theme.correct : theme.textColor.withOpacity(0.2),
              icon: const Icon(Icons.arrow_circle_left_rounded),
              onPressed: studyIndex > 0 ? _prevStudyCard : null,
            ),
            IconButton(
              iconSize: 40,
              color: studyIndex < unlockedWords.length - 1 ? theme.correct : theme.textColor.withOpacity(0.2),
              icon: const Icon(Icons.arrow_circle_right_rounded),
              onPressed: studyIndex < unlockedWords.length - 1 ? _nextStudyCard : null,
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  // --- อัปเกรดดีไซน์การ์ดให้ Responsive ---
  Widget _buildCardSide(String text, bool isFrontSide, GameTheme theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.textColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: theme.textColor.withOpacity(0.1), width: 2),
        boxShadow: isFrontSide ? [] : [
          BoxShadow(color: theme.correct.withOpacity(0.15), blurRadius: 30, spreadRadius: 5)
        ],
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), // 🆕 เพิ่มกรอบ Padding ให้สมดุล
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12), // 🔽 ลดขนาดกล่องไอคอนลงนิดนึง
            decoration: BoxDecoration(
              color: isFrontSide ? theme.textColor.withOpacity(0.1) : theme.correct.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFrontSide ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: isFrontSide ? theme.textColor.withOpacity(0.5) : theme.correct,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          // 🆕 ใช้ FittedBox กันล้น
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              isFrontSide ? "WHAT DOES THIS MEAN?" : "TRANSLATION",
              style: TextStyle(
                color: isFrontSide ? theme.textColor.withOpacity(0.4) : theme.correct.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 🆕 ให้ตัวหนังสือคำศัพท์ยืดหยุ่นและย่ออัตโนมัติถ้ายาวเกินไป
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isFrontSide ? 42 : 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: isFrontSide ? 4 : 0,
                  color: isFrontSide ? theme.textColor : theme.correct,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 🎮 UI: QUIZ MODE (ทายคำศัพท์) - 🎨 RESPONSIVE
  // ==========================================
  Widget _buildQuizMode(GameTheme theme) {
    bool isDark = theme.brightness == Brightness.dark;
    String currentWord = unlockedWords[quizIndex];
    String correctMeaning = wordMeanings[currentWord] ?? "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: (quizIndex + 1) / unlockedWords.length,
            backgroundColor: theme.textColor.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(theme.correct),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 16), // 🔽 ลดระยะห่างลง

        // --- 2. VIBRANT QUESTION CARD ---
        Container(
          width: double.infinity,
          // 🔽 1. ลด vertical padding จาก 32 เหลือ 20 ให้กล่องเตี้ยลง
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [theme.correct, theme.correct.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(28), // 🔽 ลดความโค้งลงนิดหน่อยให้รับกับกล่องที่เล็กลง
            boxShadow: [BoxShadow(color: theme.correct.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8), // 🔽 ลด padding ของกรอบไอคอน
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 25), // 🔽 ลดขนาดไอคอนจาก 28 เหลือ 24
              ),
              const SizedBox(height: 8), // 🔽 ลดระยะห่างบรรทัด
              const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text("What does this word mean?", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 4), // 🔽 ลดระยะห่างก่อนถึงคำศัพท์ให้กระชับขึ้น

              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  currentWord.toUpperCase(),
                  // 🔽 ลดฟอนต์ลงนิดนึงให้พอดีกับกล่องที่เล็กลง
                  style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2)
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15), // 🔽 ลดระยะห่างลงให้สมดุล

        // --- 3. ANSWER OPTIONS ---
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: currentOptions.map((option) {
                ButtonState buttonState = ButtonState.normal;
                Color currentTextColor = theme.textColor;
                Color currentBgColor = isDark ? Colors.grey.shade800 : Colors.white;
                Color currentShadowColor = isDark ? Colors.grey.shade900 : Colors.grey.shade300;

                String displayText = option;

                if (isAnswering) {
                  if (option == correctMeaning) {
                    buttonState = ButtonState.correct;
                    currentTextColor = Colors.white;
                    displayText = "$option";
                  } else if (option == selectedAnswer) {
                    buttonState = ButtonState.incorrect;
                    currentTextColor = Colors.white;
                    displayText = "$option";
                  } else {
                    currentTextColor = theme.textColor.withOpacity(0.3);
                    currentShadowColor = Colors.transparent;
                  }
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0), // 🔽 ลดระยะห่างระหว่างปุ่มลงนิดหน่อย
                  child: SizedBox(
                    width: double.infinity,
                    child: Custom3DButton(
                      text: displayText,
                      state: buttonState,
                      backgroundColor: currentBgColor,
                      shadowColor: currentShadowColor,
                      textColor: currentTextColor,
                      onPressed: () => _checkAnswer(option),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
