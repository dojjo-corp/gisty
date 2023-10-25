// ignore_for_file: empty_catches

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/components/buttons/custom_back_button.dart';
import 'package:gt_daily/authentication/components/loading_circle.dart';
import 'package:gt_daily/authentication/components/page_title.dart';
import 'package:gt_daily/authentication/components/ListTiles/user_tile.dart';
import 'package:gt_daily/authentication/helper_methods.dart/global.dart';

import '../../repository/firestore_repo.dart';

class UserListPage extends StatefulWidget {
  final String role;
  const UserListPage({super.key, required this.role});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  late List<Map<String, dynamic>>? allUsers;
  bool _dataLoaded = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    getAllUsers().then((value) {
      allUsers = value;
      if (context.mounted) {
        setState(() {
          _dataLoaded = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return !_dataLoaded
        ? const LoadingCircle()
        : Scaffold(
            body: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 100,
                    left: 15,
                    right: 15,
                    bottom: 10,
                  ),
                  child: SingleChildScrollView(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PageTitle(title: '${widget.role.toUpperCase()}S'),
                          Column(
                            children: getUserListTiles(),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const MyBackButton()
              ],
            ),
            floatingActionButton:
                _isLoading ? const LinearProgressIndicator() : null,
          );
  }

  Future<List<Map<String, dynamic>>?> getAllUsers() async {
    try {
      // firestore snapshot
      final snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      final List<Map<String, dynamic>> userList = [];

      for (var doc in snapshot.docs) {
        userList.add(doc.data());
      }
      return userList;
    } catch (e) {
      return null;
    }
  }

  List<Widget> getUserListTiles() => allUsers!
      .where((data) => data['user-type'].toLowerCase() == widget.role)
      .toList()
      .map(
        (userData) => UserTile(
          userData: userData,
          onDeleteButtonPressed: () async {
            try {
              setState(() {
                _isLoading = true;
              });
              await FirestoreRepo().deleteUserRecords(
                uid: userData['uid'],
                email: userData['email'],
              );
              if (context.mounted) {
                setState(() {});
                showSnackBar(context, 'Success!');
              }
            } catch (e) {
              setState(() {
                _isLoading = false;
              });

              showSnackBar(
                context,
                e.toString(),
              );
            } finally {
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
      )
      .toList();
}
