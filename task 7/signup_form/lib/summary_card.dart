import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String name;
  final String email;
  final String group;
  final String birthDate;

  const SummaryCard({
    super.key,
    required this.name,
    required this.email,
    required this.group,
    required this.birthDate,
  });

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      ListTile(
        leading: const Icon(Icons.person_outline),
        title: const Text('Name'),
        subtitle: Text(name),
      ),
      ListTile(
        leading: const Icon(Icons.email_outlined),
        title: const Text('Email'),
        subtitle: Text(email),
      ),
      ListTile(
        leading: const Icon(Icons.groups_outlined),
        title: const Text('Group'),
        subtitle: Text(group),
      ),
      ListTile(
        leading: const Icon(Icons.cake_outlined),
        title: const Text('Date of birth'),
        subtitle: Text(birthDate),
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= 600;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Registration complete!',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),

                const SizedBox(height: 16),

                if (isTablet)
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    children: tiles,
                  )
                else
                  Column(children: tiles),
              ],
            );
          },
        ),
      ),
    );
  }
}
