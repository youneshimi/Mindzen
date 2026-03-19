import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UserRole { employe, medecin, drh }

final currentRoleProvider = StateProvider<UserRole?>((ref) => null);
