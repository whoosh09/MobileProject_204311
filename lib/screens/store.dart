import 'package:flutter/material.dart';
import 'mock_data.dart';
import 'theme_data.dart';

class StorePage extends StatefulWidget {
  final User currentUser;
  final VoidCallback onShopAction; // ตัวสั่งรีเฟรชหน้า Home

  const StorePage({
    super.key,
    required this.currentUser,
    required this.onShopAction,
  });

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {

  void _buyOrEquipTheme(GameTheme theme) {
    bool dataChanged = false;

    // 1. ถ้ามีแล้ว -> ใส่เลย (Equip)
    if (widget.currentUser.ownedThemeIds.contains(theme.id)) {
      if (widget.currentUser.currentThemeId != theme.id) {
        widget.currentUser.currentThemeId = theme.id;
        dataChanged = true;

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("เปลี่ยนธีมเป็น ${theme.name} แล้ว!"),
            duration: const Duration(milliseconds: 800),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
    // 2. ถ้ายังไม่มี -> เช็คเงิน -> ซื้อ (Buy)
    else {
      if (widget.currentUser.coins >= theme.price) {
        widget.currentUser.coins -= theme.price;
        widget.currentUser.ownedThemeIds.add(theme.id);
        widget.currentUser.currentThemeId = theme.id;
        dataChanged = true;

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("ซื้อสำเร็จ!"),
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 800),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("เงินไม่พอ!"),
            backgroundColor: Colors.red,
            duration: Duration(milliseconds: 800),
          ),
        );
      }
    }
    if (dataChanged) {
      widget.currentUser.saveData();
      setState(() {
      });
      widget.onShopAction();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentAppTheme = ThemeDatabase.getTheme(widget.currentUser.currentThemeId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Center(
            child: Text(
              "COLOR THEMES 🎨",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: currentAppTheme.textColor // สีเปลี่ยนตามธีม
              ),
            ),
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: ThemeDatabase.themes.length,
            itemBuilder: (context, index) {
              final theme = ThemeDatabase.themes[index]; // ธีมของสินค้าชิ้นนั้น
              final isOwned = widget.currentUser.ownedThemeIds.contains(theme.id);
              final isEquipped = widget.currentUser.currentThemeId == theme.id;

              return Card(
                color: currentAppTheme.brightness == Brightness.dark
                    ? Colors.grey.shade900
                    : Colors.white,
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isEquipped
                      ? const BorderSide(color: Colors.green, width: 2)
                      : BorderSide.none,
                ),
                child: InkWell(
                  onTap: () => _buyOrEquipTheme(theme),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        // ส่วนที่ 1: สีตัวอย่าง
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              _buildColorCircle(theme.correct),
                              const SizedBox(width: 4),
                              _buildColorCircle(theme.present),
                              const SizedBox(width: 4),
                              _buildColorCircle(theme.absent),
                            ],
                          ),
                        ),

                        const SizedBox(width: 16),

                        // ส่วนที่ 2: ชื่อธีม
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                theme.name,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: currentAppTheme.textColor // สีเปลี่ยนตามธีม
                                ),
                              ),
                              if (isEquipped)
                                const Text("Currently Active", style: TextStyle(color: Colors.green, fontSize: 12))
                              else if (isOwned)
                                const Text("Owned", style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),

                        // ส่วนที่ 3: ปุ่ม/ราคา
                        if (isEquipped)
                          const Icon(Icons.check_circle, color: Colors.green, size: 30)
                        else if (isOwned)
                          const Chip(
                            label: Text("USE"),
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.grey),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text("💰 ", style: TextStyle(fontSize: 12, color: Colors.black)),
                                Text(
                                    "${theme.price}",
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorCircle(Color color) {
    return Container(
      width: 20, height: 20,
      decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300)
      ),
    );
  }
}