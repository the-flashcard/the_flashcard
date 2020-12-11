class EmailUtils {
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );

//   static final RegExp _passwordRegExp = RegExp(
// //    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$',
//     r'^[A-Za-z\d]{6,}$',
//   );

  static isValidEmail(String email) {
    return email != null ? _emailRegExp.hasMatch(email) : false;
  }

  static isValidPassword(String password) {
//    return password!=null? _passwordRegExp.hasMatch(password): false;
    return password != null && password.trim().length >= 6;
  }
}
