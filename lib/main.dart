import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  runApp(
    // ProviderScope is required by Riverpod — it must wrap the entire widget tree.
    const ProviderScope(
      child: UnperchApp(),
    ),
  );
}
