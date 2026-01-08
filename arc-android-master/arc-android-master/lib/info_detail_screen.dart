import 'package:arc/model/exercises_model.dart';
import 'package:arc/utils/HexColor.dart';
import 'package:arc/utils/colors.dart';
import 'package:arc/utils/image_viewer.dart';
import 'package:arc/widgets/VideoListItem.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import 'model/InfoLibModel.dart';

class InfoDetailScreen extends StatefulWidget {
  final InfoLibData infoDetail;
  final bool isInfo;

  const InfoDetailScreen({super.key, required this.infoDetail, required this.isInfo});

  @override
  State<InfoDetailScreen> createState() => _InfoDetailScreenState();
}

class _InfoDetailScreenState extends State<InfoDetailScreen>  with SingleTickerProviderStateMixin{
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
    var steps = widget.infoDetail.steps?.where((s) => s.stepImage != null && s.stepImage!.trim().isNotEmpty).toList();

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
          items: steps?.map((imagePath) {
            return Builder(
              builder: (BuildContext context) {
                /// Custom Image Viewer widget
                return CustomImageViewer.show(
                    context: context,
                    url: imagePath.stepImage!,
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
            steps!.length, (index) {
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
                  Text('Title:', textAlign: TextAlign.start, style: Theme.of(context).textTheme.titleMedium?.apply(color: Colors.black, fontSizeDelta: 4),),
                  Text('${widget.infoDetail.name}', textAlign: TextAlign.start, style: Theme.of(context).textTheme.bodySmall?.apply(color: greyColorLabel, fontSizeDelta: 2),),
                  const SizedBox(height: 10,),
                  Text('Description:', textAlign: TextAlign.start, style: Theme.of(context).textTheme.titleMedium?.apply(color: Colors.black, fontSizeDelta: 4),),
                  Text('${widget.infoDetail.description}', textAlign: TextAlign.start, style: Theme.of(context).textTheme.bodySmall?.apply(color: greyColorLabel, fontSizeDelta: 2),),
                  const SizedBox(height: 10,),
                  Text(widget.isInfo ? 'Freq. & Repetition:': 'Usage Instructions:', textAlign: TextAlign.start, style: Theme.of(context).textTheme.titleMedium?.apply(color: Colors.black, fontSizeDelta: 4),),
                  Text('${widget.infoDetail.metaData}', textAlign: TextAlign.start, style: Theme.of(context).textTheme.bodySmall?.apply(color: greyColorLabel, fontSizeDelta: 2),),
                  const SizedBox(height: 10,),
                  Text('Steps:', textAlign: TextAlign.start, style: Theme.of(context).textTheme.titleMedium?.apply(color: Colors.black, fontSizeDelta: 4),),
                  if (widget.infoDetail.steps != null && widget.infoDetail.steps!.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.infoDetail.steps?.length,
                      itemBuilder: (context, index) {
                        var exercisesStep  = widget.infoDetail.steps?[index];
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
                  if (widget.infoDetail.videoLink != null && widget.infoDetail.videoLink!.isNotEmpty)
                    Text('Exercise Videos:', textAlign: TextAlign.start, style: Theme.of(context).textTheme.titleMedium?.apply(color: Colors.black, fontSizeDelta: 4),),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.infoDetail.videoLink?.length,
                      itemBuilder: (context, index) {
                        return VideoListItem(videoUrl: widget.infoDetail.videoLink![index]);
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
