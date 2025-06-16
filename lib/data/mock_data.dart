class MockListing {
  final String id;
  final String title;
  final String location;
  final String imageUrl;
  final double price;
  final double rating;
  final int reviewCount;
  final double latitude;
  final double longitude;
  final List<String> images;
  final String description;
  final String host;
  final List<String> amenities;
  final String category; // 'event' or 'restaurant'
  final String duration; // For events: duration, For restaurants: dining time

  MockListing({
    required this.id,
    required this.title,
    required this.location,
    required this.imageUrl,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.latitude,
    required this.longitude,
    required this.images,
    required this.description,
    required this.host,
    required this.amenities,
    required this.category,
    required this.duration,
  });
}

class MockReview {
  final String id;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final DateTime date;

  MockReview({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

class MockData {
  static List<MockListing> get listings => [
        // Events
        MockListing(
          id: '1',
          title: 'Traditional Gnawa Music Concert',
          location: 'Hassan II Mosque Cultural Center',
          imageUrl: 'assets/images/casablanca.jpg',
          price: 250.0, // MAD
          rating: 4.9,
          reviewCount: 156,
          latitude: 33.6084,
          longitude: -7.6326,
          images: [
            'assets/images/casablanca.jpg',
            'assets/images/casablanca.jpg',
            'assets/images/casablanca.jpg',
          ],
          description:
              'Experience the mystical sounds of traditional Gnawa music in an intimate concert setting. This authentic performance features master musicians from Essaouira.',
          host: 'Casa Cultural Events',
          amenities: [
            'Live Music',
            'Traditional Instruments',
            'Cultural Experience',
            'Photography Allowed'
          ],
          category: 'music',
          duration: '2 hours',
        ),
        MockListing(
          id: '2',
          title: 'Moroccan Cooking Workshop',
          location: 'Habous Quarter',
          imageUrl: 'assets/images/casablanca.jpg',
          price: 450.0, // MAD
          rating: 4.8,
          reviewCount: 89,
          latitude: 33.5731,
          longitude: -7.6298,
          images: [
            'assets/images/casablanca.jpg',
            'assets/images/casablanca.jpg'
          ],
          description:
              'Learn to prepare authentic Moroccan dishes including tagine, couscous, and pastries with a local chef in a traditional kitchen setting.',
          host: 'Chef Aicha Benali',
          amenities: [
            'Hands-on Cooking',
            'Recipe Cards',
            'Full Meal Included',
            'Market Tour'
          ],
          category: 'cooking',
          duration: '4 hours',
        ),
        MockListing(
          id: '3',
          title: 'Art Gallery Opening Night',
          location: 'Maarif District',
          imageUrl: 'assets/images/casablanca.jpg',
          price: 150.0, // MAD
          rating: 4.5,
          reviewCount: 67,
          latitude: 33.5890,
          longitude: -7.6114,
          images: ['assets/images/casablanca.jpg'],
          description:
              'Exclusive opening night for contemporary Moroccan artists exhibition. Meet the artists, enjoy wine and traditional appetizers.',
          host: 'Galerie Moderne Casa',
          amenities: [
            'Art Exhibition',
            'Wine & Appetizers',
            'Artist Meet & Greet',
            'Networking'
          ],
          category: 'art',
          duration: '3 hours',
        ),
        // Restaurants
        MockListing(
          id: '4',
          title: 'La Sqala Restaurant',
          location: 'Old Medina',
          imageUrl: 'assets/images/casablanca.jpg',
          price: 320.0, // MAD per person
          rating: 4.7,
          reviewCount: 234,
          latitude: 33.5950,
          longitude: -7.6200,
          images: [
            'assets/images/casablanca.jpg',
            'assets/images/casablanca.jpg',
          ],
          description:
              'Dine in a historic fortress setting with authentic Moroccan cuisine. Famous for its tagines, pastilla, and traditional mint tea service.',
          host: 'Restaurant La Sqala',
          amenities: [
            'Traditional Cuisine',
            'Historic Setting',
            'Outdoor Terrace',
            'Live Music Fridays'
          ],
          category: 'restaurant',
          duration: '2-3 hours dining',
        ),
        MockListing(
          id: '5',
          title: 'Rick\'s Café Casablanca',
          location: 'Boulevard Sour Jdid',
          imageUrl: 'assets/images/casablanca.jpg',
          price: 480.0, // MAD per person
          rating: 4.6,
          reviewCount: 445,
          latitude: 33.5970,
          longitude: -7.6180,
          images: [
            'assets/images/casablanca.jpg',
            'assets/images/casablanca.jpg'
          ],
          description:
              'Inspired by the famous movie, this upscale restaurant offers international cuisine with Moroccan touches in an elegant 1940s atmosphere.',
          host: 'Rick\'s Café',
          amenities: [
            'International Cuisine',
            'Piano Bar',
            'Movie Memorabilia',
            'Cocktail Menu'
          ],
          category: 'restaurant',
          duration: '2-4 hours dining',
        ),
        MockListing(
          id: '6',
          title: 'Rooftop Sunset Dinner',
          location: 'Ain Diab Corniche',
          imageUrl: 'assets/images/casablanca.jpg',
          price: 380.0, // MAD per person
          rating: 4.8,
          reviewCount: 178,
          latitude: 33.5650,
          longitude: -7.6094,
          images: ['assets/images/casablanca.jpg'],
          description:
              'Exclusive rooftop dining experience with panoramic ocean views. Modern Moroccan fusion cuisine paired with spectacular sunset views.',
          host: 'Sky Lounge Casa',
          amenities: [
            'Ocean Views',
            'Fusion Cuisine',
            'Sunset Views',
            'Cocktail Pairing'
          ],
          category: 'restaurant',
          duration: '3 hours dining',
        ),
        MockListing(
          id: '7',
          title: 'Flamenco & Dinner Show',
          location: 'Anfa District',
          imageUrl: 'assets/images/casablanca.jpg',
          price: 550.0, // MAD per person
          rating: 4.9,
          reviewCount: 123,
          latitude: 33.5800,
          longitude: -7.6300,
          images: [
            'assets/images/casablanca.jpg',
            'assets/images/casablanca.jpg'
          ],
          description:
              'An unforgettable evening combining authentic Spanish flamenco performance with exquisite Mediterranean-Moroccan fusion dinner.',
          host: 'Teatro Flamenco Casa',
          amenities: [
            'Live Flamenco Show',
            'Professional Dancers',
            '3-Course Dinner',
            'Wine Pairing'
          ],
          category: 'entertainment',
          duration: '3.5 hours',
        ),
        MockListing(
          id: '8',
          title: 'Street Food Walking Tour',
          location: 'Central Market Area',
          imageUrl: 'assets/images/casablanca.jpg',
          price: 200.0, // MAD per person
          rating: 4.7,
          reviewCount: 201,
          latitude: 33.5900,
          longitude: -7.6000,
          images: ['assets/images/casablanca.jpg'],
          description:
              'Discover Casablanca\'s best street food with a local guide. Taste authentic snacks, fresh juices, and traditional sweets.',
          host: 'Casa Food Tours',
          amenities: [
            'Local Guide',
            'Food Tastings',
            'Cultural Stories',
            'Small Groups'
          ],
          category: 'tour',
          duration: '2.5 hours',
        ),
      ];

  static List<MockReview> get reviews => [
        MockReview(
          id: '1',
          userName: 'Amina Tazi',
          userAvatar: 'assets/images/casablanca.jpg',
          rating: 5.0,
          comment:
              'The Gnawa concert was absolutely magical! The musicians were incredibly talented and the atmosphere was perfect.',
          date: DateTime.now().subtract(const Duration(days: 3)),
        ),
        MockReview(
          id: '2',
          userName: 'Jean-Pierre Dubois',
          userAvatar: 'assets/images/casablanca.jpg',
          rating: 4.8,
          comment:
              'Fantastic cooking workshop! Chef Aicha taught us so much about Moroccan cuisine. The tagine was delicious!',
          date: DateTime.now().subtract(const Duration(days: 8)),
        ),
        MockReview(
          id: '3',
          userName: 'Maria Rodriguez',
          userAvatar: 'assets/images/casablanca.jpg',
          rating: 4.9,
          comment:
              'Rick\'s Café exceeded all expectations. The ambiance, food, and service were all outstanding!',
          date: DateTime.now().subtract(const Duration(days: 12)),
        ),
        MockReview(
          id: '4',
          userName: 'Omar Benali',
          userAvatar: 'assets/images/casablanca.jpg',
          rating: 4.6,
          comment:
              'Great street food tour! Our guide knew all the best spots and the food was authentic and delicious.',
          date: DateTime.now().subtract(const Duration(days: 15)),
        ),
      ];

  static Map<String, List<DateTime>> get availability => {
        '1': [
          DateTime.now().add(const Duration(days: 2)),
          DateTime.now().add(const Duration(days: 5)),
          DateTime.now().add(const Duration(days: 9)),
          DateTime.now().add(const Duration(days: 12)),
        ],
        '2': [
          DateTime.now().add(const Duration(days: 1)),
          DateTime.now().add(const Duration(days: 4)),
          DateTime.now().add(const Duration(days: 7)),
          DateTime.now().add(const Duration(days: 11)),
        ],
        '3': [
          DateTime.now().add(const Duration(days: 3)),
          DateTime.now().add(const Duration(days: 6)),
          DateTime.now().add(const Duration(days: 10)),
        ],
        '4': [
          DateTime.now().add(const Duration(days: 1)),
          DateTime.now().add(const Duration(days: 2)),
          DateTime.now().add(const Duration(days: 3)),
          DateTime.now().add(const Duration(days: 4)),
        ],
        '5': [
          DateTime.now().add(const Duration(days: 2)),
          DateTime.now().add(const Duration(days: 5)),
          DateTime.now().add(const Duration(days: 8)),
        ],
        '6': [
          DateTime.now().add(const Duration(days: 1)),
          DateTime.now().add(const Duration(days: 3)),
          DateTime.now().add(const Duration(days: 6)),
          DateTime.now().add(const Duration(days: 9)),
        ],
        '7': [
          DateTime.now().add(const Duration(days: 4)),
          DateTime.now().add(const Duration(days: 7)),
          DateTime.now().add(const Duration(days: 11)),
        ],
        '8': [
          DateTime.now().add(const Duration(days: 1)),
          DateTime.now().add(const Duration(days: 2)),
          DateTime.now().add(const Duration(days: 4)),
          DateTime.now().add(const Duration(days: 6)),
        ],
      };
}
