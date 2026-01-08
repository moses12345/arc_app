import 'package:arc/model/news_letter_model.dart';
import 'package:arc/news_letter_detail_screen.dart';
import 'package:arc/provider/news_letter_provider.dart';
import 'package:arc/utils/HexColor.dart';
import 'package:arc/utils/colors.dart';
import 'package:arc/utils/enums.dart';
import 'package:arc/utils/helper.dart';
import 'package:arc/widgets/refresh_load_more.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class NewsLetterScreen extends StatefulWidget {
  const NewsLetterScreen({super.key});

  @override
  State<NewsLetterScreen> createState() => _NewsLetterScreenState();
}

class _NewsLetterScreenState extends State<NewsLetterScreen> {
  List<NewsLetterData>? newsLetterList;
  NewsLetterProvider? provider;

  @override
  void initState() {
    super.initState();
    provider = Provider.of<NewsLetterProvider>(context, listen: false);
    provider?.getNewsLetter(context);
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

  }

  @override
  Widget build(BuildContext context) {
    final mProvider = Provider.of<NewsLetterProvider>(context);
    newsLetterList = mProvider.newsLetterDataList;
    return Scaffold(
      //appBar: buildAppBar(context),
        /*appBar: AppBar(
          leading: IconButton(
            icon:  RotationTransition(
              turns: const AlwaysStoppedAnimation(180 / 360),
              child: Image.asset('assets/right_arrow.png', fit: BoxFit.cover, color: themeColor,),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('News Letter', textAlign: TextAlign.center, style: TextStyle(color: themeColor, fontWeight: FontWeight.w600, fontSize: 18,)),
        ),*/
        backgroundColor: Colors.white,
        //resizeToAvoidBottomInset: false,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            mProvider.isLoading ? Center(heightFactor:10, child: LoadingAnimationWidget.staggeredDotsWave(color: themeColor, size: 50,),) :
            Expanded(flex: 1, child: RefreshLoadMore(
                onRefresh: () async {
                  provider?.page = 1;
                  provider?.getNewsLetter(context);
                },
                onLoadmore: () async {
                  await Future.delayed(const Duration(seconds: 1), () {
                    provider?.getNewsLetter(context);
                  });
                },
                noMoreWidget: Text(
                  '',
                  style: Theme.of(context).textTheme.titleSmall?.apply(color: Colors.black87),
                ),
                isLastPage: mProvider.isLastPage,
                child: newsLetterList?.isEmpty == true ? Container(margin: const EdgeInsets.only(top: 50), child: Text('No data found', textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.apply(color: Colors.black87),
                )) : ListView.builder(
                  physics: const ClampingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: newsLetterList!.length,
                  itemBuilder: (ctx, position) {
                    var newsLetter = newsLetterList?[position];
                    return InkWell(
                        onTap: () {
                          if(newsLetter?.pdfLinks?.isEmpty == true) {
                            Helper.showSnackBar(context: context, message: "PDF not found", status: Status.error);
                          } else {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => NewsLetterDetailScreen(newsLetter: newsLetter!)));
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(top: 5, bottom: 5, left: 20, right: 20),
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${newsLetter?.newsLetter}',
                                textAlign: TextAlign.start,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: HexColor('219653'), fontWeight: FontWeight.w600, fontSize: 18,)),
                              const SizedBox(height: 5,),
                              HtmlWidget("${newsLetter?.description}"),
                            ],
                          ),
                        )
                    );
                  },
                )
            ))
          ],
        ));
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
                    Text("ARC", style: Theme.of(context).textTheme.headlineMedium?.apply(color: Colors.white),),
                    Text('Acupunture & Physical Therepy Specialists Inc', style: Theme.of(context).textTheme.titleSmall?.apply(color: Colors.white),),
                  ],
                ),
                //IconButton(onPressed: () {}, icon: Icon(Icons.g_translate, size: 25,), iconSize: 25,),
              ],
            ),
          ]
      ),
      automaticallyImplyLeading: false,
      backgroundColor: themeColor,
    );
  }
}