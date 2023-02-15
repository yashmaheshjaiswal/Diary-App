import 'package:flutter/material.dart';
import 'package:my_diary/user/components/avatar/avatar.dart';
import 'package:my_diary/user/models/user.dart';
import 'package:provider/provider.dart';
import 'package:my_diary/generated/l10n.dart';

const logoutButtonKey = Key('logoutButton');

class ProfilePage extends StatelessWidget {
  final Avatar? avatar;

  const ProfilePage({super.key, this.avatar});

  logout(User user, BuildContext context) {
    Scaffold.of(context).closeDrawer();
    user.logout();
  }

  @override
  Widget build(BuildContext context) {
    User user = context.watch();
    final avatar = this.avatar ?? const Avatar();
    return Drawer(
        child: Column(
      children: [
        DrawerHeader(
            child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(height: 64, width: 64, child: avatar),
            const SizedBox(
              height: 10,
            ),
            Text(user.displayName,
                style: Theme.of(context).textTheme.headline6),
            const SizedBox(
              height: 5,
            ),
            Text(user.email)
          ],
        )),
        Expanded(
            child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          ElevatedButton(
              key: logoutButtonKey,
              onPressed: () => logout(user, context),
              child: Text(S.of(context).logout)),
          const SizedBox(
            height: 50,
          )
        ]))
      ],
    ));
  }
}
