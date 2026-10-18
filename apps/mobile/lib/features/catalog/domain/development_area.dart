import 'package:flutter/material.dart';

/// 12 направлений развития. [code] совпадает с полем `area` в схеме контента.
enum DevelopmentArea {
  speech('speech', Icons.record_voice_over_rounded, Color(0xFFFF8A80)),
  logic('logic', Icons.extension_rounded, Color(0xFF7E8CE0)),
  math('math', Icons.calculate_rounded, Color(0xFF4FC3A1)),
  literacy('literacy', Icons.abc_rounded, Color(0xFFFFB74D)),
  memoryAttention(
    'memory_attention',
    Icons.visibility_rounded,
    Color(0xFF9575CD),
  ),
  emotionalSocial(
    'emotional_social',
    Icons.favorite_rounded,
    Color(0xFFF06292),
  ),
  selfCare('self_care', Icons.clean_hands_rounded, Color(0xFF4DB6AC)),
  creativity('creativity', Icons.palette_rounded, Color(0xFFBA68C8)),
  world('world', Icons.pets_rounded, Color(0xFF81C784)),
  music('music', Icons.music_note_rounded, Color(0xFF64B5F6)),
  movement('movement', Icons.directions_run_rounded, Color(0xFFFF8F65)),
  languages('languages', Icons.translate_rounded, Color(0xFF4DD0E1));

  const DevelopmentArea(this.code, this.icon, this.color);

  final String code;
  final IconData icon;
  final Color color;

  static DevelopmentArea? fromCode(String code) {
    for (final area in values) {
      if (area.code == code) return area;
    }
    return null;
  }
}
