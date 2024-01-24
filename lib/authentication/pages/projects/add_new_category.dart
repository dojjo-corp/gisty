import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/components/buttons/buttons.dart';
import 'package:gt_daily/authentication/components/buttons/custom_back_button.dart';
import 'package:gt_daily/authentication/components/page_title.dart';
import 'package:gt_daily/authentication/components/textfields/simple_textfield.dart';
import 'package:gt_daily/authentication/helper_methods.dart/global.dart';

class AddNewCategory extends StatefulWidget {
  const AddNewCategory({super.key});

  @override
  State<AddNewCategory> createState() => _AddNewCategoryState();
}

class _AddNewCategoryState extends State<AddNewCategory> {
  final titleController = TextEditingController();
  final store = FirebaseFirestore.instance;
  Color chosenColor = Colors.blue;
  String chosenIcon = "";
  bool _isLoading = false;
  bool _chooseColor = false;
  bool _chooseIcon = true;

  final iconList = [
    'ai.png',
    'cyber.png',
    'data.png',
    'data-science.png',
    'desktop.png',
    'digital-asset-management.png',
    'embedded-systems.png',
    'gear.png',
    'green-technology.png',
    'iot.png',
    'nanotechnology.png',
    'project-management.png',
    'research.png',
    'responsive.png',
    'robotics.png',
    'science.png',
    'technological.png',
    'technology.png',
    'web-mobile-development.png',
    'world-wide-web.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 100, right: 15, left: 15),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PageTitle(title: 'Add New Category'),
                    SimpleTextField(
                      controller: titleController,
                      hintText: 'Category Title',
                      iconData: Icons.title,
                      isWithIcon: true,
                      autofillHints: null,
                    ),
                    const SizedBox(height: 10),
                    _chooseColor
                        ? SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Card(
                                margin: EdgeInsets.zero,
                                child: ColorPicker(
                                  color: chosenColor,
                                  heading: Text(
                                    'Select Color',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 24,
                                    ),
                                  ),
                                  subheading: Text(
                                    'Select Color Shade',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18,
                                    ),
                                  ),
                                  actionButtons: const ColorPickerActionButtons(
                                    dialogActionIcons: true,
                                    dialogActionButtons: true,
                                  ),
                                  onColorChanged: (color) {
                                    setState(() {
                                      chosenColor = color;
                                    });
                                  },
                                ),
                              ),
                            ),
                          )
                        : Container(),

                    // todo: CHOOSE ICONS
                    _chooseIcon
                        ? Card(
                            child: GridView.count(
                              crossAxisCount: 5,
                              children: iconList
                                  .map((e) =>
                                      Image.asset('assets/category_icons/$e'))
                                  .toList(),
                            ),
                          )
                        : Container(),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: MyButton(
                            onPressed: () {
                              setState(() {
                                _chooseColor = !_chooseColor;
                              });
                            },
                            btnText: 'Choose Color',
                            isPrimary: false,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: MyButton(
                            onPressed: () {
                              setState(() {
                                _chooseIcon = !_chooseIcon;
                              });
                            },
                            btnText: 'Choose Icon',
                            isPrimary: false,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    MyButton(
                      onPressed: addNewCategory,
                      btnText: 'Add Category',
                      isPrimary: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const MyBackButton()
        ],
      ),
      floatingActionButton: _isLoading ? const LinearProgressIndicator() : null,
    );
  }

  void selectColor() {}

  void selectIcon() {}

  void addNewCategory() async {
    if (titleController.text.characters.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      try {
        final docRef = store.collection('All Projects').doc('Config');
        final snapshot = await docRef.get();

        if (snapshot.exists) {
          final newCategoryData = {
            titleController.text.trim(): {
              'color': Color,
              'image': '',
              'x': 0,
            }
          };

          // send to firestore
          docRef.update(newCategoryData);
        }
      } catch (e) {
        showSnackBar(context, e.toString());
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      showSnackBar(context, 'Category Title cannnot be empty');
    }
  }
}
