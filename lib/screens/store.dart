import 'package:flutter/material.dart';
import '../models/mock_data.dart';
import '../theme/theme_data.dart';

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

  // ฟังก์ชันหลักเมื่อกดที่การ์ด
  void _buyOrEquipTheme(GameTheme theme) {
    // 1. ถ้ามีแล้ว -> ใส่เลย (Equip) ไม่ต้องถาม
    if (widget.currentUser.ownedThemeIds.contains(theme.id)) {
      if (widget.currentUser.currentThemeId != theme.id) {
        widget.currentUser.currentThemeId = theme.id;
        widget.currentUser.saveData(); // บันทึกข้อมูล

        setState(() {}); // รีเฟรชหน้าร้านค้า
        widget.onShopAction(); // รีเฟรชหน้าหลัก

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
    // 2. ถ้ายังไม่มี -> เด้งหน้าต่าง Confirm ก่อน
    else {
      _showConfirmDialog(theme);
    }
  }

  // --- 🆕 ฟังก์ชันหน้าต่างยืนยันการซื้อ ---
  void _showConfirmDialog(GameTheme theme) {
    final currentAppTheme = ThemeDatabase.getTheme(widget.currentUser.currentThemeId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: currentAppTheme.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.shopping_cart_checkout, color: Colors.amber, size: 28),
            const SizedBox(width: 10),
            Text(
              "Confirm Purchase",
              style: TextStyle(color: currentAppTheme.textColor, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        content: Text(
          "Do you want to buy '${theme.name}' for ${theme.price} coins?",
          style: TextStyle(color: currentAppTheme.textColor.withOpacity(0.8), fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // ปิดหน้าต่าง (ยกเลิก)
            child: Text("Cancel", style: TextStyle(color: currentAppTheme.textColor.withOpacity(0.5))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: currentAppTheme.correct, // สีปุ่มยืนยันตามธีม
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context); // ปิดหน้าต่างก่อน
              _processPurchase(theme); // ค่อยไปหักเงิน
            },
            child: const Text("Buy", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันจัดการระบบหักเงิน (หลังจากกดยืนยันแล้ว)
  void _processPurchase(GameTheme theme) {
    if (widget.currentUser.coins >= theme.price) {
      // หักเงินและเพิ่มเข้าคอลเลกชัน
      widget.currentUser.coins -= theme.price;
      widget.currentUser.ownedThemeIds.add(theme.id);
      widget.currentUser.currentThemeId = theme.id; // ซื้อปุ๊บใส่ปั๊บ

      widget.currentUser.saveData(); // บันทึกข้อมูล

      setState(() {}); // รีเฟรชหน้า Store
      widget.onShopAction(); // รีเฟรชหน้า Home ทันที

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("ซื้อสำเร็จ! 🎨"),
          backgroundColor: Colors.green,
          duration: Duration(milliseconds: 1000),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      // เงินไม่พอ
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("ไม่ดูตังตัวเองก่อนจะซื้อวะน้อง"),
          backgroundColor: Colors.redAccent,
          duration: Duration(milliseconds: 1000),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
              "Color Themes 🎨",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: currentAppTheme.textColor
              ),
            ),
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: ThemeDatabase.themes.length,
            itemBuilder: (context, index) {
              final theme = ThemeDatabase.themes[index];
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
                        // สีตัวอย่าง
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

                        // ชื่อธีม
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                theme.name,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: currentAppTheme.textColor
                                ),
                              ),
                              if (isEquipped)
                                const Text("Currently Active", style: TextStyle(color: Colors.green, fontSize: 12))
                              else if (isOwned)
                                const Text("Owned", style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),

                        // ปุ่ม/ราคา
                        if (isEquipped)
                          const Icon(Icons.check_circle, color: Colors.green, size: 30)
                        else if (isOwned)
                          const Chip(
                            label: Text("USE", style: TextStyle(fontWeight: FontWeight.bold)),
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