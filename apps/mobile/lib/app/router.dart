import 'package:go_router/go_router.dart';

import '../features/catalog/presentation/area_screen.dart';
import '../features/exercise_engine/presentation/exercise_screen.dart';
import '../features/parent_area/presentation/parent_screen.dart';
import '../features/profiles/presentation/profile_edit_screen.dart';
import '../features/world_map/presentation/world_map_screen.dart';

/// Разделы для взрослых открываются только кнопкой с родительским барьером;
/// внешних ссылок на них нет.
GoRouter createRouter() => GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const WorldMapScreen(),
      routes: [
        GoRoute(
          path: 'area/:code',
          builder: (context, state) =>
              AreaScreen(areaCode: state.pathParameters['code']!),
        ),
        GoRoute(
          path: 'task/:id',
          builder: (context, state) =>
              ExerciseScreen(taskId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: 'parent',
          builder: (context, state) => const ParentScreen(),
          routes: [
            GoRoute(
              path: 'child/new',
              builder: (context, state) => const ProfileEditScreen(),
            ),
            GoRoute(
              path: 'child/:id',
              builder: (context, state) =>
                  ProfileEditScreen(childId: state.pathParameters['id']),
            ),
          ],
        ),
      ],
    ),
  ],
);
