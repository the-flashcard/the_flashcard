import 'package:flutter/material.dart';
import 'package:the_flashcard/common/resources/xed_progress.dart';

class LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: XedProgress.indicator(),
      );
}
