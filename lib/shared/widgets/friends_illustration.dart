import 'package:flutter/material.dart';

class FriendsIllustration extends StatelessWidget {
  final double height;

  const FriendsIllustration({super.key, this.height = 140});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Friend 1 (Green top, excited pose)
          _buildFriend(
            name: 'Sharon',
            bgColor: const Color(0xFF10B981),
            avatarEmoji: '💁🏾‍♀️',
            height: height * 0.85,
          ),
          const SizedBox(width: 8),
          // Friend 2 (Middle - Gold/Orange top, center hero)
          _buildFriend(
            name: 'Michael',
            bgColor: const Color(0xFFF59E0B),
            avatarEmoji: '🙋🏾‍♂️',
            height: height,
            isCenter: true,
          ),
          const SizedBox(width: 8),
          // Friend 3 (Red/Coral top, cheering pose)
          _buildFriend(
            name: 'Ivy',
            bgColor: const Color(0xFFEF4444),
            avatarEmoji: '🙆🏾‍♀️',
            height: height * 0.9,
          ),
        ],
      ),
    );
  }

  Widget _buildFriend({
    required String name,
    required Color bgColor,
    required String avatarEmoji,
    required double height,
    bool isCenter = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: isCenter ? 64 : 54,
          height: isCenter ? 64 : 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgColor.withOpacity(0.25),
            border: Border.all(color: bgColor, width: isCenter ? 2.5 : 1.5),
            boxShadow: [
              BoxShadow(
                color: bgColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            avatarEmoji,
            style: TextStyle(fontSize: isCenter ? 36 : 28),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: isCenter ? 72 : 60,
          height: height * 0.45,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          alignment: Alignment.center,
          child: Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
