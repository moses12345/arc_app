import 'package:arc/exercise_detail_screen.dart';
import 'package:arc/provider/exercises_provider.dart';
import 'package:arc/utils/HexColor.dart';
import 'package:arc/utils/colors.dart';
import 'package:arc/utils/helper.dart';
import 'package:arc/exercise_category_screen.dart';
import 'package:arc/widgets/refresh_load_more.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'model/exercises_model.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  List<Data>? exercisesDataList;
  ExercisesProvider? provider;

  @override
  void initState() {
    super.initState();
    provider = Provider.of<ExercisesProvider>(context, listen: false);
    provider?.getExercises(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExercisesProvider>(context);
    exercisesDataList = provider.exercisesData;
    return SafeArea(child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: Container(padding: const EdgeInsets.only(top: 0, left: 10, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
           /*   Container(
                margin: const EdgeInsets.only(top: 5, bottom: 5),
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: HexColor('E4E2F3')),
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [boxColor, boxColor],
                  ),
                ),
                child: Text("Exercises",
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.apply(color: violet, fontSizeDelta: 2),
                ),
              ),*/
              const SizedBox(height: 10,),
              Flexible(flex: 1, child: RefreshLoadMore(
                  onRefresh:  () async {
                    provider.page = 1;
                    provider.getExercises(context);
                  },
                  onLoadmore: () async {
                    await Future.delayed(const Duration(seconds: 1), () {
                      provider.getExercises(context);
                    });
                  },
                  noMoreWidget: Text(
                    'No more data found',
                    style: Theme.of(context).textTheme.titleSmall?.apply(color: Colors.black87),
                  ),
                  isLastPage: provider.isLastPage,
                  child: ListView.builder(
                    physics: const ClampingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: exercisesDataList!.length,
                    itemBuilder: (ctx, position) {
                      var exercisesData = exercisesDataList?[position];
                      if(exercisesData?.type == "SUBCATEGORY") {
                        return listItem(exercisesData!, null);
                      } else if(exercisesData?.type  == "EXERCISES") {
                        return Column(
                          children: exercisesData!.exerciseList!.map<Widget>((exercise) {
                            return listItem(exercisesData, exercise);
                          }).toList(),
                        );
                        //return listItem();
                      }
                      return const SizedBox.shrink();
                    },
                  )
              ))

            ],
          )
        )));
  }

  Widget listItem(Data exercisesData, ExerciseData? exercise) {
    return InkWell(
        onTap: () {
          if(exercise != null) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ExerciseDetailScreen(exercisesData: exercise)));
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ExerciseCategoryScreen(exercisesData: exercisesData)));
          }
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
              Image.asset(exercise == null ? 'assets/folder.png' : 'assets/exercise.png', width: 25, height: 25, color: themeColor,),
              const SizedBox(width: 10,),
              Expanded(flex: 9,child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exercise == null ? '${exercisesData.categoryName}' : exercise.exerciseName!, textAlign: TextAlign.start, style: TextStyle(color: HexColor('219653'), fontWeight: FontWeight.w600, fontSize: 18,),),
                  exercise == null ? Text('${exercisesData.exerciseList?.length} Exercises', textAlign: TextAlign.start, style: TextStyle(color: HexColor('112950'), fontWeight: FontWeight.w600, fontSize: 14,),): Container(),
                ],
              ),),
            ],
          ),
        )
    );
  }
}