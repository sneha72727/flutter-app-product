// product_list_page.dart with improved light theme filter icon
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import 'add_edit_product_page.dart';
import '../widgets/product_card.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({Key? key}) : super(key: key);

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late Future<List<Product>> products;
  List<Product> allProducts = [];
  List<Product> filteredProducts = [];
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  String sortOption = 'price_asc';
  bool isDarkTheme = true;

  @override
  void initState() {
    super.initState();
    fetchAndFilterProducts();
  }

  void fetchAndFilterProducts() {
    products = ProductService.fetchProducts();
    products.then((productList) {
      setState(() {
        allProducts = productList;
        applyFilter();
      });
    });
  }

  void applyFilter() {
    final query = searchQuery.toLowerCase();
    setState(() {
      filteredProducts = allProducts.where((product) {
        return product.name.toLowerCase().contains(query) ||
            product.description.toLowerCase().contains(query);
      }).toList();

      if (sortOption == 'price_asc') {
        filteredProducts.sort((a, b) => a.price.compareTo(b.price));
      } else if (sortOption == 'price_desc') {
        filteredProducts.sort((a, b) => b.price.compareTo(a.price));
      }
    });
  }

  void refreshProducts() {
    fetchAndFilterProducts();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = isDarkTheme ? const Color(0xFF6A1B9A) : Colors.deepPurple.shade100;
    final Color secondaryColor = isDarkTheme ? const Color(0xFF8E24AA) : Colors.deepPurple.shade50;
    final Color bgColor = isDarkTheme ? const Color(0xFFE1BEE7) : Colors.white;
    final Color textColor = isDarkTheme ? Colors.white : Colors.black87;
    final Color hintColor = isDarkTheme ? Colors.white70 : Colors.black45;
    final Color iconColor = isDarkTheme ? Colors.amberAccent : Colors.black87;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, secondaryColor, bgColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                        "SHOPS00",
                          style: GoogleFonts.poppins(
                            color: Colors.amber,
                            fontSize: 12,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Welcome Back 👋",
                          style: GoogleFonts.poppins(
                            color: textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        isDarkTheme ? Icons.light_mode : Icons.dark_mode,
                        color: textColor,
                      ),
                      onPressed: () => setState(() => isDarkTheme = !isDarkTheme),
                      tooltip: 'Toggle Theme',
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          searchQuery = value;
                          applyFilter();
                        },
                        decoration: InputDecoration(
                          hintText: 'Search Products...',
                          hintStyle: TextStyle(color: hintColor),
                          prefixIcon: Icon(Icons.search, color: hintColor),
                          filled: true,
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(color: textColor),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: iconColor.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 1,
                          )
                        ],
                      ),
                      child: PopupMenuButton<String>(
                        color: Colors.white,
                        icon: Icon(Icons.sort, color: iconColor),
                        onSelected: (value) {
                          sortOption = value;
                          applyFilter();
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'price_asc',
                            child: Text('Price: Low to High', style: TextStyle(color: Colors.black)),
                          ),
                          PopupMenuItem(
                            value: 'price_desc',
                            child: Text('Price: High to Low', style: TextStyle(color: Colors.black)),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Product>>(
                  future: products,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      if (filteredProducts.isEmpty) {
                        return Center(
                          child: Text(
                            'No matching products found.',
                            style: TextStyle(color: hintColor),
                          ),
                        );
                      } else {
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            var product = filteredProducts[index];
                            return AnimatedScale(
                              duration: const Duration(milliseconds: 400),
                              scale: 1.0,
                              child: ProductCard(
                                product: product,
                                onEdit: () async {
                                  await Navigator.of(context).push(PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) => AddEditProductPage(product: product),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      return FadeTransition(opacity: animation, child: child);
                                    },
                                  ));
                                  refreshProducts();
                                },
                                onDelete: () async {
                                  await ProductService.deleteProduct(product.id);
                                  refreshProducts();
                                },
                              ),
                            );
                          },
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const AddEditProductPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ));
          refreshProducts();
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Product"),
        backgroundColor: Colors.deepPurpleAccent,
      ),
    );
  }
}
