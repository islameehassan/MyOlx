import 'package:flutter/material.dart';
import 'package:myolx/Utilities/carAd.dart';
import 'package:myolx/Screens/AdScreen.dart';

class adListTile extends StatelessWidget {
  const adListTile({Key? key, required this.carAd}) : super(key: key);
  final CarAd carAd;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5.0,
            spreadRadius: 1.0,
            offset: Offset(0.0, 0.0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Image.asset('assets/images/logos/${carAd.Brand}.png'),
            title: Text(carAd.Brand!),
            subtitle: Text("${carAd.Model!}\n${carAd.Location} . ${carAd.CarYear}"),
            // place comma each three digits and EGP at the end
            trailing: Text(
              '${carAd.Price!.toString().replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                  (Match m) => '${m[1]},')} EGP',
            ),
          ),
          // add some features in bubbles and add them to a row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            child: Wrap(
              alignment: WrapAlignment.start,
              children: [
                // add a chip for each feature
                for (int i = 0; (i < 5 && i < carAd.Features!.length); i++)
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Chip(
                      label: Text(carAd.Features![i]),
                    ),
                  ),
              ],
            ),
          ),
          // go to the ad details screen
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdScreen(carAd: carAd),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward_ios),
              ),
            ],
          )
        ],
      ),
    );
  }
}