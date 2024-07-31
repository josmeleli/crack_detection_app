enum AuthResultStatus {
  successful,
  emailAlreadyExists,
  wrongPassword,
  invalidEmail,
  userNotFound,
  userDisabled,
  operationNotAllowed,
  tooManyRequests,
  weakPassword,
  undefined,
}

class AuthExceptionHandler {
  static handleException(e) {
    final AuthResultStatus status;
    switch (e.code) {
      case "invalid-email":
        status = AuthResultStatus.invalidEmail;
        break;
      case "email-already-in-use":
        status = AuthResultStatus.emailAlreadyExists;
        break;
      case "wrong-password":
        status = AuthResultStatus.wrongPassword;
        break;
      case "user-not-found":
        status = AuthResultStatus.userNotFound;
        break;
      case "user-disabled":
        status = AuthResultStatus.userDisabled;
        break;
      case "operation-not-allowed":
        status = AuthResultStatus.operationNotAllowed;
        break;
      case "too-many-requests":
        status = AuthResultStatus.tooManyRequests;
        break;
      case "weak-password":
        status = AuthResultStatus.weakPassword;
        break;
      default:
        status = AuthResultStatus.undefined;
    }

    return status;
  }

  static generateExceptionMessage(exceptionCode) {
    String errorMessage;
    switch (exceptionCode) {
      case AuthResultStatus.invalidEmail:
        errorMessage = "El correo electrónico no es válido";
        break;
      case AuthResultStatus.emailAlreadyExists:
        errorMessage = "El correo electrónico ya está en uso";
        break;
      case AuthResultStatus.wrongPassword:
        errorMessage = "La contraseña es incorrecta";
        break;
      case AuthResultStatus.userNotFound:
        errorMessage = "El usuario no existe";
        break;
      case AuthResultStatus.userDisabled:
        errorMessage = "El usuario ha sido deshabilitado";
        break;
      case AuthResultStatus.operationNotAllowed:
        errorMessage = "Operación no permitida";
        break;
      case AuthResultStatus.tooManyRequests:
        errorMessage = "Demasiadas solicitudes. Intente más tarde";
        break;
      case AuthResultStatus.weakPassword:
        errorMessage = "La contraseña es débil";
        break;
      default:
        errorMessage = "Error desconocido";
    }

    return errorMessage;
  }
}