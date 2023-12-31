import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:optimum/models/user.model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserManager {
  final User _user = User.init();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  String _token = "";
  static final baseURL = Uri.parse('http://10.0.2.2:4000');

  UserManager() {
    _prefs.then((SharedPreferences prefs) {
      _token = prefs.getString('token') ?? '';
    });
  }

  setRole(String role) {
    _user.role = role;
  }

  setGender(String gender) {
    _user.gender = gender;
  }

  setDOB(DateTime dob) {
    _user.dob = dob;
  }

  setToken(String token) {
    _token = token;
    _prefs.then((SharedPreferences prefs) {
      prefs.setString('token', token);
    });
  }

  String get getToken => _token;

  bool get isLoggedIn => _token.isNotEmpty;

  String get getRole => _user.role!;

  String get getEmail => _user.email!;

  Future<http.Response> signIn(String email, String password) {
    final signInURI = baseURL.resolve("/api/auth/signin");
    return http.post(signInURI,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"email": email, "password": password}));
  }

  Future<http.Response> create(
      String name, String email, String password) async {
    _user.name = name;
    _user.email = email;

    final createURI = baseURL.resolve("/api/user");
    return http.post(createURI,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "role": _user.role,
        }));
  }

  Future<http.Response> verifyEmail(int code) {
    final createURI = baseURL.resolve("/api/auth/email/verify");
    return http.post(createURI,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"email": _user.email, "code": code}));
  }

  Future<http.Response> resendEmail() {
    final createURI = baseURL.resolve("/api/auth/email/resend");
    return http.post(createURI,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"email": _user.email}));
  }

  Future<http.Response> createPatient() {
    final createURI = baseURL.resolve("/api/patient/");
    return http.post(createURI,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': _token,
        },
        body: jsonEncode({
          "gender": _user.gender,
          "dob": _user.dob.toString(),
        }));
  }

  Future<http.StreamedResponse> createDoctor(
      int experience, Uint8List fileBytes, String fileName) {
    final createURI = baseURL.resolve("/api/doctor/");

    http.MultipartRequest request = http.MultipartRequest('POST', createURI);

    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
      'x-auth-token': _token,
    });

    request.files.add(http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: fileName,
    ));

    request.fields.addAll({
      'gender': _user.gender!,
      'experience': experience.toString(),
    });

    return request.send();
  }

  Future<http.Response> createDoctorLocation(String clinicName, String address,
      String city, String state, String zipCode) {
    final createURI = baseURL.resolve("/api/doctor/location");

    return http.post(createURI,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': _token,
        },
        body: jsonEncode({
          "clinicName": clinicName,
          "address": address,
          "city": city,
          "state": state,
          "zipCode": zipCode,
        }));
  }

  Future<http.Response> createDoctorCharges(var charges) {
    final createURI = baseURL.resolve("/api/doctor/charges");

    return http.post(createURI,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': _token,
        },
        body: jsonEncode(charges));
  }

  Future<http.Response> createDoctorSchedule(var schedule) {
    final createURI = baseURL.resolve("/api/doctor/schedule");

    return http.post(
      createURI,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': _token,
      },
      body: jsonEncode(schedule),
    );
  }
}

UserManager userManager = UserManager();
