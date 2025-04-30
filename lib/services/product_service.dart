import '../models/product.dart';
import 'api_service.dart';

class ProductService {
  static Future<List<Product>> fetchProducts() => ApiService.fetchProducts();
  static Future<void> addProduct(Product product) => ApiService.addProduct(product);
  static Future<void> updateProduct(String id, Product product) => ApiService.updateProduct(id, product);
  static Future<void> deleteProduct(String id) => ApiService.deleteProduct(id);
}

