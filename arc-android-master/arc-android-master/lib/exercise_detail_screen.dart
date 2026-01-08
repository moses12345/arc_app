import 'package:arc/model/exercises_model.dart';
import 'package:arc/utils/HexColor.dart';
import 'package:arc/utils/colors.dart';
import 'package:arc/utils/image_viewer.dart';
import 'package:arc/widgets/VideoListItem.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final ExerciseData exercisesData;

  const ExerciseDetailScreen({super.key, required this.exercisesData});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen>  with SingleTickerProviderStateMixin{
  late final List<Widget> imageSliders;
  late CarouselSliderController outerCarouselController;
  int outerCurrentPage = 0;

  @override
  void initState() {
    super.initState();
    outerCarouselController = CarouselSliderController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Widget _outerBannerSlider() {
    return Column(
      children: [
        CarouselSlider(
          carouselController: outerCarouselController,

          /// It's options
          options: CarouselOptions(
            autoPlay: true,
            enlargeCenterPage: true,
            enableInfiniteScroll: true,
            aspectRatio: 16 / 8,
            viewportFraction: .95,
            onPageChanged: (index, reason) {
              setState(() {
                outerCurrentPage = index;
              });
            },
          ),

          /// Items
          items: widget.exercisesData.imageLink?.map((imagePath) {
            return Builder(
              builder: (BuildContext context) {
                /// Custom Image Viewer widget
                return CustomImageViewer.show(
                    context: context,
                    url: imagePath,
                    fit: BoxFit.fill,
                    radius: 8);
              },
            );
          }).toList(),
        ),
        const SizedBox(
          height: 10,
        ),

        /// Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.exercisesData.imageLink!.length, (index) {
              bool isSelected = outerCurrentPage == index;
              return GestureDetector(
                onTap: () {
                  outerCarouselController.animateToPage(index);
                },
                child: AnimatedContainer(
                  width: isSelected ? 30 : 10,
                  height: 10,
                  margin: EdgeInsets.symmetric(horizontal: isSelected ? 6 : 3),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.deepPurpleAccent
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(
                      40,
                    ),
                  ),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("as ${widget.exercisesData.exerciseSteps?.length}");
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon:  RotationTransition(
            turns: const AlwaysStoppedAnimation(180 / 360),
            child: Image.asset('assets/right_arrow.png', fit: BoxFit.cover, color: themeColor,),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        /*title: Text('Exercise-${widget.exercisesData.exerciseName}',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.apply(color: themeColor, fontSizeDelta: 8)),*/
      ),
      backgroundColor: Colors.white,
      //resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _outerBannerSlider(),
            Container(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10,),
                  Text('Exercise:', textAlign: TextAlign.start, style: Theme.of(context).textTheme.titleMedium?.apply(color: Colors.black, fontSizeDelta: 4),),
                  Text('${widget.exercisesData.exerciseName}', textAlign: TextAlign.start, style: Theme.of(context).textTheme.bodySmall?.apply(color: greyColorLabel, fontSizeDelta: 2),),
                  const SizedBox(height: 10,),
                  Text('Description:', textAlign: TextAlign.start, style: Theme.of(context).textTheme.titleMedium?.apply(color: Colors.black, fontSizeDelta: 4),),
                  Text('${widget.exercisesData.description}', textAlign: TextAlign.start, style: Theme.of(context).textTheme.bodySmall?.apply(color: greyColorLabel, fontSizeDelta: 2),),
                  const SizedBox(height: 10,),
                  Text('Exercise Time:', textAlign: TextAlign.start, style: Theme.of(context).textTheme.titleMedium?.apply(color: Colors.black, fontSizeDelta: 4),),
                  Text(
                    widget.exercisesData.exerciseTime != null
                        ? '${widget.exercisesData.exerciseTime} Minute'
                        : '',
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.bodySmall?.apply(
                      color: greyColorLabel,
                      fontSizeDelta: 2,
                    ),
                  ),
                  const SizedBox(height: 10,),
                  if (widget.exercisesData.exerciseSteps != null && widget.exercisesData.exerciseSteps!.isNotEmpty)
                    Text('Exercises Steps:', textAlign: TextAlign.start, style: Theme.of(context).textTheme.titleMedium?.apply(color: Colors.black, fontSizeDelta: 4),),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.exercisesData.exerciseSteps?.length,
                      itemBuilder: (context, index) {
                        var exercisesStep  = widget.exercisesData.exerciseSteps?[index];
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
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
                              child: Column(
                                children: [
                                  Text("${exercisesStep?.description}",
                                    textAlign: TextAlign.start,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.apply(color: violet, fontSizeDelta: 2),
                                  ),
                                  const SizedBox(height: 10,),
                                  exercisesStep?.stepImage?.isNotEmpty == true ? ClipRRect(
                                    borderRadius: BorderRadius.circular(20), // Adjust the radius as needed
                                    child: Image.network(
                                      exercisesStep!.stepImage!,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child; // Return the image when fully loaded
                                        }
                                        return CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                              : null,
                                        ); // Show a progress indicator while loading
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Text('Failed to load image'); // Show an error message if loading fails
                                      },
                                    ),
                                  ): Container(),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  if (widget.exercisesData.videoLink != null && widget.exercisesData.videoLink!.isNotEmpty)
                    Text('Exercise Videos:', textAlign: TextAlign.start, style: Theme.of(context).textTheme.titleMedium?.apply(color: Colors.black, fontSizeDelta: 4),),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.exercisesData.videoLink?.length,
                      itemBuilder: (context, index) {
                        return VideoListItem(videoUrl: widget.exercisesData.videoLink![index]);
                      },
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 80,
      centerTitle: false,
      elevation: 0,
      title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ARC",
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.apply(color: Colors.white),
                    ),
                    Text(
                      'Acupunture & Physical Therepy Specialists Inc',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.apply(color: Colors.white),
                    ),
                  ],
                ),
                //IconButton(onPressed: () {}, icon: Icon(Icons.g_translate, size: 25,), iconSize: 25,),
              ],
            ),
          ]),
      automaticallyImplyLeading: false,
      backgroundColor: themeColor,
    );
  }
}
