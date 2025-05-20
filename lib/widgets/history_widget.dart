import 'package:flutter/material.dart';
import 'package:yam_guard/themes/colors.dart';

class HistoryWidget extends StatelessWidget {
  const HistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 44),
      child: Container(
        padding: const EdgeInsets.only(bottom: 10.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: Color(0xB3BFBFBF), // #BFBFBF with 70% opacity
              width: 1.0,
            ),
          ),
        ),
        child: 
           Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "History",
                    style: TextStyle(
                      color: AppColors.secondary900,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(

                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xB3BFBFBF), // #BFBFBF with 70% opacity
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text('No history yet', style: TextStyle(
                          fontSize: 14.0, fontWeight: FontWeight.w500, color: AppColors.secondary900
                        ),)
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                 
                 
                ],
              ),
         
    )
    );
  }
}