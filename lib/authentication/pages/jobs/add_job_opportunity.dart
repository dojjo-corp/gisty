import 'package:flutter/material.dart';

class AddJobOrInternship extends StatelessWidget {
  const AddJobOrInternship({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Padding(
          padding: const EdgeInsets.only(
              top: 100.0, left: 15, right: 115, bottom: 15),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  
                ],
              )
            ),
          ),
        ),
        
      ]),
    );
  }
}
