import 'package:flutter/material.dart';
import 'package:quiz_app/screens/admin/ProfilePage.dart';

import '../../LogoutHelper.dart';

class StylishDrawer extends StatefulWidget {
  @override
  _StylishDrawerState createState() => _StylishDrawerState();
}

class _StylishDrawerState extends State<StylishDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1250));
    _scaleAnimation =
        Tween<double>(begin: 0.8, end: 1.0).animate(_animationController);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    Colors.deepOrange,
                    Colors.orangeAccent,
                  ],
                ),
              ),
              child: Container(
                child: Column(
                  children: <Widget>[
                    Material(
                      borderRadius: BorderRadius.all(Radius.circular(50.0)),
                      elevation: 10,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        // child: Image.asset('assets/path_to_your_logo.png', width: 80, height: 80),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('QuizApp',
                          style:
                              TextStyle(color: Colors.white, fontSize: 20.0)),
                    ),
                  ],
                ),
              ),
            ),
            CustomListTile(Icons.person, 'Profile', () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfilePage()));
            }),

            CustomListTile(Icons.notifications, 'Notification', () => {}),
            CustomListTile(Icons.settings, 'Settings', () => {}),
            CustomListTile(Icons.money, 'Payment', () => {}),
            CustomListTile(Icons.logout_rounded, 'Logout', () => LogoutHelper(context: context).logout()),
            // Add more list items as needed...
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class CustomListTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final Function onTap;

  CustomListTile(this.icon, this.text, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade400)),
        ),
        child: InkWell(
          splashColor: Colors.orangeAccent,
          onTap: () => onTap(),
          child: Container(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(icon),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(text, style: TextStyle(fontSize: 16.0)),
                    ),
                  ],
                ),
                Icon(Icons.arrow_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
