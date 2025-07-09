import 'package:flutter/material.dart';
import 'package:yam_guard/themes/colors.dart';

class YamInfoPage extends StatelessWidget {
  const YamInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary700,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          'Yam Info',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Image Placeholder ───
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  'Yam Info Image',
                  style: TextStyle(color: AppColors.primary700),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ─── Section Title ───
            const Text(
              'Yam Types in Southwestern Nigeria',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // ─── Yam Type Cards ───
            _yamCard(
              title: 'White Yam (Dioscorea rotundata)',
              localName: 'Ìṣù fúnfun',
              description:
                  'This is the most common yam type in Southwestern Nigeria. '
                  'It has smooth brown skin and white flesh.',
            ),
            _yamCard(
              title: 'Yellow Yam (Dioscorea cayenensis)',
              localName: 'Ìṣù púpa',
              description:
                  'Slightly sweeter with yellowish flesh. Popular for pounded yam or boiled yam.',
            ),
            _yamCard(
              title: 'Water Yam (Dioscorea alata)',
              localName: 'Ìṣù ẹwúrà',
              description:
                  'Very watery and spoils quickly; common during the rainy season and used for yam porridge (Àsáró).',
            ),
            _yamCard(
              title: 'Bitter Yam (Dioscorea dumetorum)',
              localName: 'Ìṣù kíkì',
              description:
                  'Not widely eaten unless detoxified; occasionally used in local medicine.',
            ),

            const SizedBox(height: 32),

            const Text(
              'Yam Storage Methods',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // ─── Storage Method Cards ───
            _storageCard(
              title: 'Barn Storage',
              type: 'Whole yam only',
              description:
                  'Yams are tied to vertical wooden racks for good airflow. Best in dry season.',
              note: 'Cover properly during heavy rains.',
            ),
            _storageCard(
              title: 'Pit Storage',
              type: 'Whole yam only',
              description:
                  'Shallow, dry pits lined with leaves or sand to maintain cool humidity.',
              note: 'Ensure good drainage to avoid rot.',
            ),
            _storageCard(
              title: 'Ash/Sawdust Storage',
              type: 'Cut or whole yam',
              description:
                  'Cut pieces are dried for 1–2 days, then stored in dry ash or sawdust. Also suitable for whole yam.',
              note: 'Store in indoor, airy place. Never store wet cut yam.',
            ),
            _storageCard(
              title: 'Ventilated Crate Storage',
              type: 'Whole yam only',
              description:
                  'Plastic or wooden crates with holes reduce bruising and allow airflow.',
              note: 'Prefer indoor use during the rainy season.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _yamCard({
    required String title,
    required String localName,
    required String description,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 6),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Local name: '),
                  TextSpan(
                    text: localName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(description),
          ],
        ),
      ),
    );
  }

  Widget _storageCard({
    required String title,
    required String type,
    required String description,
    required String note,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 6),
            Text('Storage Type: $type'),
            const SizedBox(height: 6),
            Text(description),
            const SizedBox(height: 6),
            Text(
              'Note: $note',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
