import 'package:dress_app/models/product.dart';
import 'package:dress_app/models/order.dart';
import 'package:dress_app/models/user_profile.dart';
import 'package:dress_app/models/address.dart';
import 'package:dress_app/models/notification_item.dart';
import 'package:dress_app/models/chat_session.dart';
import 'package:dress_app/models/chat_message.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();

  factory MockDataService() {
    return _instance;
  }

  MockDataService._internal();

  static final UserProfile currentUser = UserProfile(
    id: 'u1',
    name: 'Aisha Sharma',
    email: 'aisha@example.com',
    phone: '+91 98 1234 5678',
    avatarUrl: '',
    isVendor: false,
    isVerified: true,
    reviewsCount: 84,
    rating: 4.8,
    addresses: [
      Address(
        id: 'a1',
        label: 'Home',
        fullName: 'Aisha Sharma',
        phone: '+91 98 1234 5678',
        street: '12, Sunshine Apartments, MG Road',
        city: 'Bengaluru',
        zipCode: '560001',
        isDefault: true,
      ),
      Address(
        id: 'a2',
        label: 'Office',
        fullName: 'Aisha Sharma',
        phone: '+91 98 1234 5678',
        street: '4th Floor, Cyber Towers, Hitec City',
        city: 'Hyderabad',
        zipCode: '500081',
        isDefault: false,
      ),
    ],
  );

  static final List<Product> mockProducts = [
    Product(
      id: 'p1',
      name: 'Black Sequin Evening Gown',
      category: 'Formal',
      rentalPricePerDay: 950.0,
      price: 950.0,
      originalPrice: 1200.0,
      description:
          'A floor-length black sequin gown with a plunging neckline and a side slit. Perfect for receptions and gala dinners. Lined inside; runs true to size.',
      images: [
        'https://images.unsplash.com/photo-1566174053879-31528523f8ae?q=80&w=800&auto=format&fit=crop',
      ],
      sizes: ['S', 'M', 'L', 'XL'],
      colors: ['Black', 'Midnight Blue'],
      rating: 4.8,
      reviewsCount: 124,
      storeName: 'The Wardrobe Co.',
      location: 'Bengaluru',
    ),
    Product(
      id: 'p2',
      name: 'Ivory Floral Anarkali',
      category: 'Ethnic',
      rentalPricePerDay: 650.0,
      price: 650.0,
      description:
          'Floor-length ivory anarkali with hand-block printed florals. Comes with a matching dupatta. Lightweight cotton-silk blend — ideal for daytime mehendi or sangeet.',
      images: [
        'https://images.unsplash.com/photo-1610030469983-98e550d6193c?q=80&w=800&auto=format&fit=crop',
      ],
      sizes: ['S', 'M', 'L', 'XL'],
      colors: ['Ivory', 'Dusty Pink'],
      rating: 4.9,
      reviewsCount: 86,
      storeName: 'Saroj & Co.',
      location: 'Mumbai',
    ),
    Product(
      id: 'p3',
      name: 'Crimson Bridal Lehenga',
      category: 'Bridal',
      rentalPricePerDay: 3500.0,
      price: 3500.0,
      originalPrice: 4800.0,
      description:
          'Hand-embroidered crimson bridal lehenga with gold zardozi work. Includes choli and 3m dupatta. Heirloom-quality craftsmanship.',
      images: [
        'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?q=80&w=800&auto=format&fit=crop',
      ],
      sizes: ['S', 'M', 'L'],
      colors: ['Crimson', 'Maroon'],
      rating: 5.0,
      reviewsCount: 42,
      storeName: 'Vermillion Bridal',
      location: 'Delhi NCR',
    ),
    Product(
      id: 'p4',
      name: 'Pastel Pink Saree',
      category: 'Ethnic',
      rentalPricePerDay: 480.0,
      price: 480.0,
      description:
          'Soft tissue silk saree in pastel pink with silver border. Pre-draped, falls elegantly. Perfect for haldi or day weddings.',
      images: [
        'https://images.unsplash.com/photo-1610030469983-98e550d6193c?q=80&w=800&auto=format&fit=crop',
      ],
      sizes: ['Free Size'],
      colors: ['Pastel Pink', 'Mint Green'],
      rating: 4.7,
      reviewsCount: 64,
      storeName: 'Loomcraft Studio',
      location: 'Jaipur',
    ),
    Product(
      id: 'p5',
      name: 'Indigo Denim Jacket',
      category: 'Casual',
      rentalPricePerDay: 220.0,
      price: 220.0,
      originalPrice: 350.0,
      description:
          'Vintage-wash oversized denim jacket with sherpa lining. Unisex fit. Pairs well with the slip dress below.',
      images: [
        'https://images.unsplash.com/photo-1551537482-f2075a1d41f2?q=80&w=800&auto=format&fit=crop',
      ],
      sizes: ['M', 'L', 'XL'],
      colors: ['Indigo', 'Washed Black'],
      rating: 4.5,
      reviewsCount: 38,
      storeName: 'Re/Done Rentals',
      location: 'Pune',
    ),
    Product(
      id: 'p6',
      name: 'Emerald Cocktail Dress',
      category: 'Party',
      rentalPricePerDay: 720.0,
      price: 720.0,
      description:
          'Short emerald cocktail dress with feathered hem. Made for late-night parties and engagement soirees.',
      images: [
        'https://images.unsplash.com/photo-1595777457583-95e059d581b8?q=80&w=800&auto=format&fit=crop',
      ],
      sizes: ['XS', 'S', 'M', 'L'],
      colors: ['Emerald', 'Black'],
      rating: 4.6,
      reviewsCount: 51,
      storeName: 'Glamroom',
      location: 'Mumbai',
    ),
  ];

  static final List<Order> mockOrders = [
    Order(
      id: '#ORD-9821',
      date: '18 Oct 2026',
      createdAt: DateTime(2026, 10, 18),
      itemsCount: 1,
      totalPrice: 415.00,
      status: OrderStatus.requested,
      imageUrl:
          'https://images.unsplash.com/photo-1566174053879-31528523f8ae?q=80&w=400&auto=format&fit=crop',
    ),
    Order(
      id: '#ORD-9820',
      date: '17 Oct 2026',
      createdAt: DateTime(2026, 10, 17),
      itemsCount: 1,
      totalPrice: 295.00,
      status: OrderStatus.preparing,
      imageUrl:
          'https://images.unsplash.com/photo-1610030469983-98e550d6193c?q=80&w=400&auto=format&fit=crop',
    ),
    Order(
      id: '#ORD-9815',
      date: '16 Oct 2026',
      createdAt: DateTime(2026, 10, 16),
      itemsCount: 1,
      totalPrice: 850.00,
      status: OrderStatus.outForDelivery,
      imageUrl:
          'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?q=80&w=400&auto=format&fit=crop',
    ),
    Order(
      id: '#ORD-9799',
      date: '10 Oct 2026',
      createdAt: DateTime(2026, 10, 10),
      itemsCount: 1,
      totalPrice: 150.00,
      status: OrderStatus.delivered,
      imageUrl:
          'https://images.unsplash.com/photo-1595777457583-95e059d581b8?q=80&w=400&auto=format&fit=crop',
    ),
    Order(
      id: '#ORD-9750',
      date: '5 Oct 2026',
      createdAt: DateTime(2026, 10, 5),
      itemsCount: 1,
      totalPrice: 350.00,
      status: OrderStatus.refunded,
      imageUrl:
          'https://images.unsplash.com/photo-1551537482-f2075a1d41f2?q=80&w=400&auto=format&fit=crop',
    ),
  ];

  static final List<NotificationItem> mockNotifications = [
    NotificationItem(
      id: 'n1',
      title: 'Order Delivered',
      description: 'Your order #ORD-9799 has been delivered successfully.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      timeText: '2h ago',
      type: NotificationType.order,
    ),
    NotificationItem(
      id: 'n2',
      title: 'Special Promo',
      description:
          'Get 20% off on all ethnic wear this weekend using code DRESS20.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      timeText: 'Yesterday',
      type: NotificationType.promo,
      isRead: true,
    ),
  ];

  static final List<ChatSession> mockChatSessions = [
    ChatSession(
      id: 'c1',
      peerName: 'Saroj & Co.',
      peerAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200&auto=format&fit=crop',
      lastMessage: 'Is the ivory anarkali still available for next weekend?',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
      unreadCount: 1,
      messages: [
        ChatMessage(id: 'm1', senderId: 'c1', text: 'Hi! I saw your listing.', timestamp: DateTime.now().subtract(const Duration(hours: 1))),
        ChatMessage(id: 'm2', senderId: 'c1', text: 'Is the ivory anarkali still available for next weekend?', timestamp: DateTime.now().subtract(const Duration(minutes: 5))),
      ],
    ),
    ChatSession(
      id: 'c2',
      peerName: 'Vermillion Bridal',
      peerAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=200&auto=format&fit=crop',
      lastMessage: 'The fit was perfect, thanks!',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
      unreadCount: 0,
    ),
  ];
}
