import 'package:arc/utils/colors.dart';
import 'package:arc/widgets/herbal_screen.dart';
import 'package:arc/widgets/lib_screen.dart';
import 'package:arc/widgets/tab_item.dart';
import 'package:flutter/material.dart';

class InfoLibScreen extends StatefulWidget {
  const InfoLibScreen({super.key});

  @override
  State<InfoLibScreen> createState() => _InfoLibScreenState();
}

class _InfoLibScreenState extends State<InfoLibScreen> {


  @override
  void initState() {
    super.initState();
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          /*leading: IconButton(
            icon:  RotationTransition(
              turns: const AlwaysStoppedAnimation(180 / 360),
              child: Image.asset('assets/right_arrow.png', fit: BoxFit.cover, color: themeColor,),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),*/
         // title: const Text('Information Lib', textAlign: TextAlign.center, style: TextStyle(color: themeColor, fontWeight: FontWeight.w600, fontSize: 18,)),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(5),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: Container(
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  color: Colors.blue.shade100,
                ),
                child: const TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black54,
                  tabs: [
                    TabItem(title: 'Info Lib', count: 0),
                    TabItem(title: 'Herbal', count: 0),
                  ],
                ),
              ),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        //resizeToAvoidBottomInset: false,
        body: TabBarView(
          children: [
            LibScreen(),
            HerbalScreen(),
            //LibScreen()
          ],
        ),
      ),
    );
  }
}