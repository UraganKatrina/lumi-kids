import 'package:flutter/material.dart';

import '../domain/child_profile.dart';

class ChildAvatarView extends StatelessWidget {
  const ChildAvatarView({super.key, required this.avatar, this.size = 56});

  final ChildAvatar avatar;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: avatar.color, shape: BoxShape.circle),
      child: Icon(avatar.icon, color: Colors.white, size: size * 0.6),
    );
  }
}
