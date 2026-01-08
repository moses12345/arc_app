import 'package:arc/exercise_detail_screen.dart';
import 'package:arc/info_detail_screen.dart';
import 'package:arc/model/InfoLibModel.dart';
import 'package:arc/model/exercises_model.dart';
import 'package:arc/provider/exercises_provider.dart';
import 'package:arc/provider/info_lib_provider.dart';
import 'package:arc/utils/HexColor.dart';
import 'package:arc/utils/colors.dart';
import 'package:arc/widgets/refresh_load_more.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class LibScreen extends StatefulWidget {

  @override
  State<LibScreen> createState() => _LibScreenState();
}

class _LibScreenState extends State<LibScreen> {
  List<InfoLibData>? infoLibDataList;
  InfoLibProvider? provider;

  @override
  void initState() {
    super.initState();

    provider = Provider.of<InfoLibProvider>(context, listen: false);
    provider?.page = 1;
    provider?.infoLibDataList.clear();
    provider?.getInfoLib("infolib", context);
    provider?.setLoading(true);
  }

  @override
  Widget build(BuildContext context) {
    final mProvider = Provider.of<InfoLibProvider>(context);
    infoLibDataList = mProvider.infoLibDataList;
    return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: Container(padding: const EdgeInsets.only(top: 0, left: 10, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 10,),
                mProvider.isLoading ? Center(heightFactor:10, child: LoadingAnimationWidget.staggeredDotsWave(color: themeColor, size: 50,),) :
                Expanded(flex: 1, child: infoLibDataList?.isEmpty == true ? const Center(child: Text('No data available', textAlign: TextAlign.start, style: TextStyle(color: black, fontWeight: FontWeight.w400, fontSize: 14,),)): ListView.builder(
                  physics: const ClampingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: infoLibDataList?.length,
                  itemBuilder: (ctx, position) {
                    var data = infoLibDataList?[position];
                    return InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => InfoDetailScreen(infoDetail: data!, isInfo: true,)));
                        },
                        child: Container(
                          margin: const EdgeInsets.only(top: 5, bottom: 5),
                          padding: const EdgeInsets.all(12),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: HexColor('E4E2F3')),
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight, colors: [HexColor('F2F6FE'), HexColor('F2F6FE')],
                            ),
                          ),
                          child: Row(
                            children: [
                              Image.asset('assets/info_lib.png', width: 35, height: 35, color: themeColor,),
                              const SizedBox(width: 10,),
                              Expanded(flex: 9,child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${data?.name}', textAlign: TextAlign.start, style: TextStyle(color: HexColor('219653'), fontWeight: FontWeight.w600, fontSize: 18,), maxLines: 2,
                                    overflow: TextOverflow.ellipsis,),
                                  //exercise == null ? Text('${exercisesData.exerciseList?.length} Exercises', textAlign: TextAlign.start, style: Theme.of(context).textTheme.bodyMedium?.apply(color: HexColor('112950'), fontSizeDelta: 2),): Container(),
                                ],
                              ),),
                            ],
                          ),
                        )
                    );
                  },
                ))

              ],
            )
        ));
  }

  AppBar appBar({required BuildContext context, String? title}){
    return AppBar(
      centerTitle: false,
      elevation: 0,
      title: Text("$title", style: Theme.of(context).textTheme.titleMedium?.apply(color: HexColor('415473'), fontSizeDelta: 6)),
      leading: IconButton(
        icon: RotationTransition(
          turns: const AlwaysStoppedAnimation(180 / 360),
          child: Image.asset('assets/right_arrow.png', fit: BoxFit.cover, color: themeColor,),
        ),
        onPressed: () => {
          Navigator.pop(context)
        },
      ),
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
    );
  }
}