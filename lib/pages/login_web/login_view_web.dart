import 'package:fluffychat/pages/login_web/login_web.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';

import 'package:fluffychat/widgets/layouts/login_scaffold.dart';
import 'package:fluffychat/widgets/matrix.dart';

class LoginViewWeb extends StatelessWidget {
  final LoginController controller;

  const LoginViewWeb(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final homeserver = Matrix.of(context)
        .getLoginClient()
        .homeserver
        .toString()
        .replaceFirst('https://', '');
    final title = L10n.of(context)!.login;

    return LoginScaffold(
      enforceMobileMode: Matrix.of(context).client.isLogged(),
      appBar: AppBar(
        automaticallyImplyLeading: !controller.loading,
        titleSpacing: null,
        centerTitle: true,
        title: Text.rich(
          TextSpan(
            text: title,
          ),
          style: const TextStyle(fontSize: 18),
        ),
      ),
      body: Builder(
        builder: (context) {
          return Container(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: <Widget>[
                const SizedBox(height: 32),
                Image.asset('assets/banner_transparent.png'),
                const SizedBox(height: 100),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: controller.loading
                      ? const LinearProgressIndicator()
                      : null,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: controller.error != ''
                      ? Text(
                          controller.error,
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 16,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}

// class LoginWebView extends StatelessWidget {
//   const LoginWebView(this.controller, {super.key, String? credentialsUrl});

//   final LoginWebController controller;
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     final homeserver = Matrix.of(context)
//         .getLoginClient()
//         .homeserver
//         .toString()
//         .replaceFirst('https://', '');
//     final title = L10n.of(context)!.logInTo(homeserver);
//     final titleParts = title.split(homeserver);

//     return LoginScaffold(
//       enforceMobileMode: Matrix.of(context).client.isLogged(),
//       // appBar: AppBar(
//       //   // leading: const Center(child: BackButton()),
//       //   // automaticallyImplyLeading: !controller.loading,
//       //   titleSpacing: null,
//       //   title: Text.rich(
//       //     TextSpan(
//       //       children: [
//       //         TextSpan(text: titleParts.first),
//       //         TextSpan(
//       //           text: homeserver,
//       //           style: const TextStyle(fontWeight: FontWeight.bold),
//       //         ),
//       //         TextSpan(text: titleParts.last),
//       //       ],
//       //     ),
//       //     style: const TextStyle(fontSize: 18),
//       //   ),
//       // ),
//       body: Builder(
//         builder: (context) {
//           return Container(
//             child: ListView(
//               padding: const EdgeInsets.symmetric(horizontal: 8),
//               children: <Widget>[
//                 const SizedBox(height: 48),
//                 Image.asset('assets/banner_transparent.png'),
//                 const SizedBox(height: 100),
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 8.0),
//                   child: LinearProgressIndicator(),
//                 ),
//                 const SizedBox(height: 16),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
