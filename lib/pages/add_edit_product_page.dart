// add_edit_product_page.dart
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class AddEditProductPage extends StatefulWidget {
  final Product? product;
  const AddEditProductPage({Key? key, this.product}) : super(key: key);

  @override
  State<AddEditProductPage> createState() => _AddEditProductPageState();
}

class _AddEditProductPageState extends State<AddEditProductPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _description;
  late double _price;
  late String _imageUrl;
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _name = widget.product?.name ?? '';
    _description = widget.product?.description ?? '';
    _price = widget.product?.price ?? 0.0;
    _imageUrl = widget.product?.imageUrl ?? '';

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final product = Product(
        id: widget.product?.id ?? '',
        name: _name,
        description: _description,
        price: _price,
        imageUrl:
            _imageUrl.isEmpty ? 'https://via.placeholder.com/150' : _imageUrl,
      );

      try {
        if (widget.product == null) {
          await ProductService.addProduct(product);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product added successfully')),
          );
        } else {
          await ProductService.updateProduct(widget.product!.id!, product);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product updated successfully')),
          );
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all_rounded),
            tooltip: 'Clear form',
            onPressed: () {
              setState(() {
                _name = '';
                _description = '';
                _price = 0.0;
                _imageUrl = '';
              });
            },
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeIn,
          child: Center(
            child: SingleChildScrollView(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.all(16),
                elevation: 12,
                color: Colors.deepPurple[700],
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          initialValue: _name,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Product Name',
                            labelStyle: TextStyle(color: Colors.white),
                            icon: Icon(Icons.label, color: Colors.white),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Enter product name' : null,
                          onSaved: (value) => _name = value!,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _description,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            labelStyle: TextStyle(color: Colors.white),
                            icon: Icon(Icons.description, color: Colors.white),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Enter description' : null,
                          onSaved: (value) => _description = value!,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue:
                              _price == 0.0 ? '' : _price.toStringAsFixed(2),
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Price',
                            labelStyle: TextStyle(color: Colors.white),
                            icon: Icon(Icons.attach_money, color: Colors.white),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) =>
                              value!.isEmpty ? 'Enter price' : null,
                          onSaved: (value) => _price = double.parse(value!),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _imageUrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Image URL',
                            labelStyle: TextStyle(color: Colors.white),
                            icon: Icon(Icons.image, color: Colors.white),
                          ),
                          onSaved: (value) => _imageUrl = value ?? '',
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.save_rounded, color: Colors.white),
                          label: Text(
                            widget.product == null
                                ? 'Add Product'
                                : 'Update Product',
                            style: const TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurpleAccent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 14),
                          ),
                          onPressed: _saveProduct,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}