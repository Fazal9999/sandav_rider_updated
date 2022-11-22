import 'package:efood_multivendor_driver/helper/responsive_helper.dart';
import 'package:efood_multivendor_driver/util/dimensions.dart';
import 'package:efood_multivendor_driver/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaginatedListView extends StatefulWidget {
  final ScrollController scrollController;
  final Function(int offset) onPaginate;
  final int totalSize;
  final int offset;
  final Widget productView;
  final bool enabledPagination;
  const PaginatedListView({
    Key key,  this.scrollController,  this.onPaginate,  this.totalSize,
     this.offset,  this.productView, this.enabledPagination = true,
  }) : super(key: key);

  @override
  State<PaginatedListView> createState() => _PaginatedListViewState();
}

class _PaginatedListViewState extends State<PaginatedListView> {
  int _offset;
  List<int> _offsetList;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _offset = 1;
    _offsetList = [1];

    widget.scrollController?.addListener(() {
      if (widget.scrollController.position.pixels == widget.scrollController.position.maxScrollExtent
          && widget.totalSize != null && !_isLoading && widget.enabledPagination) {
        if(mounted && !ResponsiveHelper.isDesktop(context)) {
          _paginate();
        }
      }
    });
  }

  void _paginate() async {
    int pageSize = (widget.totalSize / 10).ceil();
    if (_offset < pageSize && !_offsetList.contains(_offset+1)) {

      setState(() {
        _offset = _offset + 1;
        _offsetList.add(_offset);
        _isLoading = true;
      });
      await widget.onPaginate(_offset);
      setState(() {
        _isLoading = false;
      });

    }else {
      if(_isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if(widget.offset != null) {
      _offset = widget.offset;
      _offsetList = [];
      for(int index=1; index<=widget.offset; index++) {
        _offsetList.add(index);
      }
    }

    return Column(children: [

      widget.productView,

      (ResponsiveHelper.isDesktop(context) && (widget.totalSize == null || _offset >= (widget.totalSize / 10).ceil() || _offsetList.contains(_offset+1))) ? SizedBox() : Center(child: Padding(
        padding: (_isLoading || ResponsiveHelper.isDesktop(context)) ? EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL) : EdgeInsets.zero,
        child: _isLoading ? CircularProgressIndicator() : (ResponsiveHelper.isDesktop(context) && widget.totalSize != null) ? InkWell(
          onTap: _paginate,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_SMALL, horizontal: Dimensions.PADDING_SIZE_LARGE),
            margin: ResponsiveHelper.isDesktop(context) ? EdgeInsets.only(top: Dimensions.PADDING_SIZE_SMALL) : null,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
              color: Theme.of(context).primaryColor,
            ),
            child: Text('view_more'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE, color: Colors.white)),
          ),
        ) : SizedBox(),
      )),

    ]);
  }
}
