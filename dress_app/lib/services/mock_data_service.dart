import 'package:dress_app/models/product.dart';
import 'package:dress_app/models/order.dart';
import 'package:dress_app/models/user_profile.dart';
import 'package:dress_app/models/address.dart';
import 'package:dress_app/models/notification_item.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();

  factory MockDataService() {
    return _instance;
  }

  MockDataService._internal();

  static final UserProfile currentUser = UserProfile(
    id: 'u1',
    name: 'Arafat',
    email: 'arafat@example.com',
    phone: '+971 50 123 4567',
    avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=200&auto=format&fit=crop',
    isVendor: false,
    addresses: [
      Address(
        id: 'a1',
        label: 'Home',
        fullName: 'Arafat',
        phone: '+971 50 123 4567',
        street: '123 Marina Blvd',
        city: 'Dubai Marina',
        zipCode: '12345',
        isDefault: true,
      ),
      Address(
        id: 'a2',
        label: 'Office',
        fullName: 'Arafat',
        phone: '+971 50 123 4567',
        street: '456 Business Bay',
        city: 'Dubai',
        zipCode: '67890',
        isDefault: false,
      ),
    ],
  );

  static final List<Product> mockProducts = [
    Product(
      id: 'p1',
      name: 'Premium Hoodie',
      category: 'Streetwear',
      price: 295.0,
      originalPrice: 350.0,
      description: 'Classic streetwear premium hoodie made with 100% organic cotton. Perfect for evening outings.',
      images: [
        'https://images.unsplash.com/photo-1556821840-b9d3f4b4f001?q=80&w=600&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1556821840-3a63f95609a7?q=80&w=600&auto=format&fit=crop',
      ],
      sizes: ['S', 'M', 'L', 'XL'],
      colors: ['Black', 'Grey', 'Navy'],
      rating: 4.8,
      reviewsCount: 124,
      storeName: 'Street Style DXB',
      location: 'Dubai Marina',
    ),
    Product(
      id: 'p2',
      name: 'Elegant Evening Dress',
      category: 'Formal',
      price: 450.0,
      description: 'Stunning evening dress perfect for weddings and formal events. Features delicate lacework.',
      images: [
        'https://images.unsplash.com/photo-1566150905458-1bf1fc113f0d?q=80&w=600&auto=format&fit=crop',
      ],
      sizes: ['UK 6', 'UK 8', 'UK 10', 'UK 12'],
      colors: ['Red', 'Black', 'Emerald'],
      rating: 4.9,
      reviewsCount: 86,
      storeName: 'Luxury Rentals',
      location: 'Downtown Dubai',
    ),
    Product(
      id: 'p3',
      name: 'Casual Denim Jacket',
      category: 'Casual',
      price: 150.0,
      description: 'Vintage wash denim jacket. A versatile piece for your everyday wardrobe.',
      images: [
        'https://images.unsplash.com/photo-1576995853123-5a10305d93c0?q=80&w=600&auto=format&fit=crop',
      ],
      sizes: ['M', 'L', 'XL'],
      colors: ['Blue Denim', 'Black Denim'],
      rating: 4.5,
      reviewsCount: 42,
      storeName: 'Vintage Hub',
      location: 'Al Quoz',
    ),
    Product(
      id: 'p4',
      name: 'Designer Suit Set',
      category: 'Formal',
      price: 850.0,
      originalPrice: 1200.0,
      description: 'Complete 3-piece tailored suit set. Includes blazer, trousers, and waistcoat.',
      images: [
        'https://images.unsplash.com/photo-1594938298596-eb5fd5f5b468?q=80&w=600&auto=format&fit=crop',
      ],
      sizes: ['38R', '40R', '42R', '44R'],
      colors: ['Navy', 'Charcoal', 'Black'],
      rating: 5.0,
      reviewsCount: 210,
      storeName: 'The Suit Room',
      location: 'DIFC',
    ),
  ];

  static final List<Order> mockOrders = [
    Order(
      id: '#ORD-9821',
      date: '18 Oct 2026',
      itemsCount: 2,
      totalPrice: 415.00,
      status: OrderStatus.requested,
      imageUrl: 'https://images.unsplash.com/photo-1556821840-b9d3f4b4f001?q=80&w=200&auto=format&fit=crop',
    ),
    Order(
      id: '#ORD-9820',
      date: '17 Oct 2026',
      itemsCount: 1,
      totalPrice: 295.00,
      status: OrderStatus.preparing,
      imageUrl: 'https://images.unsplash.com/photo-1576995853123-5a10305d93c0?q=80&w=200&auto=format&fit=crop',
    ),
    Order(
      id: '#ORD-9815',
      date: '16 Oct 2026',
      itemsCount: 3,
      totalPrice: 850.00,
      status: OrderStatus.outForDelivery,
      imageUrl: 'https://images.unsplash.com/photo-1594938298596-eb5fd5f5b468?q=80&w=200&auto=format&fit=crop',
    ),
    Order(
      id: '#ORD-9799',
      date: '10 Oct 2026',
      itemsCount: 1,
      totalPrice: 150.00,
      status: OrderStatus.delivered,
      imageUrl: 'https://images.unsplash.com/photo-1566150905458-1bf1fc113f0d?q=80&w=200&auto=format&fit=crop',
    ),
    Order(
      id: '#ORD-9750',
      date: '5 Oct 2026',
      itemsCount: 1,
      totalPrice: 350.00,
      status: OrderStatus.refunded,
      imageUrl: 'https://images.unsplash.com/photo-1503341455253-b2e723bb3dbb?q=80&w=200&auto=format&fit=crop',
    ),
  ];

  static final List<NotificationItem> mockNotifications = [
    NotificationItem(
      id: 'n1',
      title: 'Order Delivered',
      description: 'Your order #ORD-9799 has been delivered successfully.',
      timeText: '10:45 AM',
      type: NotificationType.order,
    ),
    NotificationItem(
      id: 'n2',
      title: 'Special Promo',
      description: 'Get 20% off on all formal wear this weekend using code FORMAL20.',
      timeText: 'Yesterday',
      type: NotificationType.promo,
      isRead: true,
    ),
  ];
}
