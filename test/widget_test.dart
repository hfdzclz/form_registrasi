import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:form_registrasi/main.dart';

void main() {
  testWidgets('registration form shows its six fields', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(TextFormField), findsNWidgets(6));
    expect(find.text('Nama Lengkap'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Nomor Telepon'), findsOneWidget);
    expect(find.text('Tanggal Lahir'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Konfirmasi Password'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(
            find.descendant(
              of: find.byType(TextFormField).at(2),
              matching: find.byType(TextField),
            ),
          )
          .keyboardType,
      TextInputType.phone,
    );
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    expect(find.text('Jenis Kelamin'), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsOneWidget);
    expect(find.byIcon(Icons.calendar_today), findsOneWidget);
  });

  testWidgets('terms must be checked before submitting', (tester) async {
    await tester.pumpWidget(const MyApp());

    final termsCheckbox = find.byKey(const ValueKey('termsCheckbox'));
    expect(tester.widget<CheckboxListTile>(termsCheckbox).value, isFalse);

    await tester.ensureVisible(find.text('Daftar'));
    await tester.tap(find.text('Daftar'));
    await tester.pump();
    expect(
      find.text('Anda harus menyetujui syarat dan ketentuan'),
      findsOneWidget,
    );

    await tester.ensureVisible(termsCheckbox);
    await tester.tap(termsCheckbox);
    await tester.pump();
    expect(tester.widget<CheckboxListTile>(termsCheckbox).value, isTrue);
    expect(
      find.text('Anda harus menyetujui syarat dan ketentuan'),
      findsNothing,
    );
  });

  testWidgets('password strength updates for weak, medium, and strong', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    final passwordField = find.byType(TextFormField).at(4);

    await tester.enterText(passwordField, 'short7');
    await tester.pump();
    expect(find.text('Kekuatan Password: Lemah'), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      1 / 3,
    );

    await tester.enterText(passwordField, 'abcdefgh1');
    await tester.pump();
    expect(find.text('Kekuatan Password: Sedang'), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      2 / 3,
    );

    await tester.enterText(passwordField, 'Abcdef1!');
    await tester.pump();
    expect(find.text('Kekuatan Password: Kuat'), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      1,
    );
  });

  testWidgets('gender dropdown is required and saves the selected value', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    final genderDropdown = find.byKey(const ValueKey('genderField'));
    final dropdown = tester.widget<DropdownButtonFormField<String>>(
      genderDropdown,
    );
    expect(dropdown.validator!(null), 'Jenis kelamin wajib dipilih');

    await tester.tap(genderDropdown);
    await tester.pumpAndSettle();
    expect(find.text('Laki-laki'), findsOneWidget);
    expect(find.text('Perempuan'), findsOneWidget);

    await tester.tap(find.text('Perempuan').last);
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<DropdownButtonFormField<String>>(genderDropdown)
          .initialValue,
      'Perempuan',
    );
  });

  testWidgets('birth date field opens a picker and displays selected date', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    final birthDateField = tester.widget<TextField>(
      find.descendant(
        of: find.byKey(const ValueKey('birthDateField')),
        matching: find.byType(TextField),
      ),
    );
    expect(birthDateField.readOnly, isTrue);

    await tester.tap(find.byKey(const ValueKey('birthDateField')));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    final today = DateTime.now();
    final expectedDate =
        '${today.day.toString().padLeft(2, '0')}/'
        '${today.month.toString().padLeft(2, '0')}/'
        '${today.year}';
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('birthDateField')))
          .controller!
          .text,
      expectedDate,
    );
  });

  testWidgets('phone number validation enforces numeric 10 to 13 digits', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    final phoneField = tester.widget<TextFormField>(
      find.byType(TextFormField).at(2),
    );
    final validate = phoneField.validator!;

    expect(validate(null), isNotNull);
    expect(validate(''), isNotNull);
    expect(validate('123456789'), isNotNull);
    expect(validate('12345678901234'), isNotNull);
    expect(validate('12345abcde'), isNotNull);
    expect(validate('1234567890'), isNull);
    expect(validate('1234567890123'), isNull);
  });
}
