part of edit_card_screen;

class _EditCardIconButtonWidget extends StatelessWidget
    implements OnboardingObject {
  final VoidCallback onTap;
  final Widget icon;
  final Widget iconForOnboarding;

  final Key testDriverKey;

  const _EditCardIconButtonWidget({
    Key key,
    this.onTap,
    @required this.icon,
    @required this.iconForOnboarding,
    this.testDriverKey,
  }) : super(key: key);

  _EditCardIconButtonWidget.onboarding({@required this.icon})
      : onTap = null,
        iconForOnboarding = null,
        testDriverKey = null;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: testDriverKey,
      icon: icon,
      onPressed: onTap,
    );
  }

  @override
  Widget cloneWithoutGlobalKey() {
    return _EditCardIconButtonWidget.onboarding(icon: iconForOnboarding);
  }
}
