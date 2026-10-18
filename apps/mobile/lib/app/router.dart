import 'package:go_router/go_router.dart';

import '../features/age_routes/presentation/age_selection.dart';
import '../features/catalog/presentation/area_screen.dart';
import '../features/exercise_engine/presentation/exercise_screen.dart';
import '../features/world_map/presentation/world_map_screen.dart';

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
          path: 'age',
          builder: (context, state) => const AgeSelectionScreen(),
        ),
        GoRoute(
          path: 'task/:id',
          builder: (context, state) =>
              ExerciseScreen(taskId: state.pathParameters['id']!),
        ),
      ],
    ),
  ],
);
