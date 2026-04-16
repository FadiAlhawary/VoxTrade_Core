// class LookUpGroupId{
//     static const ButtonPurpose = 4;
// }

import 'dart:ui';

enum ButtonPurpose {
  primary(3),
  secondary(4),
  danger(6);

  final int referenceLookUpId;

  const ButtonPurpose(this.referenceLookUpId);
}

enum SnackBarCompStatus {
  success(0),
  warning(1),
  danger(2),
  info(3);

  final int referenceStatusId;

  const SnackBarCompStatus(this.referenceStatusId);
}
enum NewsType {
  market(0),
  company(1);

  final int referenceNewsTypeId;

  const NewsType(this.referenceNewsTypeId);
}
Color primaryColor = Color(0xFF4988C4);
// Color secondaryColor = Color(0xFFF5F5F5);

