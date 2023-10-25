import 'package:flutter/material.dart';
import '../../theme/colors/light_colors.dart';

class SearchBarWidget extends StatefulWidget {
  final Function(String)? onSearch;

  SearchBarWidget({this.onSearch});

  @override
  _SearchBarWidgetState createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _searchController = TextEditingController();
  bool isSearchExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.menu, color: LightColors.kDarkBlue),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        Expanded(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: 40,
            width:
                isSearchExpanded ? MediaQuery.of(context).size.width - 100 : 0,
            margin: EdgeInsets.only(left: 10),
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search...",
                border: InputBorder.none,
              ),
              onSubmitted: (searchTerm) {
                if (widget.onSearch != null) {
                  widget.onSearch!(searchTerm);
                }
              },
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.search, color: LightColors.kDarkBlue),
          onPressed: () {
            setState(() {
              isSearchExpanded = !isSearchExpanded;
            });
          },
        ),
      ],
    );
  }
}
