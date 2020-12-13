import 'package:ddi/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/resources.dart';
import 'package:the_flashcard/common/resources/xed_progress.dart';
import 'package:the_flashcard/common/xwidgets/x_state.dart';

import 'search_image_bloc/image_event.dart';
import 'search_image_bloc/image_list_bloc.dart';

class SearchImageScreen extends StatefulWidget {
  SearchImageScreen();

  @override
  _SearchImageScreenState createState() => _SearchImageScreenState();
}

class _SearchImageScreenState extends XState<SearchImageScreen> {
  ImageListBloc searchImageBloc = DI.get(ImageListBloc);
  RefreshController refreshController;
  TextEditingController textController;

  @override
  void initState() {
    super.initState();
    refreshController = RefreshController();
    textController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        titleSpacing: wp(10),
        elevation: 0,
        title: _searchText(context),
        actions: <Widget>[_cancelButton()],
      ),
      body: _builListImage(searchImageBloc, refreshController),
    );
  }

  @override
  void dispose() {
    textController?.dispose();
    refreshController?.dispose();
    super.dispose();
  }

  Widget _searchText(context) {
    return SizedBox(
      height: hp(36),
      child: TextField(
        autofocus: true,
        autocorrect: false,
        onSubmitted: _doSearch,
        onChanged: (value) {
          reRender();
        },
        controller: textController,
        textAlign: TextAlign.justify,
        decoration: _inputDecoration(context),
        cursorColor: XedColors.waterMelon,
      ),
    );
  }

  void _doSearch(String query) async {
    if (query.isNotEmpty) {
      searchImageBloc.add(QueryChanged(query: query));
    }
  }

  InputDecoration _inputDecoration(BuildContext context) {
    return InputDecoration(
      contentPadding: EdgeInsets.fromLTRB(wp(15), hp(10), wp(15), hp(7)),
      suffixIcon: Opacity(
        opacity: textController.text.isNotEmpty ? 1.0 : 0.2,
        child: IconButton(
          alignment: Alignment.center,
          icon: Container(
            height: 24,
            width: 24,
            alignment: Alignment.center,
            child: Center(
              child: Icon(Icons.close, color: XedColors.duckEggBlue, size: 14),
            ),
            decoration: BoxDecoration(
              color: XedColors.brownGrey,
              shape: BoxShape.circle,
            ),
          ),
          onPressed: () => XError.f0(() {
            textController.clear();
          }),
        ),
      ),
      hintStyle: RegularTextStyle(18),
      filled: true,
      fillColor: XedColors.duckEggBlue,
      enabledBorder: _outlineInputBorder(),
      focusedBorder: _outlineInputBorder(),
      border: _outlineInputBorder(),
      errorBorder: _outlineInputBorder(),
    );
  }

  OutlineInputBorder _outlineInputBorder() {
    return OutlineInputBorder(
      borderSide: BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.circular(hp(18)),
    );
  }

  Widget _builListImage(
      ImageListBloc bloc, RefreshController refreshController) {
    void _finishRefresh(RefreshController refreshController) {
      refreshController.isLoading
          ? refreshController.loadComplete()
          : refreshController.refreshCompleted();
    }

    return BlocListener(
      cubit: bloc,
      listener: (BuildContext context, ImageListState state) {
        if (state is! ImageListLoading) _finishRefresh(refreshController);
        if (state is ImageListError)
          showErrorSnakeBar(state.errorMessage, context: context);
      },
      child: BlocBuilder<ImageListBloc, ImageListState>(
        cubit: bloc,
        builder: (context, state) {
          return Stack(
            children: <Widget>[
              Container(
                child: SmartRefresher(
                  controller: refreshController,
                  enablePullDown: true,
                  enablePullUp: state.canLoadMore,
                  onRefresh: () => bloc.add(Refresh()),
                  onLoading: () => bloc.add(LoadMore()),
                  child: ListView.builder(
                    itemCount: state.images.length,
                    itemBuilder: (context, index) {
                      return _buildImageContainer(state.images[index].url);
                    },
                  ),
                ),
              ),
              state is ImageListLoading
                  ? Container(
                      child: Center(child: XedProgress.indicator()),
                      color: Colors.transparent,
                    )
                  : SizedBox()
            ],
          );
        },
      ),
    );
  }

  Widget _buildImageContainer(String url) {
    if (url == null || url.isEmpty) {
      return SizedBox();
    } else {
      return Container(
        padding: EdgeInsets.only(top: wp(15), left: wp(15), right: wp(15)),
        child: GestureDetector(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(hp(10)),
            child: Image.network(url),
          ),
          onTap: () => XError.f0(() {
            Navigator.of(context).pop(url);
          }),
        ),
      );
    }
  }

  Widget _cancelButton() {
    return InkWell(
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(left: wp(10), right: wp(15)),
        child: Text('Cancel', style: SemiBoldTextStyle(14)),
      ),
      onTap: () => XError.f0(() => Navigator.of(context).pop<String>(null)),
    );
  }
}
