import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:flutter/material.dart';
class LoadingBar extends StatelessWidget {
  const LoadingBar({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 100),
      child: Center(
        child: SizedBox(
          height: VetTheme.mediaHalfSize(context)/2,
          width: VetTheme.mediaHalfSize(context)/2,
          child: CircularProgressIndicator(
            color: VetTheme.mainIndigoColor
          ),
        ),
      ),
    );
  }
}
