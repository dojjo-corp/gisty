import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/components/buttons/buttons.dart';
import 'package:gt_daily/authentication/components/buttons/custom_back_button.dart';
import 'package:gt_daily/authentication/components/page_title.dart';
import 'package:gt_daily/authentication/components/textfields/simple_textfield.dart';
import 'package:gt_daily/authentication/helper_methods.dart/global.dart';
import 'package:provider/provider.dart';

import '../../providers/projects_provider.dart';

class AddNewCategory extends StatefulWidget {
  const AddNewCategory({super.key});

  @override
  State<AddNewCategory> createState() => _AddNewCategoryState();
}

class _AddNewCategoryState extends State<AddNewCategory> {
  final _key = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final store = FirebaseFirestore.instance;
  Color chosenColor = Colors.blue;
  String chosenIcon = 'assets/category_icons/web-mobile-development.png';

  bool _isLoading = false;
  bool _chooseColor = false;
  bool _chooseIcon = false;

  @override
  Widget build(BuildContext context) {
    final iconList =
        Provider.of<ProjectProvider>(context, listen: false).iconList;

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
                    Form(
                      key: _key,
                      child: SimpleTextField(
                        controller: titleController,
                        hintText: 'Category Title',
                        iconData: Icons.title,
                        isWithIcon: true,
                        autofillHints: null,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // todo: CHOOSE COLOR
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
                        ? SizedBox(
                            height: 300,
                            child: Card(
                              child: GridView.count(
                                crossAxisCount: 4,
                                crossAxisSpacing: 25,
                                mainAxisSpacing: 15,
                                children: iconList
                                    .map(
                                      (icon) => GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            chosenIcon = icon;
                                          });
                                        },
                                        child: Image.asset(icon, height: 20),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          )
                        : Container(),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        // todo: ICON LISTTILE
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _chooseIcon = !_chooseIcon;
                                if (_chooseIcon) {
                                  _chooseColor = false;
                                } else {}
                              });
                            },
                            child: ListTile(
                              leading: CircleAvatar(
                                foregroundImage: AssetImage(chosenIcon),
                              ),
                              title: Text(
                                  _chooseIcon ? 'End Select' : 'Select Icon'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // todo: COLOR LISTTILE
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _chooseColor = !_chooseColor;
                                if (_chooseColor) {
                                  _chooseIcon = false;
                                } else {}
                              });
                            },
                            child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: chosenColor,
                                ),
                                title: Text(_chooseColor
                                    ? 'End Select'
                                    : 'Select Color')),
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

  void addNewCategory() async {
    if (_key.currentState!.validate()) {
      _key.currentState!.save;

      setState(() {
        _isLoading = true;
      });
      try {
        final collectionRef = store.collection('Project Cateogries');
        final snapshot = await collectionRef.get();

        final newCategoryData = {
          'color': chosenColor.value,
          'image': chosenIcon,
          'x': snapshot.size + 1,
        };

        // send to firestore
        collectionRef
            .doc(titleController.text.trim())
            .set(newCategoryData, SetOptions(merge: true));

        // update local categories
        if (mounted) {
          Provider.of<ProjectProvider>(context, listen: false).setCategories();
          showSnackBar(context, 'Category Added Successfully!');
          titleController.clear();
        }
      } catch (e) {
        showSnackBar(context, e.toString());
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
