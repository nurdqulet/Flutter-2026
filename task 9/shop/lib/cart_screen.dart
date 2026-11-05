import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: Consumer<Cart>(
        builder: (context, cart, _) => Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  for (final b in cart.items)
                    ListTile(
                      title: Text(b.title),
                      subtitle: Text('${b.price} ₸'),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => cart.remove(b),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Total: ${cart.total} ₸',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
