String? emailValidator(String? text) {
  if (text == null || text.trim().isEmpty) {
    return 'El correo está vacío';
  }
  final emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    caseSensitive: false,
  );
  if (!emailRegExp.hasMatch(text)) {
    return 'El correo no es válido';
  }
  return null;
}

String? passwordValidator(String? text) {
  if (text == null || text.trim().isEmpty) {
    return 'La contraseña está vacía';
  }
  return null;
}

String? confirmPasswordValidator(String? text, String? password) {
  if (text == null || text.trim().isEmpty) {
    return 'La confirmación de la contraseña está vacía';
  }
  if (text != password) {
    return 'Las contraseñas no coinciden';
  }
  return null;
}

String? nameValidator(String? text) {
  if (text == null || text.trim().isEmpty) {
    return 'El nombre está vacío';
  }
  // Permitir letras, espacios y tildes
  final RegExp nameExp = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');
  if (!nameExp.hasMatch(text)) {
    return 'Por favor ingrese un nombre válido';
  }
  return null;
}

String? phoneValidator(String? text) {
  if (text == null || text.trim().isEmpty) {
    return 'El teléfono está vacío';
  }
  final phoneRegExp = RegExp(
    r'^[0-9]{9}$',
    caseSensitive: false,
  );
  if (!phoneRegExp.hasMatch(text)) {
    return 'El teléfono no es válido. Debe tener 9 dígitos.';
  }
  return null;
}