import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/dimens.dart';

class CategorySlider extends StatefulWidget {
  final ValueChanged<String> onSelected;
  final ValueChanged<String> onDeSelected;
  final List<core.DeckCategory> categories;
  final selectedIds = Set<String>();

  CategorySlider(
      {@required this.categories,
      String selectedId,
      this.onSelected,
      this.onDeSelected}) {
    if (selectedId != null) {
      var id = categories.where((category) => category.id == selectedId);
      if (id.isNotEmpty) {
        selectedIds.add(id.first.id);
      }
    }
  }

  @override
  _CategorySliderState createState() => _CategorySliderState();
}

class _CategorySliderState extends State<CategorySlider> {
  final double w10 = wp(10);
  final double w15 = wp(15);
  final double w121 = wp(121);
  final double h30 = hp(30);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      primary: false,
      physics: ClampingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: w15),
      itemCount: widget.categories.length,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return categoryCard(
            widget.categories[index].id,
            widget.categories[index].name.toUpperCase(),
            Icons.sort_by_alpha,
            Color.fromARGB(255, 86, 204, 242),
            Color.fromARGB(255, 47, 128, 237),
            widget.selectedIds.contains(widget.categories[index].id),
          );
        } else if (index == 1) {
          return categoryCard(
            widget.categories[index].id,
            widget.categories[index].name.toUpperCase(),
            Icons.speaker_group,
            Color.fromARGB(255, 252, 207, 49),
            Color.fromARGB(255, 245, 85, 85),
            widget.selectedIds.contains(widget.categories[index].id),
          );
        } else {
          return categoryCard(
            widget.categories[index].id,
            widget.categories[index].name.toUpperCase(),
            Icons.library_books,
            Color.fromARGB(255, 121, 241, 164),
            Color.fromARGB(255, 14, 92, 173),
            widget.selectedIds.contains(widget.categories[index].id),
          );
        }
      },
      separatorBuilder: (BuildContext context, int index) {
        return SizedBox(width: w10);
      },
    );
  }

  Widget categoryCard(String id, String title, IconData icon, Color start,
      Color end, bool isSelected) {
    return GestureDetector(
      onTap: () => XError.f0(() {
        if (!widget.selectedIds.contains(id)) {
          setState(() {
            widget.selectedIds.clear();
            widget.selectedIds.add(id);
          });
          if (widget.onSelected != null) widget.onSelected(id);
        } else {
          setState(() {
            widget.selectedIds.remove(id);
          });
          if (widget.onDeSelected != null) widget.onDeSelected(id);
        }
      }),
      child: Container(
        width: w121,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          gradient: LinearGradient(
            colors: [start, end],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
          border: Border.all(
            color: isSelected ? XedColors.waterMelon : Colors.transparent,
            width: 2.5,
          ),
        ),
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.bottomRight,
              child: Icon(
                icon,
                size: h30 * 1.5,
                color: Color.fromARGB(51, 255, 255, 255),
              ),
            ),
            Center(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'HarmoniaSansProCyr',
                  fontWeight: FontWeight.w700,
                  fontSize: 12.0,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
