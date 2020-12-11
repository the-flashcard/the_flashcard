class ApiErrorReasons {
  static const String InvalidCredentials = "invalid_credentials";
  static const String EmailExisted = "email_existed";
  static const String EmailNotExisted = "email_not_existed";
  static const String EmailInvalid = "email_invalid";
  static const String EmailRequired = "email_required";
  static const String EmailVerificationRequired = "email_verification_required";
  static const String AuthTypeUnsupported = "auth_type_unsupported";
  static const String PhoneExisted = "phone_existed";
  static const String PhoneInvalid = "phone_invalid";
  static const String PhoneNotExisted = "phone_not_existed";
  static const String PhoneRequired = "phone_required";
  static const String QuotaExceed = "quota_exceed";
  static const String RegistrationRequired = "registration_required";
  static const String VerificationCodeInvalid = "verification_code_invalid";
  static const String NotAuthenticated = "not_authenticated";
  static const String Unauthorized = "not_allowed";
  static const String NotFound = "not_found";
  static const String AlreadyExisted = "already_existed";
  static const String NotSupported = "not_supported";
  static const String Expired = "expired";
  static const String BadRequest = "bad_request";
  static const String InternalError = "internal_error";
  static const String OutOfQuotaError = "too_many_request";

  static const String NoConnectionError = "no_connection_error";
  static const String CancelledConnectionError = "cancelled_connection_error";
  static const String ConnectionTimeOutError = "connect_timeout_error";
  static const String ClientError = "client_error";
}
