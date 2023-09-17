import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProjectGridItem extends StatefulWidget {
  final String title, year, student, description, category;
  const ProjectGridItem({
    super.key,
    required this.title,
    required this.year,
    required this.student,
    required this.description,
    required this.category,
  });

  @override
  State<ProjectGridItem> createState() => _ProjectGridItemState();
}

class _ProjectGridItemState extends State<ProjectGridItem> {
  bool _isLiked = false;

  Color setProjectColor(String category) {
    switch (category.toLowerCase()) {
      case 'web':
        return const Color.fromARGB(255, 57, 134, 198);
      case 'mobile':
        return const Color.fromARGB(255, 234, 206, 64);
      case 'data':
        return const Color.fromARGB(255, 188, 137, 197);
        case 'hardware':
        return const Color.fromARGB(255, 6, 134, 4);
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectColor = setProjectColor(widget.category);
    final likedIcon = Icon(
      Icons.bookmark_added,
      color: projectColor,
    );
    const notLikedIcon = Icon(Icons.bookmark_add_outlined);
    return Container(
      constraints: const BoxConstraints(
        minWidth: 0,
        maxWidth: double.infinity,
      ),
      height: 180,
      padding: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
        gradient: LinearGradient(colors: [
          projectColor.withOpacity(0.1),
          projectColor.withOpacity(0.4)
        ]),
      ),
      child: Row(
        children: [
          VerticalDivider(
            thickness: 6,
            color: projectColor,
            width: 9,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Icon(Icons.portrait_rounded),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold, fontSize: 25, color: projectColor),
                    ),
                    Row(
                      children: [
                        Text(
                          widget.student,
                          style: GoogleFonts.montserrat(
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(widget.year,
                            style:
                                GoogleFonts.montserrat(color: Colors.grey[700]))
                      ],
                    ),
                    Text(
                      widget.description,
                      style: const TextStyle(
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 2,
                      softWrap: true,
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        print('Read more on project');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: projectColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(100, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Details'),
                    ),
                    IconButton(
                      onPressed: () async {
                        setState(() {
                          _isLiked = !_isLiked;
                        });
                      },
                      icon: _isLiked ? likedIcon : notLikedIcon,
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
