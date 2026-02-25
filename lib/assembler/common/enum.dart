// class LookUpGroupId{
//     static const ButtonPurpose = 4;
// }

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
