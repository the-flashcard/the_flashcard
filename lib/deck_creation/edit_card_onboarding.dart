part of edit_card_screen;

class _EditCardOnboarding extends StatelessWidget {
  final String editContentDescription =
      core.Config.getString('msg_onboarding_edit_content_card');
  final String flipCardDescription =
      core.Config.getString('msg_onboarding_edit_back_card');

  final String nameScreen;

  _EditCardOnboarding({Key key, @required this.nameScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildOnboarding(
      currentNameScreen: nameScreen,
      localStoredKey: LocalStoredKeys.firstTimeEditCard,
      listOnboardingData: <OnboardingData>[
        OnboardingData.right(
          globalKey: GlobalKeys.editCard,
          description: editContentDescription,
          direction: OnboardingDirection.BottomToTop,
        ),
        OnboardingData.left(
          globalKey: GlobalKeys.flipCard,
          description: flipCardDescription,
          direction: OnboardingDirection.BottomToTop,
        ),
      ],
    );
  }
}
