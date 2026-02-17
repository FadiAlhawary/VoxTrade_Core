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