import 'dart:async';

import 'package:flutter/material.dart';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:matrix/matrix.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:fluffychat/utils/localized_exception_extension.dart';
import 'package:fluffychat/widgets/matrix.dart';
import '../../utils/platform_infos.dart';
import 'login_view_web.dart';

class LoginWeb extends StatefulWidget {
  final dynamic credentialsUrl;

  const LoginWeb({super.key, this.credentialsUrl});

  @override
  LoginController createState() => LoginController();
}

class LoginController extends State<LoginWeb> {
  bool loading = false;
  bool showPassword = false;
  bool isEmpty = false;
  String error = '';

  @override
  void initState() {
    super.initState();
    if (widget.credentialsUrl != null && widget.credentialsUrl?.hasScheme) {
      _processCredentials(widget.credentialsUrl!);
    } else {
      error = 'Invalid login link';
    }
  }

  Future<void> _processCredentials(Uri credentialsUrl) async {
    setState(() => loading = true);
    final matrix = Matrix.of(context);
    try {
      final response = await http.get(credentialsUrl);
      if (response.statusCode == 200) {
        Logs().d('SYNC OFF');
        matrix.client.backgroundSync = false;
        final credentialsData = jsonDecode(response.body);
        if (matrix.client.isLogged()) {
          final loggedOut = await _logoutAction();
          if (loggedOut) {
            await _autoLoginWithCredentials(credentialsData);
          }
        } else {
          await _autoLoginWithCredentials(credentialsData);
        }
      } else {
        throw Exception('Invalid credentials');
      }
    } catch (e) {
      Logs().d('SYNC ON');
      matrix.client.backgroundSync = true;
      Logs().i(e.toString());
      setState(() => error = e.toString());
      setState(() => loading = false);
    }
  }

  Future<void> _autoLoginWithCredentials(
      Map<String, dynamic> credentialsData) async {
    try {
      final matrix = Matrix.of(context);
      final username = credentialsData['username'].toString();
      final password = credentialsData['password'].toString();
      final address = credentialsData['address'];

      AuthenticationIdentifier identifier;
      if (username.isEmail) {
        identifier = AuthenticationThirdPartyIdentifier(
          medium: 'email',
          address: username,
        );
      } else if (username.isPhoneNumber) {
        identifier = AuthenticationThirdPartyIdentifier(
          medium: 'msisdn',
          address: username,
        );
      } else {
        identifier = AuthenticationUserIdentifier(user: username);
      }

      final client = matrix.getLoginClient();
      try {
        var homeserver = Uri.parse(address.toString());
        if (homeserver.scheme.isEmpty) {
          homeserver = Uri.https(homeserver.toString(), '');
        }
        client.homeserver = homeserver;
      } catch (e) {
        setState(() => error = e.toString());
        setState(() => loading = false);
      }

      await client.login(
        LoginType.mLoginPassword,
        identifier: identifier,
        password: password,
        initialDeviceDisplayName: PlatformInfos.clientName,
      );
      Logs().d('SYNC ON');
      matrix.client.backgroundSync = true;
    } on MatrixException catch (exception) {
      setState(() => error = exception.errorMessage);
      return setState(() => loading = false);
    } catch (exception) {
      setState(() => error = exception.toString());
      return setState(() => loading = false);
    }
  }

  Future<bool> _logoutAction() async {
    final matrix = Matrix.of(context);
    try {
      await matrix.client.logout();
      return true;
    } catch (exception) {
      setState(() => error = exception.toString());
      setState(() => loading = false);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) => LoginViewWeb(this);
}

extension on String {
  static final RegExp _phoneRegex =
      RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$');
  static final RegExp _emailRegex = RegExp(r'(.+)@(.+)\.(.+)');

  bool get isEmail => _emailRegex.hasMatch(this);

  bool get isPhoneNumber => _phoneRegex.hasMatch(this);
}
