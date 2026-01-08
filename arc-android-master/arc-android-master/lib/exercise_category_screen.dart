import 'package:arc/exercise_detail_screen.dart';
import 'package:arc/model/exercises_model.dart';
import 'package:arc/provider/exercises_provider.dart';
import 'package:arc/utils/HexColor.dart';
import 'package:arc/utils/colors.dart';
import 'package:arc/widgets/refresh_load_more.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExerciseCategoryScreen extends StatefulWidget {
  final Data exercisesData;
  const ExerciseCategoryScreen({super.key, required this.exercisesData});

  @override
  State<ExerciseCategoryScreen> createState() => _ExerciseCategoryScreenState();
}

class _ExerciseCategoryScreenState extends State<ExerciseCategoryScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: appBar(context: context, title: widget.exercisesData.categoryName),
        body: Container(padding: const EdgeInsets.only(top: 0, left: 10, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 10,),
                Expanded(flex: 1, child: ListView.builder(
                  physics: const ClampingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: widget.exercisesData.exerciseList!.length,
                  itemBuilder: (ctx, position) {
                    var exercisesData = widget.exercisesData.exerciseList?[position];
                    return InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ExerciseDetailScreen(exercisesData: exercisesData!)));
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
                              Image.asset('assets/exercise.png', width: 25, height: 25, color: themeColor,),
                              const SizedBox(width: 10,),
                              Expanded(flex: 9,child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${exercisesData?.exerciseName}', textAlign: TextAlign.start, style: TextStyle(color: HexColor('219653'), fontWeight: FontWeight.w600, fontSize: 18,),),
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