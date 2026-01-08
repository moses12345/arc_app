import 'package:arc/model/news_letter_model.dart';
import 'package:arc/utils/HexColor.dart';
import 'package:arc/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class NewsLetterDetailScreen extends StatefulWidget {
  final NewsLetterData newsLetter;

  const NewsLetterDetailScreen({super.key, required this.newsLetter});

  @override
  State<NewsLetterDetailScreen> createState() => _NewsLetterDetailScreenState();
}

class _NewsLetterDetailScreenState extends State<NewsLetterDetailScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

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
    return Scaffold(
      //appBar: buildAppBar(context),
      appBar: AppBar(
          leading: IconButton(
            icon:  RotationTransition(
              turns: const AlwaysStoppedAnimation(180 / 360),
              child: Image.asset('assets/right_arrow.png', fit: BoxFit.cover, color: themeColor,),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        title: Text('News Letter',
            textAlign: TextAlign.center,
            style: TextStyle(color: HexColor('219653'), fontWeight: FontWeight.w600, fontSize: 18,))
      ),
      backgroundColor: Colors.white,
      //resizeToAvoidBottomInset: false,
      body: Padding(padding: const EdgeInsets.all(10), child: Column(
        children: [
          Container(
              margin: const EdgeInsets.only(bottom: 10),
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
              child: Text('${widget.newsLetter.newsLetter}',
                  textAlign: TextAlign.left,
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 14,))
          ),
          Expanded(
            child: SfPdfViewer.network(
              //'https://arc-staging-bucket.s3.amazonaws.com/newsletter/letter.pdf',
              '${widget.newsLetter.pdfLinks?[0]}',
              key: _pdfViewerKey,
            ),
          )
        ],
      ),)
    );
  }
}
