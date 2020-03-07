import 'package:anad_magicar/translation_strings.dart';
import 'package:flutter/material.dart';


class MainPersistentTabBar extends StatelessWidget {

  Widget page1;
  Widget page2;
  List<Widget> actions;
  TabController tabController;
  MainPersistentTabBar({
    @required this.page1,
    @required this.page2,
    @required this.tabController,
    @required this.actions
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          actions: actions,
          bottom: TabBar(

            isScrollable: false,
            tabs: [
              Tab(
                icon: Icon(Icons.done_all),
                text: Translations.current.done(),
              ),
              Tab(icon: Icon(Icons.refresh), text: Translations.current.notDone()),

            ],
          ),
          title: Text(Translations.current.services()),
        ),
        body: TabBarView(
         // controller: tabController,
          physics: BouncingScrollPhysics(),
          children: [
            page1,
            page2
          ],
        ),
      ),
    );
  }


}
