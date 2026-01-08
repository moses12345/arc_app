library refresh_loadmore;

import 'package:arc/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RefreshLoadMore extends StatefulWidget {
  /// Callback function on pull down to refresh
  final Future<void> Function()? onRefresh;

  /// Callback function on pull up to load more data
  final Future<void> Function()? onLoadmore;

  /// Whether it is the last page, if it is true, you can not load more
  final bool isLastPage;

  /// Child widget
  final Widget child;

  /// Prompt text widget when there is no more data at the bottom
  final Widget? noMoreWidget;

  /// You can use your custom scrollController, or not
  final ScrollController? scrollController;

  const RefreshLoadMore({
    Key? key,
    required this.child,
    required this.isLastPage,
    this.onRefresh,
    this.onLoadmore,
    this.noMoreWidget,
    this.scrollController,
  }) : super(key: key);
  @override
  _RefreshLoadMoreState createState() => _RefreshLoadMoreState();
}

class _RefreshLoadMoreState extends State<RefreshLoadMore> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();

  ScrollController? _scrollController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController!.addListener(() async {
      if (_scrollController!.position.pixels >=
          _scrollController!.position.maxScrollExtent) {
        if (_isLoading) {
          return;
        }

        if (mounted) {
          setState(() {
            _isLoading = true;
          });
        }

        if (!widget.isLastPage && widget.onLoadmore != null) {
          await widget.onLoadmore!();
        }

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    if (widget.scrollController == null) _scrollController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget mainWidget = ListView(
      /// Solve the problem that there are too few items to pull down and refresh | 解决item太少，无法下拉刷新的问题
      physics: const AlwaysScrollableScrollPhysics(),
      controller: _scrollController,
      children: <Widget>[
        widget.child,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              child: _isLoading
                  ? const CupertinoActivityIndicator()
                  : widget.isLastPage
                  ? widget.noMoreWidget ??
                  Text(
                    'No more data',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).disabledColor,
                    ),
                  )
                  : Container(),
            ),
          ],
        )
      ],
    );

    if (widget.onRefresh == null) {
      return Scrollbar(child: mainWidget);
    }

    return RefreshIndicator(
      color: themeColor,
      backgroundColor: Colors.white,
      key: _refreshIndicatorKey,
      onRefresh: () async {
        if (_isLoading) return;
        await widget.onRefresh!();
      },
      child: mainWidget,
    );
  }
}